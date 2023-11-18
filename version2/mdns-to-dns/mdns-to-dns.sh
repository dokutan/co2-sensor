#!/usr/bin/env sh

# change these variables
DNS_SERVER="foo.example" # DNS server (host name or IP)
DNS_ZONE="foo.example"
ESPHOME_DNS_NAME="co2-sensor.foo.example" # DNS host name (could be any name in the DNS zone)
ESPHOME_MDNS_NAME="co2-sensor.local" # mDNS host name (always ends with .local)
TTL="600"

# get the current ipv6 prefix and the link local address of the esphome device
PREFIX=$(ip -6 a | grep -F "scope global dynamic" | grep -Eo "([0-9a-f]+:){4}")
INTERFACE_ID=$(avahi-resolve -6 --name "$ESPHOME_MDNS_NAME" | grep -Eo "(:[0-9a-f]+){4}$" | cut -c 2-)

echo "updating $ESPHOME_DNS_NAME AAAA to $PREFIX$INTERFACE_ID on $DNS_SERVER"

cat << EOF | nsupdate
server $DNS_SERVER
zone $DNS_ZONE
update delete $ESPHOME_DNS_NAME. AAAA
update add $ESPHOME_DNS_NAME. $TTL AAAA $PREFIX$INTERFACE_ID
send
EOF
