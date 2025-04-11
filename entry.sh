#!/usr/bin/env bash

set -e
set -a

if [ -z "$REMOTEHOST" ]; then
  echo "Variable REMOTEHOST must be set."; exit;
fi

# echo "$USER connection '$PASSWORD' *" | tee -a /etc/ppp/chap-secrets

sstpc_args=(
    "--user" "$USER"
    "--password" "$PASSWORD"
    "$REMOTEHOST"
    "--log-stdout"
    "--log-level" "4"
    "--tls-ext"
    "--ca-cert" "/etc/ssl/certs/ca.crt"
    "--save-server-route"
    "noauth"
    "defaultroute"
)

sysctl net.ipv6.conf.all.disable_ipv6=1
sysctl net.ipv6.conf.default.disable_ipv6=1

# /etc/init.d/syslog-ng start
sstpc "${sstpc_args[@]}" &

echo "Waiting for the appearance of the PPP0 interface..."
while ! ip a | grep -q ppp0; do
  sleep 1
done

PEER=$(ip addr show dev ppp0 | grep 'peer' | awk '{print $4}' | cut -d/ -f1)
LOCAL_GATEWAY=$(ip route | grep default | grep eth0 | awk '{print $3}')

echo "PPP0 interface is found. We change the routes..."
ip route del default
ip route add default via "$PEER" dev ppp0
ip route add 192.168.0.0/24 via $LOCAL_GATEWAY dev eth0


ip link show ppp0 || { echo "PPP0 interface was not found. Interrupt launch"; exit 1; }
echo "nameserver 1.1.1.1" > /etc/resolv.conf

echo "Starting microsocks..."
microsocks -i 0.0.0.0 -p 1080 -1 -u $PROXYUSER -P $PROXYPASSWORD &
echo "Ready. Proxy on port 1080 via ppp0."

tail -f /dev/null
#pon connection

#sleep infinity