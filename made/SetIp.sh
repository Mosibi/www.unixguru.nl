#!/bin/sh

Thuis () {
	IP=192.168.1.2
	NETMASK=255.255.255.0
	GW=192.168.1.1
	DOMAIN=example.com
	NS="192.168.1.1"
	DEV=wi0
	EXTRAOPTS="ssid example.com wepmode on wepkey 0xaaabbbdddd"
	XCONFIG=XF86Config-thuis
}

Werk () {
	IP=192.168.255.55
	NETMASK=255.255.255.0
	GW=192.168.255.1
	DOMAIN=unixguru.nl
	NS=192.168.255.4
	DEV=fxp0
	XCONFIG=XF86Config-werk
}

DHCP () {
	IP="dhcp"
	echo -n "Interface to use for dhcp request: "
	read INT
	DEV=$INT
	killall dhclient
	echo "Performing DHCP setup"
	XCONFIG=XF86Config-thuis
}

SetIp () {
	if [ "$IP" = "dhcp" ]; then
		dhclient $DEV
	else
		check=`netstat -nra | awk '/default/ {print $1}'`
		
		if [ ! -z "$check" ]; then
			route delete default
		fi

		if [ ! "$DEV" = "fxp0" ]; then
			ifconfig $DEV $IP $NETMASK $EXTRAOPTS
			route add default $GW
		else
			ifconfig $DEV $IP $NETMASK media 100baseTX mediaopt full-duplex
#			ifconfig $DEV $IP $NETMASK media 10baseT/UTP
			route add default $GW
		fi

		rm -rf /etc/resolv.conf
		echo "domain $DOMAIN" >> /etc/resolv.conf
		
		for ENTRY in `echo "${NS}"`; do
			echo "nameserver ${ENTRY}" >> /etc/resolv.conf
		done
	fi

	if [ "$XCHOICE" = "YES" ]; then
		cd /etc/X11

        	check=`find . -name XF86Config -type l`

	        if [ ! -z "$check" ]; then
                	rm XF86Config
        	fi

	        ln -s $XCONFIG XF86Config

	fi

	exit
}

CheckIp () {
	CHECK=`ifconfig $DEV | grep broadcast | awk '{print $2}'`
	if [ "$IP" = "$CHECK" ]; then
		echo "   "
		echo "Het lijkt er op dat dit ip-adres al ingesteld staat"
		KEUZE1="0"
		NUM="0"

		while [ ! "$KEUZE1" = "n" ]; do
        	echo -n "Wilt je toch doorgaan? (j/n): "
        	read KEUZE1
        	case $KEUZE1 in
                	[jJ]) # Doorgaan
			SetIp
			exit
                	;;
                	[nN]) # Afsluiten
                	exit
                	;;
			* )   # Verkeerde keuze
			NUM=`echo $NUM|awk '{print $1 + 1}'`
			if [ "$NUM" -gt "1" ]; then
				echo "Je hebt nu al $NUM keer de verkeerde keuze gemaakt"
				echo "Kies nou gewoon j of n!!"
			fi
			;;
        	esac
		done
	fi
}

Menu () {
cat <<EOF
 
               ===============================================
               =                KEUZE MENU                   =
               ===============================================
 
               1. Thuis
               2. Werk
               3. DHCP
 
               x. Exit
 
EOF
}

# Main program
XCHOICE="YES"
KEUZE="0"

while [ ! "$KEUZE" = "x" ]; do
        Menu
        echo -n "Maak uw keuze: "
        read KEUZE
        case $KEUZE in
                1) # Thuis
		Thuis
		CheckIp
		SetIp
                ;;
                2) # Werk
		Werk
		CheckIp
		SetIp
                ;;
                3) # DHCP
		DHCP
		SetIp
                ;;
                x) # Afsluiten
                exit
                ;;
        esac
        read DUMMY
done
 
exit 0
