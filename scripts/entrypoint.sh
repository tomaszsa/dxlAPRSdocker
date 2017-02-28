#!/bin/bash
SDRCFG="sdrcfg.txt"



declare -A SONDE_FREQ=( ['poprad']='f 400.600 5 0' ['wien']='f 401.000 5 0 15000' ['prague']='f 401.100 5 0' ['prostejov']='f 402.100 5 0' ['wroclaw']='f 403.000 5 0 15000' ['budapest']='f 403.010 5 0' ['senica']='f 403.730 5 0')

SONDE_FREQ_LIST="${!SONDE_FREQ[@]}"


function error_n {
	echo -e "\e[1m\e[91m${1}\e[0m"
}

function error {
	error_n "$1"
	echo -e "Usage: docker run -ti --rm --privileged -v /dev/bus/usb:/dev/bus/usb -e \"CALLSIGN=your_callsign\" -e \"PPM=sdr_ppm\" -e \"FREQ_SELECT=selected_sonde_freqs\" teeed/dxlaprs:latest\e[0m"

	exit 1
}

function warning {
	echo -e "\e[93m${1}\e[0m"
}


function gen_sdrcfg_error {
	error_n "Select input frequencies, available: ${SONDE_FREQ_LIST}"
	error "Separate by space."
}

function gen_sdrcfg {
	local PPM="$1"
	local FREQ_SELECT="$2"

	# Generate sdrcfg.txt
	echo "#ponizsza wartosc 0 to wartosc PPM ktora moze byc inna dla kazdego odbiornika RTL-SDR" > $SDRCFG
	echo "p 5 ${PPM}" >> $SDRCFG
	echo "p 8 1" >> $SDRCFG
	echo >> $SDRCFG

	for freq_name in ${FREQ_SELECT}; do
		local freq_line="${SONDE_FREQ[${freq_name}]}"

		if [[ "${freq_line}" == "" ]]; then
			error_n "Frequency name invalid: ${freq_name}"
			echo
			gen_sdrcfg_error
		fi


		echo >> $SDRCFG
		echo "${freq_line}" >> $SDRCFG
	done
}

if [[ "${CALLSIGN}" == "" ]]; then
	error "CALLSIGN env not set!"
fi

if [[ ! -d /dev/bus/usb/ ]]; then
	error "USB not enabled (--privileged -v /dev/bus/usb:/dev/bus/usb)"
fi

if [[ "${PPM}" == "" ]]; then
	warning "Using default RTL ppm: 0"

	PPM="0"
fi

if [[ "${FREQ_SELECT}" == "" ]]; then
	gen_sdrcfg_error
fi


gen_sdrcfg "${PPM}" "${FREQ_SELECT}"



./start.sh