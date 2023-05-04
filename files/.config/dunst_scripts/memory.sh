#!/bin/bash

current_memory=$(free -h | awk '/Mem:/ {print $3}')
current_cpu=$(cat /proc/stat | awk '/cpu/{printf("%.2f%\n", ($2+$4)*100/($2+$4+$5))}')

dunstify -u low -t 3500  "Memory: $current_memory" "CPU:\n$current_cpu"

