#!/bin/bash
# NVIDIA GPU usage with temperature tooltip for Waybar

# Get GPU usage and temperature
usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

if [ -n "$usage" ] && [ -n "$temp" ]; then
    echo "{\"text\":\"󰾲 ${usage}%\",\"tooltip\":\"dGPU Temp: ${temp}°C\"}"
else
    echo "{\"text\":\"󰾲 N/A\",\"tooltip\":\"NVIDIA GPU not found\"}"
fi