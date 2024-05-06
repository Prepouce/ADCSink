# ADCSink

A quick and dirty bash script to POC a "NTDS dumping" technique. 
It modifies a certificate template in order to add an ESC1 vulnerability and retrieve NT&amp;LM hashes using UnPAC-the-hash method. 

This script is based on [Certipy](https://github.com/ly4k/Certipy) :D, you should installed it before running the script.

```text
pip3 install certipy-ad
```

## Usage

```text
./ADCSink.sh
Options:
  -u TEXT                | Compromised account's username (required)
  -d TEXT                | Targeted domain (required)
  -T TEXT                | Vulnerable template or template to make vulnerable (required)
  -t TEXT                | Targeted server hosting the ADCS component (required)
  -c TEXT                | Name of the targeted CA (required)
  -i TEXT                | Domain controller's IP address (required)
  -U TEXT                | List of targeted users (required)
  -p TEXT                | Compromised account's password (required if no hash is specified)
  -H TEXT                | Compromised account's NT hash (required if no hash is specified)
  -s                     | No template modifications are be made 
```
The "-s" options could be added if you do not need / want to modify the certifiate template (exemple: you already had an ESC1 vulnerability)

## Similar projects

[ADCsync](https://github.com/JPG0mez/ADCSync/blob/main/adcsync.py)


## Common Errors

KDC_ERR_PADATA_TYPE_NOSUPP : It is not possible to authenticate using Kerberos (therefore UnPAC the hash method cannot be used). 
More information: https://offsec.almond.consulting/authenticating-with-certificates-when-pkinit-is-not-supported.html 

