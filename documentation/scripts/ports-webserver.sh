#!/usr/bin/env bash
# Skript fuer production Einsatz des Webservers
# LOESCHE alle existierenden Regeln
iptables -F
iptables -t nat -F
iptables -X

# ERLAUBE trafifc ueber das loopback Interface, benoetigt fuer Datenbanken usw.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ERLAUBE ssh traffic auf Port 22
# ERLAUBE NEW,ESTABLISHED,RELATED Pakete fuer eingehende Verbindungen, da sonst keine neuen Verbindungen moeglich
iptables -A INPUT -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT
# ERLAUBE ESTABLISHED,RELATED pakete fuer ausgehende Verbindungen, benoetigt fuer ausgehende Pakete fuer Verbindung
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -p tcp --sport 22 -j ACCEPT

# ERLAUBE eingehenden traffic auf Port 80 fuer HTTP, nur von der Firewall
iptables -A INPUT -p tcp --src 192.168.0.220 --dport 80 --jump ACCEPT
# ERLAUBE ausgehenden traffic auf Port 80 fuer HTTP
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT

iptables -P INPUT DROP
iptables -P OUTPUT DROP
