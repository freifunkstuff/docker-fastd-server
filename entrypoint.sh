#!/bin/bash
set -e

# check required env variables
: "${FASTD_MTU:? must be set}"

# set some defaults
: "${FASTD_LOG_LEVEL:=info}"
: "${FASTD_PEER_LIMIT:=100}"

umask 600

mkdir -p /config/secret
if [ ! -f /config/secret/secret.txt ]; then
 fastd --generate-key > /config/secret/secret.txt
fi

mkdir -p /config/fastd/peers
cat << EOF > /config/fastd/fastd.conf
log level ${FASTD_LOG_LEVEL};
drop capabilities yes;
bind any:10061;
mode tap;
interface "mesh-vpn";
method "salsa2012+umac";
method "salsa2012+gmac";
method "null+salsa2012+umac";
method "null@l2tp";
persist interface no;
offload l2tp yes;
mtu ${FASTD_MTU};
secret "$( cat /config/secret/secret.txt | grep -e Secret | awk '{ print $2 }' )";
peer limit ${FASTD_PEER_LIMIT};
on verify sync "true";
forward yes;
on up "
  ip link set up dev mesh-vpn
  batctl meshif add mesh-vpn
  ifconfig bat0 up
  $( test -z "${IPV6_PREFIX}" || echo "/config/static_v6.sh" )
";
include peers from "peers";
EOF

if [ ! -z "${IPV6_PREFIX}" ]; then
cat << EOF > "/config/static_v6.sh"
MAC=\$( cat /sys/class/net/bat0/address )
IPV6=\$( ipv6calc --action prefixmac2ipv6 --in prefix+mac --out ipv6addr ${IPV6_PREFIX} \${MAC})
ip -6 addr add \${IPV6} dev bat0
EOF
chmod 0755 /config/static_v6.sh
fi

# create tun device
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

# Setup sysctl

echo "0" > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo "1" > /proc/sys/net/ipv6/conf/all/forwarding

exec fastd --config /config/fastd/fastd.conf --status-socket /config/fastd/fastd.status
