# base image debian stretch
FROM debian:stretch

# get required packages
RUN apt-get update \
    && apt-get -y install cmake \
    && apt-get -y install g++-multilib \
    && apt-get -y install libc6-dev \
    && apt-get -y install libc6-dev-i386 \
    && apt-get -y install libx11-dev \
    && apt-get -y install git

# clone a patched version of MrsWatson
RUN git clone 'https://github.com/CarlosBalladares/MrsWatson'

# set env variables
ENV C_COMPILER 'gcc' 
ENV CXX_COMPILER 'g++'

# Pull MrsWatson dependencies
RUN cd MrsWatson && git submodule sync && git submodule update --init --recursive

# Patch libaudiofile to make it compatible with the compiler config
RUN sed -i -e 's/-1 << kScaleBits/-1U << kScaleBits/g' MrsWatson/vendor/audiofile/libaudiofile/modules/SimpleModule.h

# Run makefile and copy binaries to /usr/bin
RUN cd MrsWatson &&  mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=Debug -DVERBOSE=TRUE .. && make && mv main/mrswatson /usr/bin/ && mv main/mrswatson64 /usr/bin/

# Optionally remove MrsWatson if you don't need
RUN rm -rf MrsWatson