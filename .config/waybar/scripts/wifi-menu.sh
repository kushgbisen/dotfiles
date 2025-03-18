#!/bin/bash

# Choose between rofi or wofi
MENU_CMD="rofi -dmenu -p WiFi -theme ~/.config/rofi/wifi.rasi"
# Uncomment for wofi:
# MENU_CMD="wofi --dmenu --prompt 'WiFi' --style ~/.config/wofi/style.css"

selected=$(nmcli -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list | \
    sed -e 's/IN-USE//' | \
    awk '! /^--/ {print}' | \
    sed -e 's/^*//' -e 's/ *$//' | \
    $MENU_CMD | \
    awk '{print $2}')

if [ -n "$selected" ]; then
    if nmcli -g GENERAL.STATE dev show wlp3s0 | grep -q "connected"; then
        nmcli con down id "$selected"
    else
        if nmcli -g 802-11-wireless-security.psk dev wifi list | grep -q "WPA2"; then
            password=$(rofi -dmenu -password -p "Password for $selected" -theme ~/.config/rofi/wifi.rasi)
        fi
        nmcli dev wifi connect "$selected" password "$password"
    fi
fi
