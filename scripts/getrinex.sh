#!/bin/bash

set -x

FILE=`curl -s ftp://cddis.gsfc.nasa.gov/../gps/data/daily/2017/brdc/ | awk '/brdc.*n/ {print $9}' | tail -n 1`

wget ftp://cddis.gsfc.nasa.gov/../gps/data/daily/2017/brdc/$FILE -O rinex.Z

gzip -d rinex.Z  && rm rinex.txt && mv rinex rinex.txt