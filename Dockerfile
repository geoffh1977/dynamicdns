# Build Dynamic DNS Container For NoIP.com

# Build NoIP Executable
FROM alpine:latest as builder

RUN apk add -U ca-certificates curl make gcc libc-dev && \
  curl -o /tmp/noip-duc-linux.tar.gz  https://www.noip.com/client/linux/noip-duc-linux.tar.gz && \
  tar zxf /tmp/noip-duc-linux.tar.gz -C /tmp && \
  cd /tmp/noip-* && \
  make && \
  cp noip2 /usr/bin

# Final NoIp Container
FROM alpine:latest
LABEL maintainer="geoffh1977 <geoffh1977@gmail.com>"

COPY --from=builder /usr/bin/noip2 /usr/bin/
COPY scripts/* /usr/local/bin/

RUN apk add -U --no-cache expect bash curl jq && \
  mkdir /config && \
  addgroup dyndns && \
  adduser -H -G dyndns dyndns && \
  chown dyndns:dyndns -R /config && \
  chmod +x /usr/local/bin/start.sh /usr/local/bin/healthcheck.sh&& \
  rm -rf /var/cache/apk/*

USER dyndns
CMD ["/usr/local/bin/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD /usr/local/bin/healthcheck.sh > /dev/null
