#!/bin/sh
set -e

iptables -A INPUT -p udp -m udp --dport 51820 -j ACCEPT
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 10.8.0.0/24 -d 10.8.0.0/24 -i wg0 -o wg0 -j ACCEPT
iptables -A FORWARD -s 10.8.0.0/24 -d 192.168.0.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.0.0/24 -d 10.8.0.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
ip rule add from 10.8.0.0/24 table 200
ip route add default via 10.89.1.2 dev eth0 table 200
ip route add 10.89.1.0/24 via 10.89.1.1 dev eth0 table 200
ip route add 192.168.0.0/24 via 10.89.1.1 dev eth0 table 200
ip route add 10.8.0.0/24 dev wg0 table 200
