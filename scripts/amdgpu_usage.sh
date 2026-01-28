#!/bin/bash
# AMD GPU usage script for Waybar
radeontop -d - -l 1 2>/dev/null | awk '/gpu/ {
    gsub("%","",$5)
    printf "󰢮 %.0f%%\n", $5
    exit
}'