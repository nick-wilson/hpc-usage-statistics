#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

load("data.Rdata")

bkup_data<-data
am<-read.csv(file="am-jobs.csv")
bkup_am<-am

am<-am%>%select(Job.ID,AM.cpu_hrs,AM.dgx_hrs)
am$Job.ID<-gsub(".wlm01","",am$Job.ID)

data<-data%>%filter(Node.Type!="DGX")
data<-merge(data,am,all.x=TRUE,all.y=FALSE,sort=FALSE)

write.csv(data,file=paste0("alldata+am.",suffix,".csv"),row.names=FALSE)

data$diff<-abs(data$AM.cpu_hrs-data$CoreHours)
big<-data%>%filter(diff>20.0)
print(big%>%select(Job.ID,Username,diff,AM.cpu_hrs,CoreHours,Wall.Time.Hours,Cores))
