#!/bin/sh

# Check the current mute status of the default device
current_device=$(pacmd list-sinks | grep "*" | awk '{print $NF}')

state=$(pacmd list-sinks |  grep -A 11 "index: $current_device" | grep "muted" | awk '{print $NF}')

# Icons
icon_mute="/usr/share/icons/Papirus-Dark/16x16/panel/audio-off.svg"
icon_unmute="/usr/share/icons/Papirus-Dark/16x16/panel/audio-on.svg"

# Get current volume
function get_volume {
	volume_value=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n 1 | tr -d '%')
	printf "%.0f\n" $volume_value
}

# Create bar
volume=$(get_volume)
bar=$(seq -s "─" 0 $((volume / 5)) | sed 's/[0-9]//g')
pactl set-sink-mute @DEFAULT_SINK@ toggle

# If the mute status is "yes", unmute the volume
if [ "$state" = "yes" ]; then
  dunstify -i "$icon_unmute" -r 5555 -u normal "$volume $bar"
# If the mute status is "no", mute the volume
else
  dunstify -i "$icon_mute" -r 5555 -u normal "$volume $bar"
fi
