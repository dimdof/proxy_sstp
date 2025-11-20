# SSTP client running in docker

Allows connect to SSTP network throw SOCKS5.

### With docker command
You need to set `USER` `PASSWORD` and `REMOTEHOST` for sstp connection

> You need to put certificate to file `ca.crt` into root directory

`PROXYUSER` and `PROXYPASSWORD` need for first socks5 connection

```bash
docker build -t proxy_sstp . && \
docker run -d --cap-add=NET_ADMIN \
--device /dev/ppp \
-e USER=*** \
-e PASSWORD=*** \
-e REMOTEHOST=*** \
-e PROXYUSER=*** \
-e PROXYPASSWORD=*** \
--name proxy_sstp \
-p 1080:1080 \
proxy_sstp \
sh -c "ip route add 192.168.2.0/24 via 172.17.0.1 dev eth0"
```

After starting the container for the first connection, authentication is needed.

You can simply run:

```
curl --socks5 PROXYUSER:PROXYPASSWORD@<ip address>:1080 https://ipinfo.io
```