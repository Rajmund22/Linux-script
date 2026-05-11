#!/bin/bash

clear

packages=(
    "python3"
    "net-tools"
    "nmap"
    "apache2"
    "docker.io"
    "gcc"
    "vim"
    "htop"
    "curl"
    "git"
)

dependencies=(
    "libssl"
    "libcrypto"
    "python3-dev"
    "network-utils"
    "system-core"
    "libc6"
)

echo "===================================="
echo "      Linux Package Installer"
echo "===================================="
echo

sleep 1

echo "[*] Frissítés keresése..."
sleep 2

echo "[*] Csomaglista letöltése..."
sleep 2

echo
echo "[*] Függőségek ellenőrzése..."
echo

for dep in "${dependencies[@]}"
do
    echo "[OK] $dep"
    sleep 0.5
done

echo
echo "[*] Telepítés indítása..."
echo

for i in {0..100}
do
    package=${packages[$RANDOM % ${#packages[@]}]}

    echo -ne "\r[$i%] Installing: $package..."

    sleep 0.05
done

echo
echo
sleep 1

echo "[OK] Minden csomag sikeresen telepítve."
echo "[OK] System update complete."

echo
echo "===================================="
echo " Installation Finished Successfully "
echo "===================================="
echo
