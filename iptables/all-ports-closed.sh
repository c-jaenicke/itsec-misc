#!/usr/bin/env bash
# Skript der alle Ports schliesst
# LOESCHE alle existierenden Regeln
iptables -F
iptables -t nat -F
iptables -X

# BLOCKIERE ALLE EINGEHENDEN UND AUSGEHENDEN PAKETE
iptables -P INPUT DROP
iptables -P OUTPUT DROP
