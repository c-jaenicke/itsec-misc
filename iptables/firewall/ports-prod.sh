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

# allow dns traffic on port 53, both tcp and udp
iptables -A INPUT -p tcp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# allow ntp traffic on port 123, as client, recieving ntp time
iptables -A INPUT -p udp --sport 123 -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT

# allow pinging
iptables -A INPUT -p icmp -j  ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# allow http on port 80
iptables -A INPUT -p tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

# allow https on port 443
iptables -A INPUT -p tcp --sport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# forward incoming traffic on port 80, http, to webserver port 80 and back
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.221:80
iptables -A FORWARD -p tcp -d 192.168.0.221 --dport 80 -j ACCEPT
iptables -t nat -A POSTROUTING -p tcp -d 192.168.0.221 --dport 80 -j MASQUERADE

# allow outlook traffic to external mailserver
## imap
iptables -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 993 -j ACCEPT
## pop3
iptables -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 110 -j ACCEPT
iptables -A INPUT -p tcp --dport 995 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 995 -j ACCEPT
## smtp
iptables -A INPUT -p tcp --dport 587 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 587 -j ACCEPT

# allow traffic for teamviewer
iptables -A INPUT -p tcp --dport 5938 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5938 -j ACCEPT

iptables -A INPUT -p udp --dport 5938 -j ACCEPT
iptables -A OUTPUT -p udp --sport 5938 -j ACCEPT

# allow traffic for delfship
iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8081 -j ACCEPT

# drop  traffic that doesnt match incoming or forwarding rules, allow all outgoing
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT # forward has to be ACCEPT, to allow forwarding to webserver
iptables -P OUTPUT ACCEPT
