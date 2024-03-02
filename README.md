# ADCSink
A little and dirty bash script to add ESC1 on a certificate template and retrieve NT&amp;LM hashes using UnPAC the hash method. 

This script needs the tool Certipy to be installed to work :). 

## Usage 

	./ADCSink.sh username domain password template_name target_ca ca_name dc-ip users_file  


## Common Errors 

KDC_ERR_PADATA_TYPE_NOSUPP : It is not possible to authenticate using Kerberos (therefore UnPAC the hash method cannot be used). More information: https://offsec.almond.consulting/authenticating-with-certificates-when-pkinit-is-not-supported.html 

