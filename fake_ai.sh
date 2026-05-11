#!/bin/bash

clear

echo "========================================="
echo "        AI TERMINAL ASSISTANT"
echo "========================================="
echo

sleep 1

echo "[OK] AI core initialized"
sleep 1

echo "[OK] Terminal access granted"
sleep 1

echo
echo "Type 'help' to view commands."
echo

while true
do

    echo -n "AI-Terminal > "
    read cmd

    case $cmd in

        help)

            echo
            echo "Available commands:"
            echo "----------------------------"
            echo "help      - Show commands"
            echo "scan      - Scan network"
            echo "status    - System status"
            echo "hack      - Fake hack mode"
            echo "clear     - Clear terminal"
            echo "exit      - Exit assistant"
            echo
            ;;

        scan)

            echo
            echo "[*] Scanning local network..."
            sleep 2

            echo "[OK] Device found: 192.168.1.12"
            sleep 1

            echo "[OK] Device found: 192.168.1.24"
            sleep 1

            echo "[OK] Device found: 192.168.1.51"
            echo
            ;;

        status)

            cpu=$((RANDOM % 70 + 20))
            ram=$((RANDOM % 60 + 30))
            users=$((RANDOM % 8 + 1))

            echo
            echo "System Status"
            echo "----------------------------"
            echo "CPU Usage: $cpu%"
            echo "RAM Usage: $ram%"
            echo "Connected Users: $users"
            echo "Firewall: ACTIVE"
            echo
            ;;

        hack)

            echo
            echo "[*] Connecting to remote server..."
            sleep 2

            echo "[*] Bypassing firewall..."
            sleep 2

            echo "[*] Injecting payload..."
            sleep 2

            echo "[OK] ACCESS GRANTED"
            echo

            echo " ☠ SYSTEM COMPROMISED ☠ "
            echo
            ;;

        clear)

            clear
            ;;

        exit)

            echo
            echo "[OK] Shutting down AI assistant..."
            sleep 1

            echo "Goodbye."
            echo

            break
            ;;

        *)

            echo
            echo "[ERROR] Unknown command"
            echo "Type 'help' for available commands."
            echo
            ;;

    esac

done
