#!/usr/bin/env bash
# Skript der alle Ports oeffnet
# LOESCHE alle existierenden Regeln
iptables -F
iptables -t nat -F
iptables -X

# ERLAUBE ALLE EINGEHENDEN UND AUSGEHENDEN PAKETE
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
