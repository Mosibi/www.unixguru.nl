#!/bin/sh

#######################################################
#
# A little ACPI script written by Richard Arends
# for his own laptop. This script poll's every
# 30 seconds the current battery state and
# take's action when the battery is low
# and NOT on AC.
#
#######################################################

while true; do
	LIFE=`/sbin/sysctl hw.acpi.battery.life|cut -d ' ' -f 2`
	AC=`/sbin/sysctl hw.acpi.acline|cut -d ' ' -f 2`

	echo "`date`	-	${LIFE}" >> /var/tmp/acpid.txt

	if [ "${LIFE}" -le "5" ] && [ "${AC}" = "0" ]; then
		LAST=`tail -2 /var/tmp/acpid.txt |cut -d '-' -f 2|head -1`
		DIFF=`expr "${LAST}" - "${LIFE}"`

		if [ "${DIFF}" -gt "10" ]; then
			# On the next check, we will suspend.
			/usr/bin/logger -p user.emerg "battery status critical!"
			echo T250L16B+BA+AG+GF+FED+DC+CC >/dev/speaker		
		else
			echo T250L16B+BA+AG+GF+FED+DC+CC >/dev/speaker		
			echo AA >/dev/speaker		
			echo AA >/dev/speaker		
			/usr/bin/logger -p user.emerg "battery low - emergency suspend"
			/usr/sbin/acpiconf -e
			/usr/sbin/acpiconf -s 3

			if [ -f /etc/nobeep ]; then
				rm /etc/nobeep
			fi
		fi

	elif [ "${LIFE}" -le "10" ] && [ "${AC}" = "0" ] && [ ! -f /etc/nobeep ]; then
		/usr/bin/logger -p user.emerg "battery status critical!"
		echo T250L16B+BA+AG+GF+FED+DC+CC >/dev/speaker		
	fi

	sleep 30
done
