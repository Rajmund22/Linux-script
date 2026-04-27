#!/bin/bash

services=("Network Manager" "Bluetooth" "Apache" "MySQL")

for s in "${services[@]}"
do
  echo "[ OK ] Started $s"
  sleep 1
done

echo "System ready."
