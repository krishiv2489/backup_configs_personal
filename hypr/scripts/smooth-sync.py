#!/usr/bin/env python3

import json
import time
import sys
import os
from openrgb import OpenRGBClient
from openrgb.utils import RGBColor

# 1. Load your Quickshell colors
JSON_FILE = os.path.expanduser("~/.config/hypr/scripts/quickshell/qs_colors.json")

try:
    with open(JSON_FILE, 'r') as f:
        colors_data = json.load(f)
except Exception as e:
    print(f"Error loading JSON: {e}")
    sys.exit(1)

# 2. Extract only the vibrant accent colors
keys = ["blue", "sapphire", "peach", "green", "red", "mauve", "pink", "yellow", "maroon", "teal"]
hex_colors = [colors_data.get(k) for k in keys if colors_data.get(k)]

if not hex_colors:
    print("No vibrant colors found in JSON.")
    sys.exit(1)

# 3. Helper function to convert Hex string (#FF0000) to RGB tuple (255, 0, 0)
def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

rgb_colors = [hex_to_rgb(h) for h in hex_colors]

# 4. Connect to OpenRGB SDK
try:
    client = OpenRGBClient()
    mouse = client.get_devices_by_type("Mouse")[0]
except Exception as e:
    print("Could not connect to OpenRGB SDK. Make sure the SDK server is running in the OpenRGB GUI.")
    sys.exit(1)

# 5. The Crossfade Engine
def crossfade(color_a, color_b, steps=60, frame_delay=0.016):
    r1, g1, b1 = color_a
    r2, g2, b2 = color_b
    
    for i in range(steps + 1):
        # Calculate the intermediate color for this specific frame
        r = int(r1 + (r2 - r1) * (i / steps))
        g = int(g1 + (g2 - g1) * (i / steps))
        b = int(b1 + (b2 - b1) * (i / steps))
        
        # Push to mouse
        mouse.set_color(RGBColor(r, g, b))
        time.sleep(frame_delay)

# 6. Infinite Loop
print("Starting smooth color cycle. Press Ctrl+C to stop.")
try:
    current_index = 0
    while True:
        next_index = (current_index + 1) % len(rgb_colors)
        
        color_start = rgb_colors[current_index]
        color_end = rgb_colors[next_index]
        
        # Crossfade over ~1 second (60 steps * 0.016s)
        crossfade(color_start, color_end, steps=60, frame_delay=0.016)
        
        # Hold the color for 4 seconds before moving to the next
        time.sleep(4)
        
        current_index = next_index
except KeyboardInterrupt:
    print("\nExiting smooth sync.")
