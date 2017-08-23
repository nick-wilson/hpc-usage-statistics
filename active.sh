#!/bin/sh
. ./config
csv1=active.$suffix.csv
csv2=active-totals.$suffix.csv

echo
echo calculating number of active users
. ./config
cat user_walltime_* | awk -F, '{print $2}' | grep -v Username | sed -e 's,",,g' | sort | uniq | while read u ; do grep ^\"$u\" alldata.$suffix.csv | head -1 ; done | awk -F, '{print $1,$29}' > "$csv1"
rm -f "$csv2"
for s in A.STAR NTU NUS CREATE SMU SUTD Industry Other ; do
echo $s , `grep -c \"$s\" "$csv1"` | tee -a "$csv2"
done
wc -l "$csv1" | awk '{printf "Total , %d\n",$1}' | tee -a "$csv2"
