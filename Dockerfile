# offical https://hub.docker.com/_/buildpack-deps/ 
# Debian 8 Jessie SCM (bzr, git, hg, svn included)
FROM buildpack-deps:jessie-scm
MAINTAINER Pooya Woodcock <pooyaw@packetcloud.net>

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

ENV GOLANG_VERSION 1.6
ENV GOLANG_DOWNLOAD_URL https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR "$GOPATH"

RUN useradd -m gouser
USER gouser

ENV HOME /home/gouser
ENV GOPATH /go
ENV DEPOT_TOOLS /home/gouser/depot_tools
ENV PATH "$GOPATH/bin:/usr/local/go/bin:$PATH:$DEPOT_TOOLS"

WORKDIR "$HOME"

RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS
RUN echo "export PATH=\"\$PATH\"" >> .bashrc

# compile V8 and go install v8worker
WORKDIR "$GOPATH"
RUN git clone https://github.com/ry/v8worker src/github.com/ry/v8worker
WORKDIR "$GOPATH/src/github.com/ry/v8worker"
RUN make \
	&& make install

RUN rm -rf $DEPOT_TOOLS

USER root
RUN chown -R gouser /go
