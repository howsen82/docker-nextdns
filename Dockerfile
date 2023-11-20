FROM golang:alpine AS builder
ENV CGO_ENABLED=0

RUN set -xe && \
    apk update && apk upgrade && \
    apk add git upx && \
    git clone https://github.com/nextdns/nextdns.git /app && \
    cd /app && \
    go build -ldflags="-s -w" -o /go/bin/nextdns && \
    upx --lzma /go/bin/nextdns

FROM alpine
ENV NEXTDNS_ARGUMENTS="-listen :3000 -report-client-info -log-queries -cache-size 10MB -max-ttl 5s"
ENV NEXTDNS_ID=abcdef
COPY --from=builder /go/bin/nextdns /usr/bin
EXPOSE 3000/udp
CMD /usr/bin/nextdns run ${NEXTDNS_ARGUMENTS} -config ${NEXTDNS_ID}