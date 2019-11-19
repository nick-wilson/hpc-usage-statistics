#!/usr/bin/env python
import os
import config as cfg

def cleancsv( rawfile, csvfile ):
  n=0
  with open(rawfile) as f:
    g=open(csvfile,'w');
    for line in f:
      n=n+1;
      if n<6:
        continue;
      if line=="\n":
        break;
      npipe=line.count("|");
      if (npipe!=14)and(n>6):
        # replace all pipe characters from start of line to end of job name
        line=line.replace("|", "%",npipe-11)
        # put first three field separators back
        line=line.replace("%", "|",3)
      line=line.replace(",","_")
      g.write(line);
    f.close()
    g.close()
  return

cleancsv("pbs-report.raw."+cfg.suffix+".csv","pbs-report.cleaned."+cfg.suffix+".csv")
cleancsv("pbs-report.raw.partial."+cfg.suffix+".csv","pbs-report.cleaned.partial."+cfg.suffix+".csv")

