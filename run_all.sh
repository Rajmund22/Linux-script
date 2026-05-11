#!/bin/bash

clear

echo "========================================="
echo "       Linux Simulation Suite"
echo "========================================="
echo

sleep 2

# ---------------- INSTALLER ----------------

clear
echo "[1/5] Starting Package Installer..."
sleep 2

./fake_installer.sh

echo
echo "Press ENTER to continue..."
read

# ---------------- SERVER MONITOR ----------------

clear
echo "[2/5] Starting Server Monitor..."
sleep 2

echo
echo "Press ENTER at any time to continue..."
echo

while true
do
    ./fake_server.sh &

    pid=$!

    read -n 1 key

    kill $pid 2>/dev/null

    break
done

# ---------------- SSH BREACH DETECTOR ----------------

clear
echo "[3/5] Starting SSH Breach Detector..."
sleep 2

echo
echo "Press ENTER at any time to continue..."
echo

while true
do
    ./fake_detector.sh &

    pid=$!

    read -n 1 key

    kill $pid 2>/dev/null

    break
done

# ---------------- DISK REPAIR ----------------

clear
echo "[4/5] Starting Disk Repair Tool..."
sleep 2

./fake_disk.sh

echo
echo "Press ENTER to continue..."
read

# ---------------- AI TERMINAL ----------------

clear
echo "[5/5] Starting AI Terminal Assistant..."
sleep 2

./fake_ai.sh

# ---------------- FINISH ----------------

clear

echo "========================================="
echo "     All simulations completed."
echo "========================================="
echo

sleep 2
