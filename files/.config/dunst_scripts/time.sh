#!/bin/bash

export DISPLAY=:0

current_time=$(date +"%T")
current_date=$(date '+%d.%m.%d')

dunstify -u low -t 3500 $current_date $current_time

