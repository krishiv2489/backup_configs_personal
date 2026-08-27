#!/bin/bash

# This script takes a wallpaper path as an argument.
# Usage: ./set-theme.sh /path/to/wallpaper.jpg
WALLPAPER=$1

if [ -z "$WALLPAPER" ]; then
    echo "Please provide a wallpaper path!"
    exit 1
fi

# 1. Set the Wallpaper
# (If you use hyprpaper or swaybg instead of awww, change this line)
awww img "$WALLPAPER" --transition-type any

# 2. Run Matugen to generate new system colors
matugen image "$WALLPAPER"

# 3. Reload Waybar so it instantly applies the new colors
killall -SIGUSR2 waybar

# 4. Extract the color and sync the mouse!
# We will search your Waybar CSS file for the primary color.
# Change this path to wherever Matugen saves your Waybar CSS file:
CSS_FILE="$HOME/.config/waybar/colors.css"

if [ -f "$CSS_FILE" ]; then
    # Grep searches for the line defining 'primary', then extracts just the #HEX code
    RAW_HEX=$(grep -m 1 "define-color primary" "$CSS_FILE" | grep -oP '#[0-9a-fA-F]{6}')
    
    if [ -n "$RAW_HEX" ]; then
        # Strip the '#' symbol and send to OpenRGB
        CLEAN_HEX="${RAW_HEX//\#/}"
        openrgb -c "$CLEAN_HEX"
    else
        echo "Could not find a hex color in $CSS_FILE"
    fi
else
    echo "Could not find $CSS_FILE"
fi
