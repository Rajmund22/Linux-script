#!/bin/bash

clear

ips=(
    "192.168.1.24"
    "45.83.122.14"
    "103.44.72.91"
    "172.16.0.5"
    "88.214.55.11"
    "203.12.94.7"
)

users=(
    "root"
    "admin"
    "ubuntu"
    "server"
    "guest"
)

countries=(
    "RU"
    "CN"
    "US"
    "DE"
    "BR"
    "KR"
)

clear

echo "==========================================="
echo "        SSH BREACH DETECTOR"
echo "==========================================="
echo

sleep 1

echo "[*] Monitoring SSH activity..."
sleep 2

echo "[*] Firewall active"
sleep 1

echo "[*] Intrusion detection enabled"
sleep 1

echo
echo "==========================================="

while true
do

    ip=${ips[$RANDOM % ${#ips[@]}]}
    user=${users[$RANDOM % ${#users[@]}]}
    country=${countries[$RANDOM % ${#countries[@]}]}

    action=$((RANDOM % 5))

    echo

    case $action in

        0)
            echo "[INFO] Successful login:"
            echo "       User: $user"
            echo "       IP: $ip [$country]"
            ;;

        1)
            echo "[WARNING] Failed SSH login attempt"
            echo "          User: $user"
            echo "          IP: $ip [$country]"
            ;;

        2)
            echo "[ALERT] Multiple failed login attempts detected"
            echo "        Source IP: $ip [$country]"
            echo "        Firewall response initiated"
            ;;

        3)
            echo "[BLOCKED] IP blocked by firewall"
            echo "          IP: $ip [$country]"
            ;;

        4)
            echo "[CRITICAL] Possible brute force attack detected"
            echo "           Attacker IP: $ip [$country]"
            echo "           SSH port secured"
            ;;

    esac

    sleep 2

done
