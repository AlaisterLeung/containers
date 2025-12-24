#!/bin/sh
set -e

iptables -D INPUT -p udp -m udp --dport 51820 -j ACCEPT
iptables -D FORWARD -i wg0 -j ACCEPT
iptables -D FORWARD -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -s 10.8.0.0/24 -d 10.8.0.0/24 -i wg0 -o wg0 -j ACCEPT
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
ip rule del from 10.8.0.0/24 table 200
ip route del default via 10.89.1.2 dev eth0 table 200
ip route del 10.89.1.0/24 via 10.89.1.1 dev eth0 table 200
ip route del 10.8.0.0/24 dev wg0 table 200
