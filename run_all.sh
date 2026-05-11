#!/bin/bash

clear

echo "========================================="
echo "       Linux Simulation Suite"
echo "========================================="
echo

sleep 2

# ---------------- INSTALLER ----------------

echo "[1/5] Starting Package Installer..."
sleep 2

./fake_installer.sh

echo
echo "Press ENTER to continue..."
read

clear

# ---------------- SERVER MONITOR ----------------

echo "[2/5] Starting Server Monitor..."
sleep 2

echo
echo "Press CTRL + C when finished viewing."
echo
sleep 2

./fake_server.sh

clear

# ---------------- SSH BREACH ----------------

echo "[3/5] Starting SSH Breach Detector..."
sleep 2

echo
echo "Press CTRL + C when finished viewing."
echo
sleep 2

./fake_detector.sh

clear

# ---------------- DISK REPAIR ----------------

echo "[4/5] Starting Disk Repair Tool..."
sleep 2

./fake_disk.sh

echo
echo "Press ENTER to continue..."
read

clear

# ---------------- AI TERMINAL ----------------

echo "[5/5] Starting AI Terminal Assistant..."
sleep 2

./fake_ai.sh

clear

echo "========================================="
echo "     All simulations completed."
echo "========================================="
echo
