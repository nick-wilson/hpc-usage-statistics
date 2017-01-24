#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

maintitle<-paste("Queue wait times (",suffix,")")
ylabel<-"Wait Time / hour"

# Load cleaned data
load(file=alldata_R)
load(file=users_R)

title_outliers<-""
file_outliers<-"+outliers"
filename<-paste0("wait_byqueue",file_outliers,".",suffix,".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
boxplot(Wait.Time.Hours~Queue,data=data,las=2,main=maintitle,ylab=ylabel)
dev.off()
data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)
filename<-paste0("wait_bycore_cpu+outliers.",suffix,".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
par(mfrow=c(2,3))
for (q in c("dev","small","medium","q1","q4","long")) {
 d<-data%>%filter(Queue==q)
 boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main=paste0("Queue wait times for ",q),ylab=ylabel)
}
dev.off()
filename<-paste0("wait_bycore_gpu+outliers.",suffix,".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
par(mfrow=c(1,2))
d<-data%>%filter(Queue=="gpunormal")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for gpunormal",ylab=ylabel)
d<-data%>%filter(Queue=="gpulong")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for gpulong",ylab=ylabel)
dev.off()


outline<-FALSE
title_outliers<-"\n(outliers removed)"
file_outliers<-"-outliers"
filename<-paste0("wait_byqueue",file_outliers,".",suffix,".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
boxplot(Wait.Time.Hours~Queue,data=data,las=2,main=paste0(maintitle,title_outliers),ylab=ylabel,outline=outline)
dev.off()
data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)
filename<-paste0("wait_bycore_cpu-outliers.",suffix,".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
par(mfrow=c(2,3))
for (q in c("dev","small","medium","q1","q4","long")) {
 d<-data%>%filter(Queue==q)
 boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main=paste0("Queue wait times for ",q,title_outliers),ylab=ylabel,outline=outline)
}
dev.off()
filename<-paste0("wait_bycore_gpu-outliers.",suffix,".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
par(mfrow=c(1,2))
for (q in c("gpunormal","gpulong")) {
 d<-data%>%filter(Queue==q)
 boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main=paste0("Queue wait times for ",q,title_outliers),ylab=ylabel,outline=outline)
}
dev.off()
