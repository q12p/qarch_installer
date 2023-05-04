#!/bin/bash

battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d '%')

charge=$(echo "75 - $battery_level" | bc)
time=$(echo "$charge * 45 / 55" | bc)


if [ $battery_level -ge 75 ]; then
  battery_symbol=""
  time=""
  message=$(echo -e "$battery_symbol $battery_level%")
elif [ $battery_level -ge 50 ]; then
  battery_symbol=""
  time=$(echo "$charge * 45 / 55" | bc)
  message=$(echo -e "$battery_symbol $battery_level%\nTo charge to 75%: $time minutes.")
elif [ $battery_level -ge 25 ]; then
  battery_symbol=""
  time=$(echo "$charge * 45 / 55" | bc)
  message=$(echo -e "$battery_symbol $battery_level%\nTo charge to 75%: $time minutes.")
else
  battery_symbol=""
  time=$(echo "$charge * 45 / 55" | bc)
  message=$(echo -e "$battery_symbol $battery_level%\nTo charge to 75%: $time minutes.")
fi


dunstify -u low -t 3500 "$message"

