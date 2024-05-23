#!/usr/bin/env bash
# script for setting up production settings
# flush all rules and reset all chains
iptables -F
iptables -t nat -F
iptables -X

# allow all local traffic, needed for local connection like databases
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# allow ssh traffic on port 22
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# allow pinging
iptables -A INPUT -p icmp -j  ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# allow incoming http traffic from firewall and allow all outgoing http traffic
iptables --append INPUT --protocol tcp --src 192.168.0.220 --dport 80 --jump ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT

# drop  traffic that doesnt match incoming or forwarding rules, allow all outgoing
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
