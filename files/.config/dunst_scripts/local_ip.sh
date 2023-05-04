#!/bin/bash

local_ip=$(ip addr show | grep "inet " | awk '{print $2}')

dunstify -u low -t 3500  "$local_ip"

