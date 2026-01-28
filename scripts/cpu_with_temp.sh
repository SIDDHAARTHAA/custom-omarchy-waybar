#!/bin/bash
# CPU usage with temperature tooltip

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')

# Get CPU temperature
if [ -f /sys/class/hwmon/hwmon6/temp1_input ]; then
    temp=$(cat /sys/class/hwmon/hwmon6/temp1_input)
    cpu_temp="$((temp / 1000))°C"
elif command -v sensors &> /dev/null; then
    cpu_temp=$(sensors | awk '/Package id 0:|Tdie:|Tctl:|CPU:/ {print $3; exit}' | tr -d '+')
else
    cpu_temp="N/A"
fi

# Output JSON for Waybar
echo "{\"text\":\"󰘚 ${cpu_usage}%\",\"tooltip\":\"CPU Temp: ${cpu_temp}\"}"