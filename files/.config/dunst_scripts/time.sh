#!/bin/bash

export DISPLAY=:0

current_time=$(date +"%T")

dunstify -u low -t 3500  "$current_time"

