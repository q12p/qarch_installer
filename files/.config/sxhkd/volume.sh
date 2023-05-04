#!/usr/bin/env bash

# You can call this script like this:
# $ ./brightnessControl.sh up
# $ ./brightnessControl.sh down

# Script inspired by these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_volume {
	volume_value=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n 1 | tr -d '%')
	printf "%.0f\n" $volume_value
}

function send_notification {
  icon="/home/q12/.config/status/volume.png"
  volume=$(get_volume)
  # Make the bar with the special character ─ (it's not dash -)
  # https://en.wikipedia.org/wiki/Box-drawing_character
  bar=$(seq -s "─" 0 $((volume / 5)) | sed 's/[0-9]//g')
  # Send the notification
  dunstify -i "$icon" -r 5555 -u normal "    $bar"
}

case $1 in
  up)
    # increase the backlight by 5%
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    send_notification
    ;;
  down)
    # decrease the backlight by 5%
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    send_notification
    ;;
esac
