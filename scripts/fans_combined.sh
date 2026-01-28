#!/bin/bash
# Combined fan display for Waybar - improved sensor detection

# Initialize fan speeds
fan_left=0
fan_right=0

# Try reading from hwmon directly first (most reliable)
fan_count=0
for hwmon in /sys/class/hwmon/hwmon*/fan*_input; do
    if [ -f "$hwmon" ]; then
        speed=$(cat "$hwmon" 2>/dev/null)
        # Only count non-zero speeds
        if [ -n "$speed" ] && [ "$speed" -gt 0 ]; then
            if [ $fan_count -eq 0 ]; then
                fan_left=$speed
                fan_count=1
            elif [ $fan_count -eq 1 ]; then
                fan_right=$speed
                break
            fi
        fi
    fi
done

# If hwmon didn't work, try sensors command
if [ $fan_left -eq 0 ] && [ $fan_right -eq 0 ] && command -v sensors &> /dev/null; then
    fan_data=$(sensors 2>/dev/null | grep -i "fan" | grep -oP '\d+' | grep -v "^0$")
    fan_left=$(echo "$fan_data" | sed -n '1p')
    fan_right=$(echo "$fan_data" | sed -n '2p')
fi

# Ensure we have values
fan_left=${fan_left:-0}
fan_right=${fan_right:-0}

# Output JSON with tooltip
echo "{\"text\":\"󰈐 󰈐\",\"tooltip\":\"Left Fan: ${fan_left} RPM\\nRight Fan: ${fan_right} RPM\"}"