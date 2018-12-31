#!/bin/bash
# 

DATE=`date +%Y%m%d`
REPORTDIR=/reports/${DATE}.d
LOGDIR=/var/log/apache2

errorexit() {
	echo $1
	exit 4
}

####

mkdir $REPORTDIR || errorexit "reportdir already exists"

(cd $LOGDIR; ls -tr access.log* | tail -32 > /tmp/filelist)

[ -f /tmp/filelist ] || errorexit "filelist does not exist" 
[ -d $REPORTDIR ] || errorexit "Reportdir does not exist"

for file in `cat /tmp/filelist`
do
    cp -p $LOGDIR/$file $REPORTDIR/
done

cd $REPORTDIR || errorexit "Unable to change directory to $REPORTDIR"
echo "unzipping files"
gunzip *.gz

ls access.log* > /dev/null || errorexit "No httpd Access Files Exist, exiting"

if [ -d results ] 
then
  errorexit  "results directory already exists, exiting"
fi
	
mkdir results
echo "Generating results from access.log*"

if [ ! -f all ]
then
  cat access.log* > all 
fi 

echo -n "Total all non-bot: "
cat all | grep "jpg" | grep -v bot |  awk '{print $1}' | sort | uniq > results/total-uniq-non-bot
wc -l results/total-uniq-non-bot
cat all | grep "jpg" | grep -v bot | grep -i google > results/google.txt
echo -n "Total Google hits: "
cat results/google.txt | awk '{print $7}' | wc -l
echo -n "Total Google jpg hits: "
cat results/google.txt | awk '{print $7}' | grep jpg | wc -l
echo "Creating Google search results by jpg count per image... google-search-top-image-results"
cat results/google.txt | awk '{print $7}' | grep jpg | sort | uniq -c | sort -n  > results/google-search-top-image-results
echo -n "Creating facebook results - unique users "
cat all | grep "jpg" | grep -v bot | grep -i facebook | awk '{print $1}' | sort | uniq > results/facebookusers.txt
wc -l results/facebookusers.txt
echo -n "Creating google results - unique users "
cat all | grep "jpg" | grep -v bot | grep -i google  | awk '{print $1}' | sort | uniq > results/googleusers.txt
wc -l results/googleusers.txt
echo -n "Creating mobile results - unique users "
cat all | grep "jpg" | grep -v bot | egrep -i "phone|android|samsung|galaxy"  | awk '{print $1}' | sort | uniq > results/phoneusers.txt
wc -l results/phoneusers.txt
