FROM ubuntu:16.04

RUN apt update && apt install -y --no-install-recommends --no-install-suggests build-essential libtool automake cmake libssl-dev libboost-dev libpcap-dev libsndfile1-dev libapr1-dev libspeex-dev liblog4cxx-dev libxerces-c-dev

RUN mkdir src

COPY orkbasecxx src/orkbasecxx
COPY orkaudio src/orkaudio

COPY docker/deps src/deps
COPY docker/deps/debian src/debian
COPY docker/build.sh /build.sh
RUN /build.sh

CMD [ "/usr/sbin/orkaudio", "debug" ]
