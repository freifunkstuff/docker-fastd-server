FROM debian:bullseye-backports
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
      fastd batctl iproute2 \
      net-tools inetutils-ping procps \
      radvd radvdump tcpdump ndisc6 ipv6calc \
      bash curl socat jq
VOLUME /config /config/secret
ADD entrypoint.sh /entrypoint.sh
ADD healthcheck.sh /healthcheck.sh
CMD /entrypoint.sh
