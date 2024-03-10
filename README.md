# ADCSink
A little and dirty bash script to POC a "NTDS dumping" technique. to do so, it adds an ESC1 vulnerability on a certificate template and retrieve NT&amp;LM hashes using UnPAC the hash method. 

This script needs the tool Certipy to be installed to work :D. 

## Usage 

	./ADCSink.sh -u username -d domain -T template_name -t targeted_ca -c ca_name -i dc-ip -U targeted_users [-p password] [-H hash]


## Common Errors 

KDC_ERR_PADATA_TYPE_NOSUPP : It is not possible to authenticate using Kerberos (therefore UnPAC the hash method cannot be used). More information: https://offsec.almond.consulting/authenticating-with-certificates-when-pkinit-is-not-supported.html 

