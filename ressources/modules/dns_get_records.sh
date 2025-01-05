#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} domain"
    echo "Run dig command for different DNS record types"
    exit
fi

domain=${1}
outFile="/tmp/dns-resource-record-result.txt"

dig +short AAAA ${domain} >> ${outFile}
dig +short AFSDB ${domain} >> ${outFile}
dig +short APL ${domain} >> ${outFile}
dig +short CAA ${domain} >> ${outFile}
dig +short CDNSKEY ${domain} >> ${outFile}
dig +short CDS ${domain} >> ${outFile}
dig +short CERT ${domain} >> ${outFile}
dig +short CNAME ${domain} >> ${outFile}
dig +short DHCID ${domain} >> ${outFile}
dig +short DLV ${domain} >> ${outFile}
dig +short DNAME ${domain} >> ${outFile}
dig +short DNSKEY ${domain} >> ${outFile}
dig +short DS ${domain} >> ${outFile}
dig +short HIP ${domain} >> ${outFile}
dig +short HINFO ${domain} >> ${outFile}
dig +short IPSECKEY ${domain} >> ${outFile}
dig +short ISDN ${domain} >> ${outFile}
dig +short KEY ${domain} >> ${outFile}
dig +short KX ${domain} >> ${outFile}
dig +short MB ${domain} >> ${outFile}
dig +short MD ${domain} >> ${outFile}
dig +short MF ${domain} >> ${outFile}
dig +short MG ${domain} >> ${outFile}
dig +short MR ${domain} >> ${outFile}
dig +short MX ${domain} >> ${outFile}
dig +short NAPTR ${domain} >> ${outFile}
dig +short NS ${domain} >> ${outFile}
dig +short NSAP ${domain} >> ${outFile}
dig +short NSEC ${domain} >> ${outFile}
dig +short NSEC3 ${domain} >> ${outFile}
dig +short NSEC3PARAM ${domain} >> ${outFile}
dig +short NULL ${domain} >> ${outFile}
dig +short NXT ${domain} >> ${outFile}
dig +short OPT ${domain} >> ${outFile}
dig +short RP ${domain} >> ${outFile}
dig +short RRSIG ${domain} >> ${outFile}
dig +short SIG ${domain} >> ${outFile}
dig +short SOA ${domain} >> ${outFile}
dig +short SPF ${domain} >> ${outFile}
dig +short SRV ${domain} >> ${outFile}
dig +short SRV _ldap._tcp.dc._msdcs.${domain} >> ${outFile}
dig +short SRV _ldap._tcp.gc._msdcs.${domain} >> ${outFile}
dig +short SRV _ldap._tcp.pdc._msdcs.${domain} >> ${outFile}
dig +short SRV _ldap._tcp.${domain} >> ${outFile}
dig +short SRV _ldap._tcp.ForestDNSZones.${domain} >> ${outFile}
dig +short SRV _gc._msdcs.${domain} >> ${outFile}
dig +short SRV _kpasswd._tcp.${domain} >> ${outFile}
dig +short SRV _kpasswd._udp.${domain} >> ${outFile}
dig +short SRV _kerberos._tcp.dc._msdcs.${domain} >> ${outFile}
dig +short SRV _kerberos.tcp.dc._msdcs.${domain} >> ${outFile}
dig +short SRV _kerberos-master._tcp.${domain} >> ${outFile}
dig +short SRV _kerberos-master._udp.${domain} >> ${outFile}
dig +short SRV _kerberos._tcp.${domain} >> ${outFile}
dig +short SRV _kerberos._udp.${domain} >> ${outFile}
dig +short SRV _autodiscover._tcp.${domain} >> ${outFile}
dig +short SRV _ntp._udp.${domain} >> ${outFile}
dig +short SRV _nntp._tcp.${domain} >> ${outFile}
dig +short SRV _imap._tcp.${domain} >> ${outFile}
dig +short SRV _imap.tcp.${domain} >> ${outFile}
dig +short SRV _imaps._tcp.${domain} >> ${outFile}
dig +short SRV _pop3._tcp.${domain} >> ${outFile}
dig +short SRV _pop3s._tcp.${domain} >> ${outFile}
dig +short SRV _smtp._tcp.${domain} >> ${outFile}
dig +short SRV _caldav._tcp.${domain} >> ${outFile}
dig +short SRV _caldavs._tcp.${domain} >> ${outFile}
dig +short SRV _carddav._tcp.${domain} >> ${outFile}
dig +short SRV _carddavs._tcp.${domain} >> ${outFile}
dig +short SRV _stun._tcp.${domain} >> ${outFile}
dig +short SRV _stun._udp.${domain} >> ${outFile}
dig +short SRV _stuns._tcp.${domain} >> ${outFile}
dig +short SRV _turn._tcp.${domain} >> ${outFile}
dig +short SRV _turn._udp.${domain} >> ${outFile}
dig +short SRV _turns._tcp.${domain} >> ${outFile}
dig +short SRV _h323be._tcp.${domain} >> ${outFile}
dig +short SRV _h323be._udp.${domain} >> ${outFile}
dig +short SRV _h323cs._tcp.${domain} >> ${outFile}
dig +short SRV _h323cs._udp.${domain} >> ${outFile}
dig +short SRV _h323ls._tcp.${domain} >> ${outFile}
dig +short SRV _h323ls._udp.${domain} >> ${outFile}
dig +short SRV _sip._tcp.${domain} >> ${outFile}
dig +short SRV _sip._tls.${domain} >> ${outFile}
dig +short SRV _sip._udp.${domain} >> ${outFile}
dig +short SRV _sipfederationtls._tcp.${domain} >> ${outFile}
dig +short SRV _sipinternal._tcp.${domain} >> ${outFile}
dig +short SRV _sipinternaltls._tcp.${domain} >> ${outFile}
dig +short SRV _sips._tcp.${domain} >> ${outFile}
dig +short SRV _aix._tcp.${domain} >> ${outFile}
dig +short SRV _certificates._tcp.${domain} >> ${outFile}
dig +short SRV _cmp._tcp.${domain} >> ${outFile}
dig +short SRV _crl._tcp.${domain} >> ${outFile}
dig +short SRV _crls._tcp.${domain} >> ${outFile}
dig +short SRV _finger._tcp.${domain} >> ${outFile}
dig +short SRV _ftp._tcp.${domain} >> ${outFile}
dig +short SRV _gc._tcp.${domain} >> ${outFile}
dig +short SRV _hkp._tcp.${domain} >> ${outFile}
dig +short SRV _hkps._tcp.${domain} >> ${outFile}
dig +short SRV _http._tcp.${domain} >> ${outFile}
dig +short SRV _https._tcp.${domain} >> ${outFile}
dig +short SRV _jabber-client._tcp.${domain} >> ${outFile}
dig +short SRV _jabber-client._udp.${domain} >> ${outFile}
dig +short SRV _jabber._tcp.${domain} >> ${outFile}
dig +short SRV _jabber._udp.${domain} >> ${outFile}
dig +short SRV _ocsp._tcp.${domain} >> ${outFile}
dig +short SRV _pgpkeys._tcp.${domain} >> ${outFile}
dig +short SRV _pgprevokations._tcp.${domain} >> ${outFile}
dig +short SRV _PKIXREP._tcp.${domain} >> ${outFile}
dig +short SRV _submission._tcp.${domain} >> ${outFile}
dig +short SRV _svcp._tcp.${domain} >> ${outFile}
dig +short SRV _telnet._tcp.${domain} >> ${outFile}
dig +short SRV _test._tcp.${domain} >> ${outFile}
dig +short SRV _whois._tcp.${domain} >> ${outFile}
dig +short SRV _x-puppet-ca._tcp.${domain} >> ${outFile}
dig +short SRV _x-puppet._tcp.${domain} >> ${outFile}
dig +short SRV _xmpp-client._tcp.${domain} >> ${outFile}
dig +short SRV _xmpp-client._udp.${domain} >> ${outFile}
dig +short SRV _xmpp-server._tcp.${domain} >> ${outFile}
dig +short SRV _xmpp-server._udp.${domain} >> ${outFile}
dig +short SSHFP ${domain} >> ${outFile}
dig +short TA ${domain} >> ${outFile}
dig +short TKEY ${domain} >> ${outFile}
dig +short TLSA ${domain} >> ${outFile}
dig +short TSIG ${domain} >> ${outFile}
dig +short TXT ${domain} >> ${outFile}
dig +short URI ${domain} >> ${outFile}
dig +short WKS ${domain} >> ${outFile}

cat ${outFile} | sort -u
rm ${outFile}

