#!/bin/bash

JSON_FILE="$HOME/.config/hypr/scripts/quickshell/qs_colors.json"

# Set default mode to static if no argument is provided
MODE=${1:-static}
# Set default static color to 'blue' if no second argument is provided
STATIC_COLOR_KEY=${2:-blue}
# Delay in seconds between color changes in cycle mode
DELAY=5

# Safety measure: Kill any background instances of this script so loops do not overlap
for pid in $(pgrep -f "sync-mouse.sh"); do
    if [ "$pid" != "$$" ]; then
        kill -9 "$pid" 2>/dev/null
    fi
done

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: Could not find $JSON_FILE"
    exit 1
fi

if [ "$MODE" = "static" ]; then
    RAW_HEX=$(jq -r ".$STATIC_COLOR_KEY" "$JSON_FILE")
    
    if [ -n "$RAW_HEX" ] && [ "$RAW_HEX" != "null" ]; then
        CLEAN_HEX="${RAW_HEX//\#/}"
        # > /dev/null 2>&1 completely hides the OpenRGB I2C warnings
        openrgb -c "$CLEAN_HEX" > /dev/null 2>&1
        echo "Mode: Static. Mouse synced to $STATIC_COLOR_KEY ($CLEAN_HEX)."
    else
        echo "Color $STATIC_COLOR_KEY not found in JSON."
    fi

elif [ "$MODE" = "cycle" ]; then
    echo "Mode: Cycle. Syncing to Matugen accent colors every $DELAY seconds..."
    
    # Extract only the vibrant accents. This ignores backgrounds like crust, mantle, and surface.
    COLORS=$(jq -r '.blue, .sapphire, .peach, .green, .red, .mauve, .pink, .yellow, .maroon, .teal' "$JSON_FILE" | grep -v 'null')

    while true; do
        for RAW_HEX in $COLORS; do
            CLEAN_HEX="${RAW_HEX//\#/}"
            openrgb -c "$CLEAN_HEX" > /dev/null 2>&1
            sleep "$DELAY"
        done
    done

else
    echo "Invalid mode. Use 'static' or 'cycle'."
fi
