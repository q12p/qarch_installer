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
  volume=$(get_volume)
  if [ $volume -lt 1 ];then
	  icon="/usr/share/icons/Papirus-Dark/16x16/panel/audio-off.svg"
  elif [ $volume -lt 25 ];then
	  icon="/usr/share/icons/Papirus-Dark/16x16/panel/audio-volume-low.svg"
  elif [ $volume -lt 50 ];then
	  icon="/usr/share/icons/Papirus-Dark/16x16/panel/audio-volume-medium.svg"
  elif [ $volume -lt 75 ];then
	  icon="/usr/share/icons/Papirus-Dark/16x16/panel/audio-volume-high.svg"
  elif [ $volume -le 100 ];then
	  icon="/usr/share/icons/Papirus-Dark/16x16/panel/audio-volume-too-high.svg"
  elif [ $volume -gt 100 ];then
	  icon="/usr/share/icons/Papirus-Dark/16x16/panel/audio-volume-too-high.svg"
  fi

  # Make the bar with the special character ─ (it's not dash -)
  # https://en.wikipedia.org/wiki/Box-drawing_character
  bar=$(seq -s "─" 0 $((volume / 5)) | sed 's/[0-9]//g')
  # Send the notification
  dunstify -i "$icon" -r 5555 -u normal "$volume $bar"
}

case $1 in
  up)
    volume_v=$(get_volume)
    if [ $volume_v -ge 100 ];then
	    send_notification
	    exit 1
    fi
    # increase the backlight by 5%
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    if [ $((volume_v + 5)) -ge 100 ];then
	    pactl set-sink-volume @DEFAULT_SINK@ 100%
	    exit 1
    fi
    send_notification
    ;;
  down)
    # decrease the backlight by 5%
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    send_notification
    ;;
esac
