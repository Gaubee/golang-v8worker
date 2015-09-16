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

ENV GOLANG_VERSION 1.5.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA1 46eecd290d8803887dec718c691cc243f2175fe0

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA1  golang.tar.gz" | sha1sum -c - \
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

RUN rm -rf /go/src/github.com/ry/v8worker/v8

USER root
RUN chown -R gouser /go
