#!/bin/bash

CALENDAR_TOGGLE=false
TWELVE_HOUR=false

for i in $@;do
    case i in
    fulltime)
        TWELVE_HOUR=true
        ;;
    calendar)  
        CALENDAR_TOGGLE=true
        ;;
    esac
done

INFO=$(date)

TIME=$(echo "$INFO" | awk '{print $4}')
DATE=$(echo "$INFO" | awk '{print $2, $3, $7}')

MAIN_OUTPUT="$TIME $DATE"
TOOLTIP_OUTPUT=""
echo "{\"text\": \"$MAIN_OUTPUT\", \"tooltip\": \"$TOOLTIP_OUTPUT\"}"
