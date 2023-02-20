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
RUN apk add --no-cache bash curl
RUN addgroup -g 10001 mattermost && \
  adduser -u 10001 -G mattermost -h /mattermost -D mattermost


WORKDIR /mattermost
RUN mkdir config && chown mattermost:mattermost config && \
  mkdir logs && chown mattermost:mattermost logs

COPY --from=build /build/bin/mattermost .
COPY --from=build /build/i18n ./i18n
USER mattermost
CMD ["mattermost"]
EXPOSE 8065 8067 8074 8075
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]