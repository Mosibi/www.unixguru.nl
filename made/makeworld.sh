#!/bin/sh

if [ -z "$1" ]; then
	echo "Please give the name of kernelconfig you wish to build!"
	echo " "
	echo "Usage: $0 [kernelconfig]"
	echo "Example: $0 GENERIC"
	exit 0
fi

echo "#######################################"
echo "Now starting: make buildworld"
echo "#######################################"
make buildworld

echo "#######################################"
echo "Now starting: make buildkernel KERNCONF=$1"
echo "#######################################"
make buildkernel KERNCONF="$1"

echo "#######################################"
echo "Now starting: make installkernel KERNCONF=$1"
echo "#######################################"
make installkernel KERNCONF="$1"

echo "Reboot in single user mode (boot -s) and give the following commands:"
echo " "
echo "fsck -p"
echo "mount -u /"
echo "mount -a"
echo "cd /usr/src"
echo "adjkerntz -i"
echo "mergemaster -p"
echo "make installworld"
echo "mergemaster"
