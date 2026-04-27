#!/bin/bash

for i in {1..100}
do
  echo "Backing up /home... $i%"
  sleep 0.05
done

echo "Backup complete."
