#!/bin/sh

# Check the current mute status of the first sink
current_device=$(pacmd list-sinks | grep "*" | awk '{print $NF}')

state=$(pacmd list-sinks |  grep -A 11 "index: $current_device" | grep "muted" | awk '{print $NF}')

pactl set-sink-mute $current_device 0
# If the mute status is "yes", unmute the volume
if [ "$state" = "yes" ]; then
  pactl set-sink-mute $current_device 0

# If the mute status is "no", mute the volume
else
  pactl set-sink-mute $current_device 1
fi
