#!/bin/bash
pkill waybar
waybar > ~/.cache/waybar.log 2>&1 &
