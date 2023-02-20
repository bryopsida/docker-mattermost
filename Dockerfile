FROM alpine:latest as build
RUN apk add --no-cache \
  g++ \
  gcc \
  make \
  bash \
  libc6-compat \
  gcompat \
  musl-dev \
  git \
  go \
  curl \
  wv \
  poppler-utils \
  libssl1.1 \
  libxml2 \
  openssl

ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

RUN git clone https://github.com/mattermost/mattermost-server.git /build
WORKDIR /build
COPY build.sh .
RUN ./build.sh

FROM alpine:latest
RUN apk add --no-cache bash gcompat
RUN addgroup -g 10001 mattermost && \
  adduser -u 10001 -G mattermost -h /home/mattermost -D mattermost

WORKDIR /home/mattermost
COPY --from=build /build/bin/mattermost .
USER mattermost