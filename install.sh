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
  apt_install curl ca-certificates nodejs npm || return 1

  # Ha a node-red nincs fent, felrakjuk npm-mel
  if ! command -v node-red >/dev/null 2>&1; then
    log "Node-RED telepítése npm-mel"
    # --unsafe-perm kell rootos telepítéshez sok esetben
    run npm install -g --unsafe-perm node-red || return 1
  fi

  # user + mappa
  id -u nodered >/dev/null 2>&1 || run useradd -r -m -s /usr/sbin/nologin nodered || true
  run mkdir -p /var/lib/node-red || true
  run chown -R nodered:nodered /var/lib/node-red || true

  # Systemd unit LÉTREHOZÁSA (mindig)
  cat > /etc/systemd/system/nodered.service <<'UNIT'
[Unit]
Description=Node-RED
After=network.target

[Service]
Type=simple
User=nodered
Group=nodered
WorkingDirectory=/var/lib/node-red
Environment="NODE_RED_OPTIONS=--userDir /var/lib/node-red --port 1880"
ExecStart=/usr/bin/env node-red $NODE_RED_OPTIONS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

  run systemctl daemon-reload || true
  run systemctl enable --now nodered.service || true

  # ellenőrzés
  if systemctl is-active --quiet nodered; then
    return 0
  fi

  warn "Node-RED nem indult el, journal:"
  journalctl -u nodered.service --no-pager -n 80 2>/dev/null | tee -a "$LOGFILE" >/dev/null || true
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
for svc in apache2 ssh mosquitto mariadb nodered; do
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
