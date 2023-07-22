#!/bin/bash

# Function to get the battery level using acpi
get_battery_level() {
    acpi | awk '{ print $4 }' | tr -d ','
}

# Function to get the current time
get_current_time() {
    date '+%I:%M %p'
}

# Function to check if battery is charging
is_charging() {
    acpi | grep -qi "charging"
}

# Function to check if audio is muted using pacmd
is_muted() {
    pactl list sinks | awk '/Mute:/{print $2}' | grep -q "yes"
}

# Function to toggle mute/unmute audio using pactl
toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

# Function to adjust audio volume using pavucontrol
adjust_volume() {
    if [ "$1" == "up" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    elif [ "$1" == "down" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ -5%
    fi
}

# Define font path
font_path="/home/dmoz/.fonts/Iosevka Term Nerd Font Complete.ttf"

while true; do
    # Get the current time and battery information
    current_time=$(get_current_time)
    battery_level=$(get_battery_level)

    # Construct the output string with date and time on the left side, battery level and charging status in the middle, audio level and mute indicator on the right side
    output="%{l} $(date '+%A %d %B') | Time: $current_time %{c}"

    if is_charging; then
        output+=" | "
    fi

    output+="Battery: $battery_level% %{r}"

    if is_muted; then
        output+="Muted"
    else
        output+="Volume: $(pactl list sinks | awk '/Volume: front/{print $5}' | grep -oE '[0-9]+')%"
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



