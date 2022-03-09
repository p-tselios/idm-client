# idm-client
Scripts for the automated installation of ipa-client on RHEL servers.

In order to run this script you need to perform the following modifications: 

DOMAIN::
  This variable holds the domain that you use

RHELM::
  This is your REALM, in capital letters

DYNDNS::
  If you have installed IdM with the embedded DNS, you want to enable this option so as the host DNS records are automatically added to IdM. Default is disabled ('')

FORCE_NTPD::
  The default NTP daemon for RHEL 7 is chrony. However, IdM on a RHEL 7 is not compatible with chrony. If the clients use chrony, that should be disabled and use NTP instead. Provided that the ntp package is a requirement of `ipa-client`, we can use use this option so as to disable chrony and use ntpd instead.
  If we already have ntpd as our NTP client, we can disable this variable.

NTPD::
  This variable is the list of **all** NTP servers that the IdM client synchronizes to. For **each** server we need to add the `--ntp-server=` option and the value should be an IP. If we don't want to configure the NTP client on the server, we disable this variable and we enable the NONTP.

NONTP::
  If we already have ntpd configured and running on a server, we can skip it's configuration by using the option '-N'. Setting this variable to '-N' will disable the rest of the NTP variables.

MKHOMEDIR::
  We can ask from IdM clients to automatically create the home directories of users upon their first login.
  The default value is to enable this option.

WARNING: The script does not support autofs options. 
