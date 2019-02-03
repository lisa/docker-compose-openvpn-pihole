#!/bin/bash

source /etc/openvpn/ovpn_env.sh

NATDEV=${OVPN_NATDEVICE:-eth0}

iptables -C FORWARD -i "${OVPN_DEVICE}${OVPN_DEVICEN}" -o ${NATDEV} -s ${OVPN_SERVER} -m conntrack --ctstate NEW -j ACCEPT || \
  iptables -I FORWARD -i "${OVPN_DEVICE}${OVPN_DEVICEN}" -o ${NATDEV} -s ${OVPN_SERVER} -m conntrack --ctstate NEW -j ACCEPT 

iptables -C FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || \
  iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

iptables -C POSTROUTING -t nat -o ${NATDEV} -s ${OVPN_SERVER} -j MASQUERADE || \
  iptables -I POSTROUTING -t nat -o ${NATDEV} -s ${OVPN_SERVER} -j MASQUERADE

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

pihost=$(getent hosts openvpn | cut -d ' ' -f 1)

echo "Setting pi-host to $pihost"

sed -i -e "s/push \"dhcp-option DNS .*\"/push \"dhcp-option DNS $pihost\"/" /etc/openvpn/openvpn.conf

exec openvpn --config /etc/openvpn/openvpn.conf --client-config-dir /etc/openvpn/ccd
