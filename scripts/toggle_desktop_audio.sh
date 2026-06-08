#!/usr/bin/env zsh

# 1. Define the names exactly as they appear
DEV1="Blue Microphones Digital Stereo"
DEV2="Starship/Matisse HD Audio Controller Analog Stereo"

# 2. Get clean, decoration-free sink lines from wpctl
# This strips out the tree characters '│' and trims leading whitespace
SINK_LIST=$(wpctl status | grep -A 3 "Sinks:" | tr -d '│' | sed 's/^[ \t]*//')

# 3. Check which device has the active asterisk
ACTIVE_LINE=$(echo "$SINK_LIST" | grep -E "\*\s+[0-9]+")

# 4. Extract the target ID cleanly by targeting only digits
if [[ "$ACTIVE_LINE" =~ "$DEV1" ]]; then
    # Target DEV2: Match the number before the name, ignoring everything else
    TARGET_ID=$(echo "$SINK_LIST" | grep "$DEV2" | grep -oE "[0-9]+" | head -n 1)
else
    # Target DEV1: Match the number before the name, ignoring everything else
    TARGET_ID=$(echo "$SINK_LIST" | grep "$DEV1" | grep -oE "[0-9]+" | head -n 1)
fi

# 5. Fire the switch
if [[ -n "$TARGET_ID" ]]; then
    wpctl set-default "$TARGET_ID"
fi
