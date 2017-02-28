#!/bin/bash
## wyjscie z crona: screen -S radiosondy -X quit

set -x 

killall -9 udpgate4 sondemod sondeudp rtl_tcp sdrtst

if test `find "rinex.txt" -mmin +1440`
then
    ./getrinex.sh
fi

mkfifo /tmp/multichannel.fifo

screen -S radiosondy -t rtl_tcp -A -d -m rtl_tcp -a 127.0.0.1 -g 0 -P 53 -d 0 -b 30
sleep 10 

screen -S radiosondy -X screen -t udpgate
screen -S radiosondy -p udpgate -X stuff $"udpgate4 -v -R 127.0.0.1:4011:4010 -s ${CALLSIGN}-15 -l 7:aprs.log -t 14580 -g euro.aprs2.net:14580 -p 19874\n"

screen -S radiosondy -X screen -t sdrtst
screen -S radiosondy -p sdrtst -X stuff $'sdrtst -c sdrcfg.txt -k -v -s /tmp/multichannel.fifo \n'
sleep 10

screen -S radiosondy -X screen -t sondeudp
screen -S radiosondy -p sondeudp -X stuff $"sondeudp -f 16000 -l 128 -c 0 -o /tmp/multichannel.fifo -I ${CALLSIGN}-14 -v -u 127.0.0.1:4000 \n"
sleep 10

screen -S radiosondy -X screen -t sondemod
screen -S radiosondy -p sondemod -X stuff $"while [ 1 ] ; do sondemod -v -x rinex.txt -r 127.0.0.1:4010 -o 4000 -I ${CALLSIGN}-14 -R 30 -d -A 700 -B 2 -b 30 -p 0 ; done\n"

screen -S radiosondy -X screen -t almanach
screen -S radiosondy -p almanach -X stuff $'while [ 1 ] ; do sleep 7200; ./getrinex.sh ; done \n'

screen -rx radiosondy -p sondeudp
