#!/bin/bash

clear

partitions=(
    "/dev/sda1"
    "/dev/sda2"
    "/dev/nvme0n1p1"
    "/dev/nvme0n1p2"
)

errors=(
    "Orphaned inode detected"
    "Corrupted filesystem journal"
    "Invalid sector table"
    "Filesystem inconsistency"
    "Directory checksum mismatch"
)

partition=${partitions[$RANDOM % ${#partitions[@]}]}

echo "========================================="
echo "         DISK REPAIR TOOL"
echo "========================================="
echo

sleep 1

echo "[*] Initializing filesystem scan..."
sleep 2

echo "[*] Selected partition: $partition"
sleep 1

echo "[*] Mount status: UNMOUNTED"
sleep 1

echo
echo "========================================="
echo

for i in {0..100}
do

    echo -ne "\r[SCAN] Checking sectors... $i%"

    sleep 0.05

    # random hibák
    if (( RANDOM % 40 == 1 ))
    then
        echo
        err=${errors[$RANDOM % ${#errors[@]}]}

        echo "[WARNING] $err"
        sleep 1

        echo "[FIX] Repairing issue..."
        sleep 1

        echo "[OK] Issue resolved"
    fi

done

echo
echo
sleep 1

echo "[*] Rebuilding filesystem journal..."
sleep 2

echo "[*] Verifying disk integrity..."
sleep 2

echo
echo "[SUCCESS] Filesystem successfully repaired"
echo "[SUCCESS] No critical errors remaining"

echo
echo "========================================="
echo "      DISK REPAIR COMPLETED"
echo "========================================="
echo
