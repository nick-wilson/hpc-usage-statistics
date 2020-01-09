#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

load(alldata_R)

bkup_data<-data
am<-read.csv(file=paste0("am-jobs.",suffix,".csv"))
bkup_am<-am

am<-am%>%select(Job.ID,AM.cpu_hrs,AM.dgx_hrs)
am$Job.ID<-gsub(".wlm01","",am$Job.ID)

data<-merge(data,am,all.x=TRUE,all.y=FALSE,sort=FALSE)
save(data,file=paste0("data+am.",suffix,".Rdata"))

data<-data%>%filter(Node.Type!="DGX")
write.csv(data,file=paste0("alldata+am.",suffix,".csv"),row.names=FALSE)

data<-data%>%select(Job.ID,Username,Queue,Cores,Wall.Time.Hours,CoreHours,AM.cpu_hrs)
data$diff<-data$AM.cpu_hrs-data$CoreHours
data<-na.omit(data)

big<-data%>%filter(abs(diff)>10.0)%>%arrange(desc(diff))
print(big)
write.csv(big,file=paste0("am-discrepancy.",suffix,".csv"),row.names=FALSE)
