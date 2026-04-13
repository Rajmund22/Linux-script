#!/bin/bash

BASE="$HOME/escape_room"

# SZÍNEK
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}        DISCORD ADMIN TERMINAL${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${RED}⚠️ Rendszergazda hitelesítés szükséges${NC}"
echo ""
echo -e "${YELLOW}Titkos információ:${NC}"
echo "Felhasználónév: +>@1M7"
echo "Jelszó: 8O(#\`="
echo ""

# LOGIN
while true
do
    read -p "Felhasználónév: " user
    read -s -p "Jelszó: " pass
    echo ""

    if [[ "$user" == "Balint" && "$pass" == "Bolyai" ]]; then
        echo -e "${GREEN}✅ Hozzáférés megadva${NC}"
        sleep 2
        break
    else
        echo -e "${RED}❌ Hibás adatok!${NC}"
        sleep 2
        clear
    fi
done

clear
echo -e "${GREEN}Belépve a rendszerbe...${NC}"
sleep 2

# NODE-RED
if ! command -v node-red &> /dev/null
then
    sudo apt update
    sudo apt install -y nodejs npm
    sudo npm install -g --unsafe-perm node-red
    mkdir -p ~/.node-red && cd ~/.node-red
    npm install node-red-dashboard
fi

node-red &
sleep 5

# MAPPÁK
rm -rf "$BASE" 2>/dev/null
mkdir -p "$BASE"
cd "$BASE"

mkdir -p Logs Backup Temp Secrets Data Config
mkdir -p Discord/szerverek

# CLUE-K
echo "WARNING: Server unstable below 30°C" > Logs/system.log
echo "Temperature critical threshold: 30" > Logs/temp_hint.txt

echo "Backup rotation sequence: 6 -> 15 -> 8" > Secrets/backup.txt
echo "Sequence hint: first low then high then medium" > Secrets/hint2.txt

echo "Power sequence: ON OFF ON" > Config/power.conf
echo "Binary pattern: 101" > Config/binary.txt

echo "Hold button for 5 seconds to confirm override" > Data/button.txt
echo "Authentication requires patience..." > Data/hint_btn.txt

echo "Override code: 7429" > Backup/code.txt

# SZERVEREK
cd Discord/szerverek
servers=(alpha beta gamma delta epsilon zeta theta omega nexus titan matrix cyber void shadow neon quantum vortex pixel arcadia szarfos)

for s in "${servers[@]}"
do
    mkdir -p "$s"
done

# =========================
# VIZUÁLIS FA (FIXED)
# =========================
cd "$BASE"

clear
echo -e "${GREEN}📂 RENDSZER ELÉRÉS MEGADVA${NC}"
echo "========================================="

echo "escape_room/"
echo "├── Logs/"
echo "│   ├── system.log"
echo "│   └── temp_hint.txt"
echo "├── Secrets/"
echo "│   ├── backup.txt"
echo "│   └── hint2.txt"
echo "├── Data/"
echo "│   ├── button.txt"
echo "│   └── hint_btn.txt"
echo "├── Config/"
echo "│   ├── power.conf"
echo "│   └── binary.txt"
echo "├── Backup/"
echo "│   └── code.txt"
echo "└── Discord/"
echo "    └── szerverek/"
ls Discord/szerverek

echo ""
echo -e "${YELLOW}💡 TIPP: Az ajtó bezáródott… találd meg a kijutás módját!${NC}"
echo "📄 Hasznos parancsok: cat, ls, cd, rmdir"
echo -e "${RED}🎯 Feladat: töröld a hibás szervert${NC}"
echo ""
echo -e "${BLUE}🌐 Dashboard: http://localhost:1880/ui${NC}"

xdg-open http://localhost:1880/ui 2>/dev/null &

# =========================
# COUNTDOWN (CSAK LOSE)
# =========================

countdown() {
    seconds=300

    echo ""
    echo "========================================="
    echo "⚠️ FURCSA TEVÉKENYSÉG ÉSZLELVE"
    echo "🔒 AZ AJTÓ LEZÁRÁSI RENDSZERE AKTIVÁLVA"
    echo "========================================="
    echo ""
    echo "⏳ VISSZASZÁMLÁLÁS ELINDULT (05:00)"
    echo ""

    while [ $seconds -gt 0 ]
    do
        min=$((seconds / 60))
        sec=$((seconds % 60))
        printf "\r⏳ Hátralévő idő: %02d:%02d " $min $sec
        sleep 1
        ((seconds--))
    done

    echo ""
    echo ""
    echo "🚓 ELKAPTAK A RENDŐRÖK!"
    echo "❌ VESZTETTÉL"
    sleep 5
    exit
}

(
TARGET="$BASE/Discord/szerverek/szarfos"

while true
do
    if [ ! -d "$TARGET" ]; then
        countdown
        break
    fi
    sleep 1
done
) &

cd "$BASE"
export PS1="(DISCORD-SERVER) $ "
exec bash
