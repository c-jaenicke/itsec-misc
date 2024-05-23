# this script blocks all incoming and outgoing traffic
# flush all rules and reset all chains
iptables -F
iptables -t nat -F
iptables -X

# block all incoming, outgoing and forwarded traffic
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
