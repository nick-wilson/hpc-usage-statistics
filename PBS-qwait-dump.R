#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)

qwait<-data%>%select(Job.ID,Queue,Wait.Time.Hours)
qwait$suffix<-suffix

save(qwait,file=paste0("qwait.",suffix,".Rdata"))