#!/bin/sh

# OS X/macOS shell script to call post network interface standup -
# particularly VPN tunnels. Note that you must have the ability to
# update DNS records in the specified domain.

# what is our hostname?
myhost=$(scutil --get HostName)
# what's my domain? If this needs to be retrieved programmatically,
# this will need additional work!
mydomain="example.com."
# which NIC is the VPN tunnel? Previous comment applies here as well
nic="utun0"
# RR TTL in seconds (86400 ::= one day)
ttl=86400

# grab the IPv4 address from the VPN tunnel
vpn_ip=$(ifconfig ${nic} | awk '$1=="inet" {print $2}')
# we'll need a reversed IP to create the PTR record
rev_ip=$(echo $vpn_ip | awk -F. '{printf("%d.%d.%d.%d\n",$4,$3,$2,$1)}')

#create temp file for input
mytemp=$(mktemp /tmp/nsupdate_XXXXXX)
#place nsupdate commands in tempfile using a here document
cat > "${mytemp}" <<XXXendstrXXX
update delete ${myhost}.${mydomain} A
send
update delete ${rev_ip}.in-addr.arpa. PTR
send
update add ${myhost}.${mydomain} ${ttl} IN A ${vpn_ip}
send
update add ${rev_ip}.in-addr.arpa. ${ttl} IN PTR ${myhost}.${mydomain}
send
quit            
XXXendstrXXX

# finally, execute nsupdate, and delete the tempfile iff successful
/usr/bin/nsupdate "${mytemp}" && rm "${mytemp}"
