# Start other applications
nitrogen --restore &
tint2 &
/home/dmoz/bar/lemonbar_config.sh &
compton &
volumeicon &

# Sleep for a few seconds to allow tint2 to start (adjust as needed)
sleep 2

# Replace <tint2_window_id> with the actual window ID of your tint2 bar.
xdotool windowmove <tint2_window_id> $((($(xwininfo -root | awk '/Width/ {print $2}') - 81) / 2)) 0

