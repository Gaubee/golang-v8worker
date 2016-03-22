#
# Go-Runtime with v8worker Dockerfile
#
# http://dockerfile.github.io/#/go
# http://dockerfile.github.io/#/go-runtime
#

# Pull base image.
FROM buildpack-deps:jessie-scm
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

#Install GoLang
ENV GOLANG_VERSION 1.6
ENV GOLANG_DOWNLOAD_URL https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV GOROOT /usr/local/go
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR "$GOPATH"

# go get v8worker: download & compile V8 & go install v8worker
RUN useradd -m gouser
USER gouser

# fetch need create file
ENV HOME /home/gouser
ENV DEPOT_TOOLS $HOME/depot_tools
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH:$DEPOT_TOOLS

WORKDIR "$HOME"

# get chromium depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS

WORKDIR "$GOPATH"
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
CMD ["bash"]
