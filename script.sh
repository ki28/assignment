#!/bin/bash
s3bucket="s3://bashassignment-bucket"
echo "please provide below details to check old files in s3 bucket"
read -p "retention days: " retentionday
if [[ ! $retentionday =~ ^[0-9]+$ ]];
then 
	echo "please enter a numerical value"
	exit
fi
read -p "prfix for file name to be searched for: " prefix
read -p "path where file should be find: " path
rm -rf old_files.txt json_files.txt >/dev/null 2>&1
aws s3 ls $s3bucket/$path/ >/dev/null
if [[ $? == 0 ]]
then
#aws s3 ls $s3bucket/$path/ |  while read -r line;
cat check.txt |  while read -r line;
do
	creationdate=`echo $line|awk {'print $1" "$2'}`
	Creation_date=`date -d"$creationdate" +%s`
	days_older=`date -d "$retentionday days ago" +%s`
	if [[ $Creation_date -lt $days_older ]]
	then
		file=`echo $line|awk {'print $4'}`
		echo $file >> old_files.txt
	fi
done
ls -l old_files.txt >/dev/null 2>&1
if [[ $? -eq 0 ]]
	then
		cat old_files.txt | grep "$prefix" > json_files.txt
echo list of all filesto be deleted-  `cat old_files.txt`
echo "list of files with provided prefix due to be deleted- `cat json_files.txt`"
else 
	echo "No old file exists"
fi
else
	echo "No such path exists"
fi

