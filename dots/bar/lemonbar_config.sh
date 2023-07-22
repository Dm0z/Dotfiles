#!/bin/bash

# Function to get the current audio level
get_audio_level() {
    amixer get Master | grep -oE '[0-9]+%' | head -1
}

# Function to check if audio is muted
is_muted() {
    amixer get Master | grep -q '\[off\]'
}

# Function to toggle mute/unmute audio using pavucontrol
toggle_mute() {
    pacmd set-sink-mute @DEFAULT_SINK@ toggle
}

# Function to adjust audio volume using pavucontrol
adjust_volume() {
    if [ "$1" == "up" ]; then
        pacmd set-sink-volume @DEFAULT_SINK@ +5%
    elif [ "$1" == "down" ]; then
        pacmd set-sink-volume @DEFAULT_SINK@ -5%
    fi
}

# Function to get the battery level
get_battery_level() {
    acpi | awk '{ print $4 }' | tr -d ','
}

# Define font path
font_path="/home/dmoz/.fonts/Iosevka Term Nerd Font Complete.ttf"

while true; do
    # Get the current time in the desired format
    current_time=$(date '+%I:%M %p')

    # Construct the output string with date and time on the left side, battery level in the middle, audio level and mute indicator on the right side
    output="%{l}Date: $(date '+%A %d %B') | Time: $current_time %{c}Battery: $(get_battery_level) %{r}"

    if is_muted; then
        output+="Muted"
    else
        output+="Volume: $(get_audio_level)"
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


