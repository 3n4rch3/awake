#!/bin/bash


Sec=120 ##Seconds between moves.


## Check if user is root:
if [ "$EUID" -ne 0 ]
  then echo -e "\nRun as root, you'll be happier.\n"
  exit
fi

## Check 'ydotool' dependency:
if ! command -v ydotool &> /dev/null
then
    echo -e "\n'ydotool' is not installed, please do that first!\n"
    exit 1
fi


## Move the mouse one pixel every Nmin to keep the screen awake,
## as long as Battery is more than 12% charge.
##
echo -e "\n## Move the mouse one pixel every ${Sec} seconds to keep the screen\n## awake, as long as Battery is more than 12% charge.\n"
batt=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "percentage:" \
  | gawk '{print $2}' | cut -d '%' -f 1 )
echo -e "Battery: $batt%"

## Start background service for 'ydotool':
systemctl start ydotool

## STOP ydotool daemon if we need to exit
## with "Ctrl + C":
trap "{ systemctl stop ydotool; }" EXIT

## Loop every 3 minutes while battery has sufficient charge:
while [ "$batt" -gt 12 ] ; do 
        sleep ${Sec}
        batt=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "percentage:" \
          | gawk '{print $2}' | cut -d '%' -f 1 )
        echo -e "\r\033[1A\033[0KBattery: $batt%"
        ydotool mousemove 1 1 2>/dev/null
done

## Stop ydotool daemon on exit:
systemctl stop ydodool
