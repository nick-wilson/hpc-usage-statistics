#!/usr/bin/env python
import os
import config as cfg

rawfile="production.pbs-report.raw."+cfg.suffix+".csv"
csvfile="production.pbs-report.cleaned."+cfg.suffix+".csv"

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
    g.write(line);
  f.close()
  g.close()
