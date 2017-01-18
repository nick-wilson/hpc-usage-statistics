#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

maintitle<-"Queue wait times from 2017-01-01 to 2017-01-18"
titlezoom<-paste0(maintitle,"\n(y axis zoomed)")
ylabel<-"Wait Time / hour"

# Load cleaned data
load(file=alldata_R)
load(file=users_R)
i<-0

i<-i+1
filename<-paste0("pbs_wait_",as.character(i),".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
boxplot(Wait.Time.Hours~Queue,data=data,las=2,main=maintitle,ylab=ylabel)
dev.off()

i<-i+1
filename<-paste0("pbs_wait_",as.character(i),".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
boxplot(Wait.Time.Hours~Queue,data=data,las=2,main=titlezoom,ylab=ylabel,ylim=c(0,200))
dev.off()

data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)

i<-i+1
filename<-paste0("pbs_wait_",as.character(i),".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
par(mfrow=c(2,3))
d<-data%>%filter(Queue=="dev")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for dev",ylab=ylabel,ylim=c(0,50))
d<-data%>%filter(Queue=="small")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for small",ylab=ylabel)
d<-data%>%filter(Queue=="medium")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for medium",ylab=ylabel)
d<-data%>%filter(Queue=="q1")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for q1",ylab=ylabel)
d<-data%>%filter(Queue=="q4")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for q4",ylab=ylabel)
d<-data%>%filter(Queue=="long")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for long",ylab=ylabel)
dev.off()

i<-i+1
filename<-paste0("pbs_wait_",as.character(i),".png")
png(filename,width=854,height=544)
par(mar=c(8.1,4.1,4.1,2.1))
par(mfrow=c(1,2))
d<-data%>%filter(Queue=="gpunormal")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for gpunormal",ylab=ylabel)
d<-data%>%filter(Queue=="gpulong")
boxplot(Wait.Time.Hours~CoresGroup,data=d,las=2,main="Queue wait times for gpulong",ylab=ylabel)
dev.off()