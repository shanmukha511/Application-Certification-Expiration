#!/bin/bash

unset seven_days_expiration
unset fifteen_days_expiration
unset thirty_days_expiration

declare -a seven_days_expiration
declare -a fifteen_days_expiration
declare -a thirty_days_expiration


while IFS= read -r line || [ -n "$line" ];
do
        echo "Checking Certificate Expiration Date for $line" 
	certificate_file=$(mktemp)
	echo -n | openssl s_client -connect "$line" 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $certificate_file
	date=$(openssl x509 -in $certificate_file -enddate -noout | sed "s/.*=\(.*\)/\1/")
	date_s=$(date -d "${date}" +%s)
	now_s=$(date -d now +%s)
	date_diff=$(( (date_s - now_s) / 86400 ))
	if [ $date_diff -eq 72 ];then
	seven_days_expiration+=("$line,")
	elif [ $date_diff -eq 52 ];then
	fifteen_days_expiration+=("$line,")
	elif [ $date_diff -eq 68 ];then
	thirty_days_expiration+=("$line,")
	fi
	rm "$certificate_file"
done < Application-Urls.txt

	if  [[ ${seven_days_expiration[@]} ]]; then
	echo "${seven_days_expiration[*]}" | sed 's/.$//' > seven_days_expiration.txt
	seven_days_expiration=`cat seven_days_expiration.txt`
    	echo "The Application URLS $seven_days_expiration certificates will expire in 73 days"
	fi
	if  [[ ${fifteen_days_expiration[@]} ]]; then
	echo "${fifteen_days_expiration[*]}" | sed 's/.$//' > fifteen_days_expiration.txt
	fifteen_days_expiration=`cat fifteen_days_expiration.txt`
    	echo "The Application URLS ${fifteen_days_expiration} certificates will expire in 53 days"
        
	fi
	if  [[ ${thirty_days_expiration[@]} ]]; then
        echo "${thirty_days_expiration[*]}" | sed 's/.$//'> thirty_days_expiration.txt
	thirty_days_expiration=`cat thirty_days_expiration.txt`
    	echo "The Application URLS ${thirty_days_expiration}  certificates will expire in 69 days"
	fi
