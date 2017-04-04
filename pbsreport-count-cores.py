#!/usr/bin/env python
import os
import config as cfg
import csv
import re

csvfile="pbs-report.cleaned."+cfg.suffix+".csv"
csvcores="cores."+cfg.suffix+".csv"

with open(csvfile, 'rb') as csvfile_in:
  csvfile_out=open(csvcores, 'w')
  pbsreader = csv.reader(csvfile_in, delimiter='|')
  pbswriter = csv.writer(csvfile_out, delimiter=',')
  pbswriter.writerow(["Job.ID","Cores"])
  rownum=0
  for row in pbsreader:
    rownum=rownum+1
    if rownum <= 2:
      continue
    id=row[0]
    string=row[6]
    # count any number of cores on gpu as 24
    parsed=string
    #print string
    if row[2] == "q1":
     parsed=re.sub("gpu[0-9]+(|-ib0)/[0-9]+\*","",parsed)
     parsed=re.sub("gpu[0-9]+(|-ib0)/[0-9]+","1",parsed)
    else:
     parsed=re.sub("gpu[0-9]+(|-ib0)/[0-9]+\*[0-9]+","24",parsed)
     parsed=re.sub("gpu[0-9]+(|-ib0)/[0-9]+","24",parsed)
    parsed=re.sub("(std|lmn|vis|wlm)[0-9]+(|-ib0)/[0-9]+\*","",parsed)
    parsed=re.sub("(std|lmn|vis|wlm)[0-9]+(|-ib0)/[0-9]+","1",parsed)
    #print parsed
    cores=parsed.split('+')
    totalcores=0
    for core in cores:
     totalcores=totalcores+int(core)
    pbswriter.writerow([id,totalcores])
  csvfile_in.close()
  csvfile_out.close()
