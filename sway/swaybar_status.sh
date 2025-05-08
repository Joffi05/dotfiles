#!/bin/bash

# Ensure consistent decimal separators
export LC_ALL=C

# Configuration
BATTERY_CAPACITY_PATH="/sys/class/power_supply/BAT1/capacity"
BATTERY_STATUS_PATH="/sys/class/power_supply/BAT1/status"
PING_TARGET="google.com"
PING_COUNT=1
WIFI_INTERFACE="wlp4s0"  # Replace with your actual Wi-Fi interface name
UPDATE_INTERVAL=0.5  # Update interval in seconds
MIN_WIDTH=100

# Function to get Battery Status
get_battery() {
    if [ -f "$BATTERY_CAPACITY_PATH" ] && [ -f "$BATTERY_STATUS_PATH" ]; then
        capacity=$(cat "$BATTERY_CAPACITY_PATH")
        status=$(cat "$BATTERY_STATUS_PATH")
        if ["$status" = "Full" ]; then
		icon="󰁹"

	elif [ "$status" = "Charging" ]; then
	    if [ "$capacity" -le 10 ]; then
	        icon="󰢜"
	    elif [ "$capacity" -le 20 ]; then
	        icon="󰂆"
	    elif [ "$capacity" -le 30 ]; then
	        icon="󰂇"
	    elif [ "$capacity" -le 40 ]; then
	        icon="󰂈"
	    elif [ "$capacity" -le 50 ]; then
	        icon="󰢝"
	    elif [ "$capacity" -le 60 ]; then
	        icon="󰂉"
	    elif [ "$capacity" -le 70 ]; then
	        icon="󰢞"
	    elif [ "$capacity" -le 80 ]; then
	        icon="󰂊"
	    elif [ "$capacity" -le 90 ]; then
	        icon="󰂋"
	    elif [ "$capacity" -le 100 ]; then
	        icon="󰂅"
	    fi
        else
	    if [ "$capacity" -le 10 ]; then
	        icon="󰂎"
	    elif [ "$capacity" -le 20 ]; then
	        icon="󰁺"
	    elif [ "$capacity" -le 30 ]; then
	        icon="󰁻"
	    elif [ "$capacity" -le 40 ]; then
	        icon="󰁼"
	    elif [ "$capacity" -le 50 ]; then
	        icon="󰁽"
	    elif [ "$capacity" -le 60 ]; then
	        icon="󰁾"
	    elif [ "$capacity" -le 70 ]; then
	        icon="󰁿"
	    elif [ "$capacity" -le 80 ]; then
	        icon="󰂀"
	    elif [ "$capacity" -le 90 ]; then
	        icon="󰂁"
	    elif [ "$capacity" -le 100 ]; then
	        icon="󰂂"
	    fi
        fi
        echo "{\"name\": \"battery\", \"full_text\": \"$icon $capacity%\", \"color\": \"$color\", \"min_width\": \"$MIN_WIDTH\"}"
    fi
}

# Function to get Wi-Fi Signal Strength
get_wifi() {
    # Check if Wi-Fi interface is connected
    if iw dev "$WIFI_INTERFACE" link >/dev/null 2>&1; then
        ssid=$(iw dev "$WIFI_INTERFACE" link | grep "SSID" | awk '{print $2}')
        signal_level=$(iw dev "$WIFI_INTERFACE" link | grep "signal" | awk '{print $2}')
        
        # Convert signal level from dBm to percentage
        if [[ "$signal_level" =~ ^-?[0-9]+$ ]]; then
            signal_dbm=$signal_level
            if [ "$signal_dbm" -le -100 ]; then
                signal_percent=0
            elif [ "$signal_dbm" -ge -30 ]; then
                signal_percent=100
            else
                # Linear interpolation: (-100 to -30 dBm) maps to (0% to 100%)
                signal_percent=$(awk "BEGIN {printf \"%d\", ($signal_dbm + 100) * 100 / 70}")
            fi
        else
            signal_percent=0
        fi

        # Determine color based on signal strength
        if [ "$signal_percent" -le 30 ]; then
            color="#FF0000"  # Red
        elif [ "$signal_percent" -le 70 ]; then
            color="#FFFF00"  # Yellow
        else
            color="#00FF00"  # Green
        fi

        echo "{\"name\": \"wifi\", \"full_text\": \"󰖩  $ssid ($signal_percent%)\", \"color\": \"$color\", \"min_width\": \"$MIN_WIDTH\"}"

    else
        echo "{\"name\": \"wifi\", \"full_text\": \"󰖪  Disconnected\", \"color\": \"#FF0000\", \"min_width\": \"$MIN_WIDTH\"}"

    fi
}

# Function to get Ping Time
get_ping() {
    ping_output=$(ping -c "$PING_COUNT" "$PING_TARGET" 2>/dev/null)
    if echo "$ping_output" | grep -q 'time='; then
        ping_time=$(echo "$ping_output" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
        echo "{\"name\": \"ping\", \"full_text\": \" $ping_time ms\", \"color\": \"#00FFFF\", \"min_width\": \"$MIN_WIDTH\"}"

    else
        echo "{\"name\": \"ping\", \"full_text\": \" N/A\", \"color\": \"#FF0000\", \"min_width\": \"$MIN_WIDTH\"}"

    fi
}

# Function to get CPU Usage
get_cpu() {
    # Using top in batch mode to get CPU usage
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    # Replace comma with dot, if any
    cpu_idle=$(echo "$cpu_idle" | tr ',' '.')
    # Calculate CPU usage
    cpu_usage=$(awk "BEGIN {printf \"%.1f\", 100 - $cpu_idle}")
    echo "{\"name\": \"cpu\", \"full_text\": \" CPU: $cpu_usage%\", \"color\": \"#FFD700\", \"min_width\": \"$MIN_WIDTH\"}"

}

# Function to get RAM Usage
get_ram() {
    ram_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    ram_available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    ram_used_kb=$((ram_total_kb - ram_available_kb))
    ram_total_mb=$(awk "BEGIN {printf \"%.0f\", $ram_total_kb / 1024}")
    ram_used_mb=$(awk "BEGIN {printf \"%.0f\", $ram_used_kb / 1024}")
    echo "{\"name\": \"ram\", \"full_text\": \"RAM: ${ram_used_mb}MB/${ram_total_mb}MB\", \"color\": \"#00CED1\", \"min_width\": \"$MIN_WIDTH\"}"

}

# Function to get Date and Time
get_datetime() {
    datetime=$(date '+%Y-%m-%d %H:%M:%S')
    echo "{\"name\": \"datetime\", \"full_text\": \"$datetime\", \"color\": \"#ADFF2F\", \"min_width\": \"$MIN_WIDTH\"}"

}

# Function to send blocks following swaybar-protocol
send_blocks() {
    # Collect all block JSON objects
    battery=$(get_battery)
    wifi=$(get_wifi)
    ping=$(get_ping)
    cpu=$(get_cpu)
    ram=$(get_ram)
    datetime=$(get_datetime)

    # Combine blocks into an array
    blocks=("$battery" "$wifi" "$ping" "$cpu" "$ram" "$datetime")

    # Join blocks with commas and wrap in [ ]
    IFS=, ; echo "[${blocks[*]}],"
}

# Initial output as required by swaybar-protocol
echo "{\"version\":1}"
echo "["
# Continuously update the status
while true; do
    send_blocks
    sleep "$UPDATE_INTERVAL"
done

