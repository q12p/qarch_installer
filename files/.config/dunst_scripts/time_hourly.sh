#!/bin/sh 
# cron.sh
# Notifies the user of date and time
sleep 59
source /home/q12/.bashrc
pid=$(pgrep -u q12 bspwm | head -n 1)
dbus=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ | sed 's/DBUS_SESSION_BUS_ADDRESS=//' )
export DBUS_SESSION_BUS_ADDRESS=$dbus
export HOME=/home/q12
export DISPLAY=:0
/usr/bin/dunstify "$(/bin/date +"%T")"

