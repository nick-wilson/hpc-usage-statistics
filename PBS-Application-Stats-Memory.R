#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)

coremem<-paste0("coremem.",suffix,".csv")
virtualmem<-paste0("virtualmem.",suffix,".csv")

core1<-data[data$Cores=="1",]

core1$cmem<-as.numeric(gsub("kb","",core1$Core.Memory))
core1$vmem<-as.numeric(gsub("kb","",core1$Virtual.Memory))

memsizes<-c("0-1GB","1-2GB","2-3GB","3-4GB","4-5GB","5-6GB","6-7GB","7-8GB","8-12GB","12-16GB",">16GB")

core1$virtualmemgb<-"NA"
core1[core1$vmem>16e6,"virtualmemgb"]<-">16GB"
core1[core1$vmem<=16e6,"virtualmemgb"]<-"12-16GB"
core1[core1$vmem<=12e6,"virtualmemgb"]<-"8-12GB"
core1[core1$vmem<=8e6,"virtualmemgb"]<-"7-8GB"
core1[core1$vmem<=7e6,"virtualmemgb"]<-"6-7GB"
core1[core1$vmem<=6e6,"virtualmemgb"]<-"5-6GB"
core1[core1$vmem<=5e6,"virtualmemgb"]<-"4-5GB"
core1[core1$vmem<=4e6,"virtualmemgb"]<-"3-4GB"
core1[core1$vmem<=3e6,"virtualmemgb"]<-"2-3GB"
core1[core1$vmem<=2e6,"virtualmemgb"]<-"1-2GB"
core1[core1$vmem<=1e6,"virtualmemgb"]<-"0-1GB"
core1$virtualmemgb<-factor(core1$virtualmemgb,memsizes)
tmpdata<-core1%>%group_by(virtualmemgb)%>%summarise(NumJobs=length(Job.ID),CoreHours=sum(CoreHours))
write.csv(tmpdata,virtualmem)

core1$corememgb<-"NA"
core1[core1$cmem>16e6,"corememgb"]<-">16GB"
core1[core1$cmem<=16e6,"corememgb"]<-"12-16GB"
core1[core1$cmem<=12e6,"corememgb"]<-"8-12GB"
core1[core1$cmem<=8e6,"corememgb"]<-"7-8GB"
core1[core1$cmem<=7e6,"corememgb"]<-"6-7GB"
core1[core1$cmem<=6e6,"corememgb"]<-"5-6GB"
core1[core1$cmem<=5e6,"corememgb"]<-"4-5GB"
core1[core1$cmem<=4e6,"corememgb"]<-"3-4GB"
core1[core1$cmem<=3e6,"corememgb"]<-"2-3GB"
core1[core1$cmem<=2e6,"corememgb"]<-"1-2GB"
core1[core1$cmem<=1e6,"corememgb"]<-"0-1GB"
core1$corememgb<-factor(core1$corememgb,memsizes)
tmpdata<-core1%>%group_by(corememgb)%>%summarise(NumJobs=length(Job.ID),CoreHours=sum(CoreHours))
write.csv(tmpdata,coremem)
