#!/usr/bin/env bash
# Script um production Einstellungen umzusetzen
# alle regeln und chains flushen, zuruecksetzen
iptables -F
iptables -t nat -F
iptables -X

# ERLAUBE lokalen traffic, benoetigt fuer lokale Verbindungen wie datenbanken
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ERLAUBE ssh traffic auf Port 22
# ERLAUBE NEW,ESTABLISHED,RELATED Pakete fuer eingehende Verbindungen, da sonst keine neuen Verbindungen moeglich
iptables -A INPUT -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT
# ERLAUBE ESTABLISHED,RELATED pakete fuer ausgehende Verbindungen, benoetigt fuer ausgehende Pakete fuer Verbindung
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -p tcp --sport 22 -j ACCEPT

# ERLAUBE DNS traffic auf Port 53, sowohl TCP als auch UDP
# ERLAUBE eingehende TCP Pakete die Antwort auf DNS abfrage sind
iptables -A INPUT -m state --state ESTABLISHED -p tcp --sport 53 -j ACCEPT
# ERLAUBE ausgehende TCP Pakete die neue DNS abfrage durchfuehren oder Rueckantwort auf eine DNS abfrage sind
iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 53 -j ACCEPT
# ERLAUBE eingehende UDP Pakete die Antwort auf DNS abfrage sind
iptables -A INPUT -m state --state ESTABLISHED -p udp --sport 53 -j ACCEPT
# ERLAUBE ausgehende UDP Pakete die neue DNS abfrage durchfuehren oder Rueckantwort auf eine DNS abfrage sind
iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p udp --dport 53 -j ACCEPT

# ERLAUBE NTP (Zeitserver) traffic auf Port 123, als Client, erhalten von NTP Zeit
# ERLAUBE eingehende Pakete, Antworten auf NTP abfragen
iptables -A INPUT -m state --state ESTABLISHED -p udp --sport 123 -j ACCEPT
# ERLAUBE ausgehende Pakete, NTP Anfragen oder Rueckantworten
iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p udp --dport 123 -j ACCEPT

# ERLAUBE HTTP traffic auf Port 80
# ERLAUBE eingehende Pakete die Antwort auf ein Paket sind, zu einer Session gehoeren
iptables -A INPUT -m state --state ESTABLISHED -p tcp --sport 80 -j ACCEPT
# ERLAUBE ausgehende Pakete die eine neue Session starten oder Rueckantwort auf ein Paket sind
iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 80 -j ACCEPT

# ERLAUBE HTTPS traffic auf Port 443
# ERLAUBE eingehende Pakete die Antwort auf ein Paket sind, zu einer Session gehoeren
iptables -A INPUT -m state --state ESTABLISHED -p tcp --sport 443 -j ACCEPT
# ERLAUBE ausgehende Pakete die eine neue Session starten oder Rueckantwort auf ein Paket sind
iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 443 -j ACCEPT

# LEITE eingehenden traffic auf Port 80 WEITER zum Webserver und zurueck
iptables -A FORWARD -p tcp -d 192.168.0.221 --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.221:80
iptables -t nat -A POSTROUTING -p tcp -d 192.168.0.221 --dport 80 -j MASQUERADE

# ERLAUBE traffic zu einem externen Outlook Exchange Server
# Das Verwenden von States ist hier nicht moeglich, das sowohl der Server als auch der Client Pakete
# senden koennen, wie Benachrichtigungen und E-Mails
## ERLAUBE traffic fuer das IMAP Protokoll
iptables -A INPUT -p tcp --sport 143 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp --sport 993 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 993 -j ACCEPT
## ERLAUBE traffic fuer das POP3 Protokoll
iptables -A INPUT -p tcp --sport 110 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
iptables -A INPUT -p tcp --sport 995 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 995 -j ACCEPT
## ERLAUBE traffic fuer das SMTP Protokoll
iptables -A INPUT -p tcp --sport 587 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 587 -j ACCEPT

# ERLAUBE traffic fuer TeamViewer ueber TCP und UDP
# ERLAUBE alle Pakete unabhaengig von Status, da dies zu Problem fuehren koennte
iptables -A INPUT -p tcp --dport 5938 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5938 -j ACCEPT

iptables -A INPUT -p udp --dport 5938 -j ACCEPT
iptables -A OUTPUT -p udp --sport 5938 -j ACCEPT

# ERLAUBE traffic fuer Delftship Lizenzserver
# ERLAUBE eingehende Pakete vom Lizenzserver
iptables -A INPUT -m state --state ESTABLISHED -p tcp --sport 8081 -j ACCEPT
# ERLAUBE Anfragen zum Lizenzserver und Rueckantworten
iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 8081 -j ACCEPT

# drop  traffic that doesnt match incoming or forwarding rules, allow all outgoing
# REGELN FUER ALLE PAKETE DIE VORHERIGE REGELN NICHT MATCHEN
# LASSE alle eingehenden Pakete FALLEN
iptables -P INPUT DROP
# LEITE Pakete WEITER, muss auf Accept sein um Forwarding generell zu ermoeglichen
iptables -P FORWARD ACCEPT
# LASSE alle ausgehenden Pakete FALLEN
iptables -P OUTPUT DROP

