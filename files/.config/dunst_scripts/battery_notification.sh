#!/bin/bash

while true; do
    battery_level=$(acpi | awk '{print $4}' | tr -d ',' | tail -n 1)
    if [[ $battery_level == "25%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 25%"
        break
    elif [[ $battery_level == "20%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 20%"
        break
    elif [[ $battery_level == "15%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 15%"
        break
    elif [[ $battery_level == "10%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 10%"
        break
    elif [[ $battery_level == "5%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 5%"
        break
    elif [[ $battery_level == "4%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 4%"
        break
    elif [[ $battery_level == "3%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 3%"
        break
    elif [[ $battery_level == "2%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 2%"
        break
    elif [[ $battery_level == "1%" ]]; then
        dunstify -u critical "Battery Low" "Battery level is at 1%"
        break
    fi
    sleep 60
done

