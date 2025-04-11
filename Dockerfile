FROM ubuntu:latest
# COPY connection /etc/ppp/peers/

RUN apt update
RUN apt install -y sstp-client ppp pptp-linux ca-certificates openssl net-tools --no-install-recommends
RUN apt install -y wget iproute2 microsocks dnsutils --no-install-recommends

ARG BUILD_DATE
ARG IMAGE_VERSION

COPY entry.sh /usr/bin/
RUN chmod +x /usr/bin/entry.sh

COPY 0route /etc/ppp/ip-up.d/
RUN chmod +x /etc/ppp/ip-up.d/0route

LABEL build-date=$BUILD_DATE
LABEL image-version=$IMAGE_VERSION
COPY ca.crt /etc/ssl/certs/ca.crt
EXPOSE 1080

ENTRYPOINT [ "/usr/bin/entry.sh" ]