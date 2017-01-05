#!/usr/bin/env Rscript

library(dplyr,warn.conflicts=FALSE)
alldata_R<-'data.Rdata'

# Load cleaned data
load(file=alldata_R)

tmpdata<-data%>%filter(Node.Type=="CPU")
tmpdata<-tmpdata%>%filter(Cores<24)
tmpdata<-tmpdata%>%filter(Queue!="production")
tmpdata<-tmpdata%>%filter(Queue!="paidq")

tmpdata<-tmpdata%>%summarise(length(Job.ID),sum(CoreHours))

stats_by_core_cpu<-"stats_1node.csv"
write.csv(tmpdata,file=stats_by_core_cpu,row.names=FALSE)
tmpdata
rm(tmpdata)
