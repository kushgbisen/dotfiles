#!/usr/bin/env bash

# Configuration
ROFI_OPTIONS=(-theme ~/.config/rofi/wifi.rasi -dmenu -i -p "Wi-Fi")
ICON_CONNECTED="󰖩"
ICON_DISCONNECTED="󰖪"
ICON_SECURE=""
ICON_OPEN=""

# Get WiFi status and list
wifi_status=$(nmcli radio wifi)
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed -E "s/WPA*.?\S/$ICON_SECURE /;s/^--/$ICON_OPEN /;/--/d")

# Build menu options
if [[ "$wifi_status" == "enabled" ]]; then
    menu="$ICON_DISCONNECTED Disable Wi-Fi\n$wifi_list"
else
    menu="$ICON_CONNECTED Enable Wi-Fi"
fi

# Show Rofi menu
chosen=$(echo -e "$menu" | rofi "${ROFI_OPTIONS[@]}")

# Handle selection
case "$chosen" in
    "$ICON_DISCONNECTED"*)
        nmcli radio wifi off
        notify-send "Wi-Fi Disabled" "Wi-Fi has been turned off"
        ;;
    "$ICON_CONNECTED"*)
        nmcli radio wifi on
        notify-send "Wi-Fi Enabled" "Wi-Fi has been turned on"
        ;;
    *)
        if [ -n "$chosen" ]; then
            ssid=${chosen:3}
            if nmcli -g NAME connection | grep -qxF "$ssid"; then
                nmcli connection up "$ssid" && \
                notify-send "Connected" "You are now connected to $ssid"
            else
                password=$(rofi "${ROFI_OPTIONS[@]}" -password -p "Password for $ssid")
                [ -n "$password" ] && \
                nmcli device wifi connect "$ssid" password "$password" && \
                notify-send "Connected" "You are now connected to $ssid"
            fi
        fi
        ;;
esac
