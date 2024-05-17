#!/bin/bash

# Function to get the battery status using acpi
get_battery_status() {
    acpi | awk '{print $3}' | tr -d ',' | sed 's/Discharging/Dying/'
}

# Function to get the battery percentage using acpi
get_battery_percentage() {
    acpi | awk '{print $4}' | tr -d ','
}

# Function to get the current time
get_current_time() {
    date '+%I:%M %p'
}

# Function to check if battery is charging
is_charging() {
    acpi | grep -qi "Charging"
}

# Function to check if audio is muted using pactl
is_muted() {
    pactl list sinks | awk '/Mute:/{print $2}' | grep -q "yes"
}

# Function to toggle mute/unmute audio using pactl
toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

# Define font path
font_path="/home/dmoz/.fonts/Iosevka Term Nerd Font Complete.ttf"

while true; do
    # Get the current time and battery information
    current_time=$(get_current_time)
    battery_status=$(get_battery_status)
    battery_percentage=$(get_battery_percentage)

    # Construct the output string with battery level and charging status on the right side, date and time in the middle, and audio level and mute indicator on the left side
    output="%{l} $(date '+%A %d %B') | Time: $current_time %{c}"

    if is_charging; then
        output+=" %{r} $battery_status $battery_percentage% "
    else
        output+=" %{r} $battery_status: $battery_percentage%"
    fi

    echo "$output"
    sleep 1
done | lemonbar -p -f "$font_path:size=10" -B "#00000000" -F "#FFFFFF" -g 1366x24+0+0 | while read -r line; do
    case "$line" in
        *"%{A:toggle_mute:}"*)
            toggle_mute
            ;;
        *"%{A}"*)
            scroll_direction="${line#*"%{A}"}"
            case "$scroll_direction" in
                "4")
                    adjust_volume "up"
                    ;;
                "5")
                    adjust_volume "down"
                    ;;
            esac
            ;;
    esac
done
