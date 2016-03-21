#
# Go-Runtime with v8worker Dockerfile
#
# http://dockerfile.github.io/#/go
# http://dockerfile.github.io/#/go-runtime
#

# Pull base image.
FROM golang
MAINTAINER Gaubee <gaubeebangeel@gmail.com>

# Install Build Env
RUN apt-get update && apt-get install -y \
		apt-utils \
		lbzip2 \
		lsb-release \
		gcc \
		g++ \
		clang \
		pkg-config \
		libc6-dev \
		make \
		--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ENV DEPOT_TOOLS $HOME/depot_tools

# fetch need create file
ENV HOME /home/gouser
WORKDIR "$HOME"

# get chromium depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS

# go get v8worker: download & compile V8 & go install v8worker
chmod -R 777 "$GOPATH"
WORKDIR "$GOPATH"

RUN useradd -m gouser
USER gouser

RUN git clone https://github.com/ry/v8worker src/github.com/ry/v8worker
WORKDIR "$GOPATH/src/github.com/ry/v8worker"
# build and run test && compile to $GOPATH/pkg/linux_amd64/github.com/ry/v8worker.a
RUN make && make install
# clear v8 source and test file
RUN make distclean
# remove compile tools
RUN rm -rf $DEPOT_TOOLS

USER root
RUN chown -R gouser /go
ENV HOME /root

# open bash
CMD ["sh"]
