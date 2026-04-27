#!/bin/bash

for i in {1..20}
do
  usage=$((RANDOM % 100))
  echo "CPU usage: $usage%"
  sleep 1
done
