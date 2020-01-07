#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)

filename<-paste0("depend.",suffix,".csv")
depend<-read.csv(file=filename,header=TRUE,col.names=c("Job.ID.NoIndex","Dependency"),colClasses=c("character","logical"))
data<-merge(data,depend,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$Dependency[is.na(data$Dependency)]<-FALSE
data<-data%>%filter(Dependency==FALSE)

qwait<-data%>%select(Job.ID,Queue,Wait.Time.Hours)
qwait$suffix<-suffix

save(qwait,file=paste0("qwait.",suffix,".Rdata"))
