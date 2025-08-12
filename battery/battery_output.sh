#!/bin/bash

MODE_FILE="/tmp/waybar_battery_mode"
[[ ! -f "$MODE_FILE" ]] && echo "percentage" > "$MODE_FILE"

FRAME_FILE="/tmp/waybar_battery_frame"
[[ ! -f "$FRAME_FILE" ]] && echo 0 > "$FRAME_FILE"

FRAME=$(<"$FRAME_FILE")
MODE=$(<"$MODE_FILE")

WATTAGE_TOGGLE=false

if [[ "$1" == "wattage" ]]; then
    WATTAGE_TOGGLE=true
elif [[ "$1" == "toggle" ]]; then
    if [[ "$MODE" == "percentage" ]]; then
        echo "time" > "$MODE_FILE"
    else
        echo "percentage" > "$MODE_FILE"
    fi
    exit 0
fi

BATTERY=$(upower -i "$(upower -e | grep BAT)")

STATE=$(echo "$BATTERY" | awk '/state:/ {print $2}')
PERCENTAGE=$(echo "$BATTERY" | awk '/percentage:/ {print $2}' | tr -d '%')
TIME=$(echo "$BATTERY" | awk '/time to/ {print $4, $5}')
WATTAGE=""

BATTERY_ICONS=("" "" "" "" "")

ICON=""
if [[ "$STATE" == "charging" ]]; then
    ICON="${BATTERY_ICONS[FRAME]}"
    FRAME=$(( (FRAME + 1) % 5 ))
    echo "$FRAME" > "$FRAME_FILE"
elif [[ "$STATE" == "fully-charged" ]]; then
    ICON="${BATTERY_ICONS[4]}"
elif [[ "$STATE" == "discharging" ]]; then
    if (( PERCENTAGE >= 75 )); then
        ICON="${BATTERY_ICONS[3]}"
    elif (( PERCENTAGE >= 50 )); then
        ICON="${BATTERY_ICONS[2]}"
    elif (( PERCENTAGE >= 25 )); then
        ICON="${BATTERY_ICONS[1]}"
    else
        ICON="${BATTERY_ICONS[0]}"
    fi
else
    ICON="?"
fi

MAIN_OUTPUT=""
TOOLTIP_OUTPUT=""
if [[ "$MODE" == "time" ]]; then
    if [[ -z "$TIME" ]]; then
        MAIN_OUTPUT="$ICON $PERCENTAGE%"
        TOOLTIP_OUTPUT="$TIME"
    else
        MAIN_OUTPUT="$ICON $TIME"
        TOOLTIP_OUTPUT="$PERCENTAGE%"
    fi
else
    MAIN_OUTPUT="$ICON $PERCENTAGE%"
    TOOLTIP_OUTPUT="$TIME"
fi

if $WATTAGE_TOGGLE; then
    WATTAGE=$(echo "$BATTERY" | awk '/energy-rate:/ {print $2, $3}')
    TOOLTIP_OUTPUT="$TOOLTIP_OUTPUT\n$WATTAGE"
fi

echo "{\"text\": \"$MAIN_OUTPUT\", \"tooltip\": \"$TOOLTIP_OUTPUT\"}"

