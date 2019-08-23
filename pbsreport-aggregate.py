#!/usr/bin/env python
import os
import config as cfg

def cleancsv( rawfile, csvfile ):
  n=0
  with open(rawfile) as f:
    g=open(csvfile,'w');
    for line in f:
      n=n+1;
      if n<8:
        continue;
      if line=="\n":
        break;
      g.write(line);
    f.close()
    g.close()
  return

cleancsv("pbs-report.raw."+cfg.suffix+".csv","../aggregate/archive/input/pbs-report.raw."+cfg.suffix+".csv")
