#!/bin/bash

MODE_FILE="/tmp/power_profile_mode"
[[ ! -f "$MODE_FILE" ]] && echo "0" > "$MODE_FILE"

INDEX=$(<"$MODE_FILE")

WATTAGE_TOGGLE=false

PROFILE_OPTIONS=("balanced" "power-saver" "performance")

if [[ "$1"  == "wattage" ]]; then
    WATTAGE_TOGGLE=true
elif [[ "$1" == "toggle" ]]; then
    INDEX=$(( ("$INDEX" + 1) % ${#PROFILE_OPTIONS[@]} ))
    powerprofilesctl set "${PROFILE_OPTIONS[$INDEX]}"
    echo "$INDEX" > "$MODE_FILE"
    exit 0 
fi

BATTERY=$(upower -i "$(upower -e | grep BAT)")
PROFILE=$(powerprofilesctl get)
WATTAGE=""

PROFILE_ICONS=("" "" "" "?")
ICON="${PROFILE_ICONS[3]}"
for i in "${!PROFILE_OPTIONS[@]}"; do
    if [[ "$PROFILE" == "${PROFILE_OPTIONS[$i]}" ]]; then
        ICON="${PROFILE_ICONS[$i]}"
        break
    fi
done

MAIN_OUTPUT="$ICON"
TOOLTIP_OUTPUT="Currrent Profile: $PROFILE"

if $WATTAGE_TOGGLE; then
    WATTAGE=$(echo "$BATTERY" | awk '/energy-rate:/ {print $2, $3}' | tr -d ' W')
    ROUNDED_WATTAGE=$(printf %.0f $(echo "$WATTAGE" | bc -l))
    MAIN_OUTPUT="$MAIN_OUTPUT $ROUNDED_WATTAGE W"
    TOOLTIP_OUTPUT="$TOOLTIP_OUTPUT\nWattage: $WATTAGE W"
fi

echo "{\"text\": \" $MAIN_OUTPUT \", \"tooltip\": \"$TOOLTIP_OUTPUT\"}"
