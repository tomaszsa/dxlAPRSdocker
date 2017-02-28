#!/bin/bash

if [[ "${1}" == "" ]]; then
	echo "Usage: ./run.sh CALLSIGN"

	exit 1
fi

docker run -ti --rm --privileged -v /dev/bus/usb:/dev/bus/usb -e "CALLSIGN=$1" teeed/dxlaprs:latest