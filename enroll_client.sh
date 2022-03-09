#!/bin/bash

# To the extent possible under law, Red Hat, Inc. has dedicated all copyright to
# this software to the public domain worldwide, pursuant to the CC0 Public
# Domain Dedication. This software is distributed without any warranty.
# See <http://creativecommons.org/publicdomain/zero/1.0/>.

DOMAIN='example.com'
REALM='EXAMPLE.COM'

#DYNDNS='--enable-dns-updates'
DYNDNS=''

MKHOMEDIR='--mkhomedir'
#MKHOMEDIR=''

FORCE_NTPD='--force-ntpd'
#FORCE_NTPD=''

#NTPD='--ntp-server=ntp_ip1 --ntp-server=ntp_ip2 --ntp-server=ntp_ip3 --ntp-server=ntp_ip4'
NTPD=''

NONTP=''
#NONTP='-N'

ENROLL_USER='hostenroll'
USER_PASSWORD='supersecret'

[[ ${NONTP} -eq '-N' ]] && FORCE_NTPD=''
[[ ${NONTP} -eq '-N' ]] && NTPD=''

INSTPCKG=''

DIGINS=$(rpm -qa | grep bind-utils | wc -l)
if [ 1 -gt ${DIGINS} ]; then
  INSTPCKG="bind-utils"
fi;

IDMC=$(rpm -qa | grep ipa-client | wc -l)

if [ 1 -gt ${IDMC} ]; then
  INSTPCKG="${INSTPCKG} ipa-client"
fi

if [ "${INSTPCKG}" != "" ]; then
  yum -e0 -y -q install ${INSTPCKG}
  if [ $? -ne 0 ]; then
    echo "Package installation failed"
    exit 3
  fi
fi

## Check if we run on RHEL 6 to update packages
RHEL=$(cat /etc/redhat-release | cut -d ' ' -f 7 | cut -d '.' -f1)
if [ 6 -eq ${RHEL} ]; then
  yum update -y -q curl libcurl nss
fi

kerb=$(dig +short TXT _kerberos.${DOMAIN})

if [ ${kerb} -eq "" ]; then
  echo "DNS is not correctly set. Exiting."
  exit 1
fi

ldaps=$(dig +short SRV _ldap._tcp.${DOMAIN} | wc -l )

if [ ${ldaps} -eq 0 ]; then
  echo "DNS is not correctly set. Exiting."
  exit 1
fi

if [ -f /var/lib/ipa-client/sysrestore/sysrestore.state ]; then
  if [ 0 -lt $(grep 'complete = True' /var/lib/ipa-client/sysrestore/sysrestore.state | wc -l) ]; then
    echo "IdM Client is already installed"
    exit 2
  fi
fi

/usr/sbin/ipa-client-install \
  -p ${ENROLL_USER} \
  -w "${USER_PASSWORD}" \
  --realm=${REALM} \
  --domain=${DOMAIN} \
  ${DYNDNS} \
  ${MKHOMEDIR} \
  ${FORCE_NTPD} \
  ${NTPD} \
  ${NONTP} \
  --unattended
