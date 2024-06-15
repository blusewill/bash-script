#!/bin/bash

# Get the name of your hardware sink (usually something like 'alsa_output.pci-0000_00_1b.0.analog-stereo')
hardware_sink=$(pactl list short sinks | grep -m 1 'alsa_output' | cut -f2)

# Define the file to save module IDs

MODULE_FILE="/tmp/pulseaudio_modules.txt"

# Function to unload modules
unload_modules() {
    if [ -f "$MODULE_FILE" ]; then
        while IFS= read -r module_id; do
            pactl unload-module "$module_id"
        done < "$MODULE_FILE"
        rm "$MODULE_FILE"
    fi
}

# Unload existing modules
if test -f $MODULE_FILE; then
    pactl set-default-sink $hardware_sink
    sleep 0.1
    unload_modules
    echo "Virtual Audio Track is down."
    exit 1 
fi
# Load null sinks and save their module IDs
module_id_music=$(pactl load-module module-null-sink sink_name=Music sink_properties=device.description="Music")
module_id_audio=$(pactl load-module module-null-sink sink_name=Audio sink_properties=device.description="Audio")
module_id_games=$(pactl load-module module-null-sink sink_name=Games sink_properties=device.description="Games")

# Load loopbacks and save their module IDs
module_id_loopback_music=$(pactl load-module module-loopback source=Music.monitor sink=$hardware_sink)
module_id_loopback_audio=$(pactl load-module module-loopback source=Audio.monitor sink=$hardware_sink)
module_id_loopback_games=$(pactl load-module module-loopback source=Games.monitor sink=$hardware_sink)

# Save all module IDs to the file
echo "$module_id_music" > "$MODULE_FILE"
echo "$module_id_audio" >> "$MODULE_FILE"
echo "$module_id_games" >> "$MODULE_FILE"
echo "$module_id_loopback_music" >> "$MODULE_FILE"
echo "$module_id_loopback_audio" >> "$MODULE_FILE"
echo "$module_id_loopback_games" >> "$MODULE_FILE"

# Set the Default Computer Audio to Audio (This Note Sucks lol)
pactl set-default-sink Audio

echo "Virtual Audio Track is up!"
