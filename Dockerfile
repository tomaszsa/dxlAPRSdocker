FROM debian
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install build-essential libX11-dev libXext-dev libpng-dev:i386 libjpeg-dev git g++-multilib zlib1g-dev:i386 libx11-dev:i386 libxext-dev:i386 rtl-sdr psmisc
WORKDIR /root
RUN git clone --depth=1 https://github.com/oe5hpm/dxlAPRS
WORKDIR dxlAPRS/src
RUN make
RUN cp afskmodem aprsmap gps2aprs gps2digipos sdrradio sdrtst sondemod sondeudp udpbox udpflex udpgate4 udphub udprfnet /usr/local/bin

RUN apt-get -y install xterm screen
RUN apt-get -y install wget curl

# from http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /home/developer

WORKDIR /home/developer
COPY scripts/ scripts
WORKDIR scripts
RUN chmod +x *.sh
RUN chown developer:developer -R /home/developer


USER developer
ENV HOME /home/developer
ENTRYPOINT ./entrypoint.sh