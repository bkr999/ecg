#!/bin/bash

WATCHDOG_FILE=/home/pi/ecg1/watchdog.list
THISSCRIPT=$(readlink -f $0)

echo "Watchdog"
echo "================================="
echo "To install, edit 'sudo nano /etc/crontab' and add '* * * * * root $THISSCRIPT'"
echo ""
echo "Arguments:"
echo "$THISSCRIPT <-file:listfile> <-display>"
echo ""
echo "-file.   : different list file"
echo "-display : echo output to console"
echo ""

DISPLAY_ECHO=0
while [[$# -gt 1]]
	do
	key="$1"

	case $key in
	-display)
		DISPLAY_ECHO=1
	;;
	-file)
		WATCHDOG_FILE=`echo $key | cut -d':' -f 2
	;;
	*)	
	;;
esac




while read WATCHDOG_PROCESS; do
	if [[ "$WATCHDOG_PROCESS" != "#"* ]];then
		# String no comment

		if [[ $WATCHDOG_PROCESS == -* ]]; then
			WATCHDOG_KILL=`echo -n "$WATCHDOG_PROCESS" | tail -c +2 | sed -e 's/^[[:space:]]*//'`
			[[ $DISPLAY_ECHO == 1]] && echo -n "Beende Prozess '$WATCHDOG_KILL'..."
			sudo pkill -f $WATCHDOG_KILL
			[[ $DISPLAY_ECHO == 1]] && echo "OK"
		else
			if [[ !  -z  $WATCHDOG_PROCESS  ]]; then
			    	[[ $DISPLAY_ECHO == 1]] && echo -n "Prüfe Prozess '$WATCHDOG_PROCESS'..."
				COUNT=`ps -ef | grep "$WATCHDOG_PROCESS" | grep -v "grep" | wc -l`
				if [ $COUNT -eq 0 ]; then
					[[ $DISPLAY_ECHO == 1]] && echo "nicht gefunden!"
					$($WATCHDOG_PROCESS) &
				else
					[[ $DISPLAY_ECHO == 1]] && echo "gefunden. OK"
				fi
			fi
		fi
	fi
done < $WATCHDOG_FILE