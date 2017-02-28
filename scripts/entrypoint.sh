#!/bin/bash


if [[ "${CALLSIGN}" == "" ]]; then
	echo "CALLSIGN env not set! (use docker run -ti --rm --privileged -v /dev/bus/usb:/dev/bus/usb -e "CALLSIGN=$1" teeed/dxlaprs:latest)"

	exit 1
fi


./start.sh