#!/bin/bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle

# Check the current mute status of the first sink
#mute_status=$(pactl list sinks | grep 'Mute:' | awk '{print $2}' | head -n 1)
#
## If the mute status is "yes", unmute the volume
#if [ "$mute_status" = "yes" ]; then
#  pactl set-sink-mute 0 0;pactl set-sink-mute 1 0
#
## If the mute status is "no", mute the volume
#else
#  pactl set-sink-mute 0 1;pactl set-sink-mute 1 1
#fi
#
