#!/bin/zsh

set -euo pipefail

# Shortcut to switch audio output
switch() {
    /opt/homebrew/bin/SwitchAudioSource "$@"
}

# Utility function to show a notification
notify() {
    osascript -e "display notification \"$1\" with title \"Audio Source\""
}

# Get current audio output
current_output=$(switch -c)
available_devices=$(switch -a)

# Toggle audio output between HDMI (ZQE-CAA) and analog (USB AUDIO  CODEC)
if [[ $current_output == "ZQE-CAA" ]]; then
    if echo "$available_devices" | grep -q "Baddies"; then
        switch -s "Baddies" &> /dev/null
        notify "Switched to Earbuds"
    elif echo "$available_devices" | grep -q "Meloetta"; then
        switch -s "Meloetta" &> /dev/null
        notify "Switched to Wireless Headphones"
    else
        switch -s "USB AUDIO  CODEC" &> /dev/null
        notify "Switched to Headphones"
    fi
else
    switch -s "ZQE-CAA" &> /dev/null
    notify "Switched to Screen"
fi
