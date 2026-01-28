#!/bin/bash
# Combined dGPU, iGPU, CPU, and Memory usage with temperatures

# Get CPU usage and temp
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')
if [ -f /sys/class/hwmon/hwmon6/temp1_input ]; then
    temp=$(cat /sys/class/hwmon/hwmon6/temp1_input)
    cpu_temp="$((temp / 1000))°C"
elif command -v sensors &> /dev/null; then
    cpu_temp=$(sensors 2>/dev/null | awk '/Package id 0:|Tdie:|Tctl:|CPU:/ {print $3; exit}' | tr -d '+')
else
    cpu_temp="N/A"
fi

# Get Memory usage - percentage and actual
mem_data=$(free -m | awk 'NR==2{used=$3; total=$2; percent=int(used*100/total); printf "%d %.1f %.1f", percent, used/1024, total/1024}')
mem_percent=$(echo "$mem_data" | awk '{print $1}')
mem_used=$(echo "$mem_data" | awk '{print $2}')
mem_total=$(echo "$mem_data" | awk '{print $3}')

# Get AMD GPU usage and temp
amd_usage=$(radeontop -d - -l 1 2>/dev/null | awk '/gpu/ {gsub("%","",$5); printf "%.0f", $5; exit}')
amd_usage=${amd_usage:-0}
if [ -f /sys/class/hwmon/hwmon5/temp1_input ]; then
    temp=$(cat /sys/class/hwmon/hwmon5/temp1_input)
    amd_temp="$((temp / 1000))°C"
else
    amd_temp="N/A"
fi

# Get NVIDIA GPU usage and temp
nvidia_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
nvidia_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
nvidia_usage=${nvidia_usage:-0}
if [ -n "$nvidia_temp" ]; then
    nvidia_temp="${nvidia_temp}°C"
else
    nvidia_temp="N/A"
fi

# Build tooltip
tooltip="dGPU: ${nvidia_usage}% | ${nvidia_temp}\\niGPU: ${amd_usage}% | ${amd_temp}\\nCPU: ${cpu_usage}% | ${cpu_temp}\\nRAM: ${mem_used}G/${mem_total}G (${mem_percent}%)"

# Output JSON - memory as percentage
echo "{\"text\":\"󰾲 ${nvidia_usage}% 󰢮 ${amd_usage}% 󰘚 ${cpu_usage}% 󰍛 ${mem_percent}%\",\"tooltip\":\"${tooltip}\"}"