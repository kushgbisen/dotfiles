#!/bin/bash

# Path for the temporary screenshot
SCREENSHOT_PATH="/tmp/swaylock_screenshot.png"

# Get the name of the focused output
FOCUSED_OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')

# Take a screenshot of the focused output
grim -o "$FOCUSED_OUTPUT" "$SCREENSHOT_PATH"

# Lock the screen using the screenshot with pixelation
swaylock \
    --daemonize \
    --image "$SCREENSHOT_PATH" \
    --scaling fill \
    --effect-pixelate 12 \
    --font "FiraCode Nerd Font" \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --ring-color "d65d0ecc" \
    --key-hl-color "ebdbb2ff" \
    --text-color "ebdbb2ff" \
    --inside-color "1a1a1aa0" \
    --separator-color "00000000" \
    --grace 1 \
    --fade-in 0.3 \
    --ring-ver-color "b8bb26ff" \
    --inside-ver-color "1a1a1aa0" \
    --ring-wrong-color "cc241dff" \
    --inside-wrong-color "1a1a1aa0" \
    --bs-hl-color "d65d0eff" \
    --datestr "%a, %b %d" \
    --timestr "%I:%M %p" \
    --clock

# Optional: Remove the screenshot after locking (uncomment if desired)
# rm "$SCREENSHOT_PATH"
