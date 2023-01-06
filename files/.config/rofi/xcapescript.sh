#!/bin/sh
if pgrep -x rofi; then
    killall rofi
else
    sh .config/rofi/launcher
fi
