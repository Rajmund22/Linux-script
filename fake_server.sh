#!/bin/bash

clear

echo "======================================="
echo "        Linux Server Monitor"
echo "======================================="
echo

sleep 1

while true
do
    clear

    cpu=$((RANDOM % 70 + 20))
    ram=$((RANDOM % 60 + 30))
    net=$((RANDOM % 900 + 100))
    users=$((RANDOM % 12 + 1))
    temp=$((RANDOM % 30 + 40))

    uptime_hours=$((RANDOM % 72 + 1))
    uptime_minutes=$((RANDOM % 59))

    echo "======================================="
    echo "         SERVER STATUS: ONLINE"
    echo "======================================="
    echo

    echo "CPU Usage:        $cpu%"
    echo "RAM Usage:        $ram%"
    echo "Network Traffic:  ${net}MB/s"
    echo "CPU Temperature:  ${temp}°C"
    echo "Connected Users:  $users"
    echo "Server Uptime:    ${uptime_hours}h ${uptime_minutes}m"

    echo
    echo "---------------------------------------"
    echo " Running Services"
    echo "---------------------------------------"

    services=("nginx" "mysql" "docker" "ssh" "apache2")

    for service in "${services[@]}"
    do
        echo "[OK] $service running"
        sleep 0.1
    done

    echo
    echo "---------------------------------------"
    echo " Security"
    echo "---------------------------------------"

    if (( RANDOM % 10 < 3 ))
    then
        echo "[WARNING] Suspicious login attempt detected"
    else
        echo "[OK] No threats detected"
    fi

    echo
    echo "Refreshing in 2 seconds..."
    
    sleep 2
done
