#!/usr/bin/env bash
set -u
export DEBIAN_FRONTEND=noninteractive
 
############################################
# KÖTELEZŐ: bash + root + stabil PATH
############################################
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "Ezt bash-al kell futtatni: bash ./install.sh"
  exit 1
fi
 
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Root jogosultság szükséges."
  echo "Futtasd így:"
  echo "  su -"
  echo "  cd /ahol/a/script/van"
  echo "  chmod +x install.sh"
  echo "  ./install.sh"
  exit 1
fi
 
# VirtualBox/minimal rendszereken gyakori PATH-hiba javítása
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
############################################
# KONFIG
############################################
CONFIG_FILE="./config.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "WARN: config.conf nem található, alapértelmezett értékekkel futok."
fi
 
: "${DRY_RUN:=false}"
: "${INSTALL_APACHE:=true}"
: "${INSTALL_SSH:=true}"
: "${INSTALL_NODE_RED:=true}"
: "${INSTALL_MOSQUITTO:=true}"
: "${INSTALL_MARIADB:=true}"
: "${INSTALL_PHP:=true}"
: "${INSTALL_UFW:=true}"
: "${LOGFILE:=/var/log/showoff_installer.log}"
 
############################################
# SZÍNEK
############################################
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
PURPLE="\e[35m"
NC="\e[0m"
 
############################################
# LOG
############################################
mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true
touch "$LOGFILE" 2>/dev/null || true
 
log() { echo "$(date '+%F %T') | $1" | tee -a "$LOGFILE" >/dev/null; }
ok() { echo -e "${GREEN}✔ $1${NC}"; log "OK: $1"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; log "WARN: $1"; }
fail() { echo -e "${RED}✖ $1${NC}"; log "FAIL: $1"; }
 
run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    warn "[DRY-RUN] $*"
    return 0
  fi
  "$@"
}
 
############################################
# BANNER
############################################
clear
cat << "EOF"
=========================================
  SHOW-OFF SERVER INSTALLER vFINAL
  Apache | Node-RED | MQTT | MariaDB | PHP | UFW
  VirtualBox / Debian / Ubuntu - STABIL
=========================================
EOF
echo -e "${BLUE}Logfile:${NC} $LOGFILE"
echo
 
############################################
# EREDMÉNYEK
############################################
declare -A RESULTS
set_result() { RESULTS["$1"]="$2"; }
 
############################################
# APT HELPERS (STABIL)
############################################
apt_update() {
  log "APT csomaglista frissítése"
  run apt-get update -y
}
 
apt_install() {
  log "Csomag telepítés: $*"
  run apt-get install -y "$@"
}
 
############################################
# SAFE STEP (ne szakadjon meg félúton)
############################################
safe_step() {
  local label="$1"; shift
  log "START: $label -> $*"
  if "$@"; then
    set_result "$label" "SIKERES"
    return 0
  else
    set_result "$label" "HIBA"
    return 1
  fi
}
 
############################################
# INSTALL FUNCS
############################################
install_apache() {
  apt_install apache2 || return 1
  run systemctl enable --now apache2 || return 1
  return 0
}
 
install_ssh() {
  apt_install openssh-server || return 1
  run systemctl enable --now ssh || return 1
  return 0
}
 
install_mosquitto() {
  apt_install mosquitto mosquitto-clients || return 1
  run systemctl enable --now mosquitto || return 1
  return 0
}
 
install_mariadb() {
  apt_install mariadb-server || return 1
  run systemctl enable --now mariadb || return 1
  return 0
}
 
install_php() {
  apt_install php libapache2-mod-php php-mysql || return 1
  run systemctl restart apache2 || return 1
  return 0
}
 
install_ufw() {
  apt_install ufw || return 1
  run ufw allow OpenSSH || return 1
  run ufw allow 80/tcp || return 1
  run ufw allow 1880/tcp || return 1
  run ufw allow 1883/tcp || return 1
  run ufw --force enable || return 1
  return 0
}
 
install_node_red() {
  apt_install curl ca-certificates || return 1

  log "Node-RED telepítés (non-interactive --confirm-root)"
  local rc=0

  # Ne kapcsoljunk be set -e-t, mert az kint maradhat és szétcsapja a scriptet
  if ! curl -fsSL https://github.com/node-red/linux-installers/releases/latest/download/update-nodejs-and-nodered-deb \
      | bash -s -- --confirm-root; then
    rc=$?
    warn "Node-RED installer nem 0-val lépett ki (rc=$rc) – ettől még lehet jó."
  fi
  log "Node-RED installer exit code: $rc"

  run systemctl daemon-reload || true

  # Service név lehet node-red vagy nodered, disztrótól függően
  local unit=""
  for u in node-red.service nodered.service; do
    if systemctl list-unit-files --type=service 2>/dev/null | awk '{print $1}' | grep -qx "$u"; then
      unit="$u"
      break
    fi
  done

  if [[ -n "$unit" ]]; then
    run systemctl enable --now "$unit" || true
  fi

  # Siker, ha bármelyik service fut
  if systemctl is-active --quiet node-red 2>/dev/null || systemctl is-active --quiet nodered 2>/dev/null; then
    return 0
  fi

  # Siker, ha a 1880 port hallgat (Node-RED web UI)
  if command -v ss >/dev/null 2>&1; then
    ss -ltnp 2>/dev/null | grep -E '(:1880)\b' >/dev/null && return 0
  fi

  # Ha itt vagyunk, adjunk hasznos logot
  warn "Node-RED nem fut. Journal részlet:"
  if systemctl list-unit-files --type=service | grep -q '^node-red\.service'; then
    journalctl -u node-red.service --no-pager -n 80 2>/dev/null | tee -a "$LOGFILE" >/dev/null || true
  fi
  if systemctl list-unit-files --type=service | grep -q '^nodered\.service'; then
    journalctl -u nodered.service --no-pager -n 80 2>/dev/null | tee -a "$LOGFILE" >/dev/null || true
  fi

  return 1
}

 
############################################
# FUTTATÁS
############################################
if apt_update; then
  ok "APT update kész"
else
  warn "APT update sikertelen (internet/DNS/repo gond)."
fi
 
run_install() {
  local var="$1"
  local label="$2"
  local func="$3"
 
  echo -e "${BLUE}==> ${label}${NC}"
  if [[ "${!var:-false}" == "true" ]]; then
    if safe_step "$label" "$func"; then
      ok "$label OK"
    else
      fail "$label HIBA"
    fi
  else
    warn "$label kihagyva (config: $var=false)"
    set_result "$label" "KIHAGYVA"
  fi
  echo
}
 
run_install INSTALL_APACHE     "Apache2"   install_apache
run_install INSTALL_SSH        "SSH"       install_ssh
run_install INSTALL_MOSQUITTO  "Mosquitto" install_mosquitto
run_install INSTALL_NODE_RED   "Node-RED"  install_node_red
run_install INSTALL_MARIADB    "MariaDB"   install_mariadb
run_install INSTALL_PHP        "PHP"       install_php
run_install INSTALL_UFW        "UFW"       install_ufw
 
############################################
# HEALTH CHECK + PORT CHECK
############################################
log "HEALTH CHECK"
for svc in apache2 ssh mosquitto mariadb node-red nodered; do
  if systemctl is-active --quiet "$svc" 2>/dev/null; then
    ok "$svc RUNNING"
  else
    warn "$svc NEM FUT"
  fi
done
 
log "PORT CHECK (80,1880,1883)"
if command -v ss >/dev/null 2>&1; then
  ss -tulpn | grep -E '(:80|:1880|:1883)\b' >/dev/null \
&& ok "Portok rendben" \
    || warn "Nem látok hallgatózó portot (lehet szolgáltatás nem fut)."
else
  warn "ss parancs nem elérhető"
fi
 
############################################
# ÖSSZEFOGLALÓ + HAJRÁ LILÁK
############################################
echo
echo "================================="
echo "  TELEPÍTÉSI ÖSSZEFOGLALÓ"
echo "================================="
for k in "${!RESULTS[@]}"; do
  echo "$k : ${RESULTS[$k]}"
done
echo
 
any_fail=0
for k in "${!RESULTS[@]}"; do
  if [[ "${RESULTS[$k]}" == "HIBA" ]]; then
    any_fail=1
  fi
done
 
if [[ "$any_fail" -eq 0 ]]; then
  echo -e "${GREEN}KÉSZ – minden lépés rendben lefutott.${NC}"
  log "Telepítés befejezve: SIKERES"
 
  echo
  echo -e "${PURPLE}"
  cat << "EOF"
██╗  ██╗ █████╗      ██╗██████╗  █████╗     ██╗     ██╗██╗      █████╗ ██╗  ██╗
██║  ██║██╔══██╗     ██║██╔══██╗██╔══██╗    ██║     ██║██║     ██╔══██╗██║ ██╔╝
███████║███████║     ██║██████╔╝███████║    ██║     ██║██║     ███████║█████╔╝ 
██╔══██║██╔══██║██   ██║██╔══██╗██╔══██║    ██║     ██║██║     ██╔══██║██╔═██╗ 
██║  ██║██║  ██║╚█████╔╝██║  ██║██║  ██║    ███████╗██║███████╗██║  ██║██║  ██╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
EOF
  echo -e "${NC}"
  exit 0
else
  echo -e "${YELLOW}KÉSZ – volt sikertelen lépés. Nézd a logot: $LOGFILE${NC}"
  log "Telepítés befejezve: RÉSZBEN SIKERES"
  exit 1
fi
