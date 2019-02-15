#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

if (!exists("dgx_on")) {dgx_on<-1}

openpng<-function(filename){
  png(filename,width=854,height=544)
  #par(mar=c(8.1,4.1,4.1,2.1))
}

makeboxplot_bycore<-function(data,main,outline) {
  ylabel<-"Wait Time / hour"
  xlabel<-"Cores"
  boxplot(Wait.Time.Hours~CoresGroup,data=data,las=2,main=main,ylab=ylabel,outline=outline)
}

makeboxplot_byqueue<-function(data,main,outline) {
  ylabel<-"Wait Time / hour"
  xlabel<-"Queue"
  if (dgx_on==1){
  # larger margins for DGX queues
    par(mar=c(7.5, 5, 5, 5))
  }
  boxplot(Wait.Time.Hours~Queue,data=data,las=2,main=main,ylab=ylabel,outline=outline)
}

# Load cleaned data
load(file=alldata_R)
load(file=users_R)

if (filter_dependent_jobs==1) {
bkupdata_prefilter<-data
filename<-paste0("depend.",suffix,".csv")
depend<-read.csv(file=filename,header=TRUE,col.names=c("Job.ID.NoIndex","Dependency"),colClasses=c("character","logical"))
data<-merge(data,depend,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$Dependency[is.na(data$Dependency)]<-FALSE
data<-data%>%filter(Dependency==FALSE)
}
bkupdata<-data

if (dgx_on==1){
  data<-data%>%filter(Queue=="dev"|Queue=="small"|Queue=="medium"|Queue=="normal"|Queue=="long"|Queue=="q1"|Queue=="q4"|Queue=="largemem"|Queue=="production"|Queue=="paidq"|Queue=="vis"|Queue=="iworkq"|Queue=="gpunormal"|Queue=="gpulong"|Queue=="dgx-03g-04h"|Queue=="dgx-03g-24h"|Queue=="dgx-03g-48h"|Queue=="dgx-48g-04h"|Queue=="dgx-48g-24h"|Queue=="dgx-48g-48h")
} else {
  data<-data%>%filter(Queue=="dev"|Queue=="small"|Queue=="medium"|Queue=="normal"|Queue=="long"|Queue=="q1"|Queue=="q4"|Queue=="largemem"|Queue=="production"|Queue=="paidq"|Queue=="vis"|Queue=="iworkq"|Queue=="gpunormal"|Queue=="gpulong")
}

data$Queue<-factor(data$Queue)
data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)

outline<-TRUE
file_outliers<-"+outliers"
filename<-paste0("wait_byqueue",file_outliers,".",suffix,".png")
openpng(filename)
main<-paste("Queue wait times (",suffix,")")
makeboxplot_byqueue(data,main,outline)
dev.off()

outline<-FALSE
file_outliers<-"-outliers"
filename<-paste0("wait_byqueue",file_outliers,".",suffix,".png")
openpng(filename)
main<-paste0("Queue wait times (",suffix,")\n outliers removed")
makeboxplot_byqueue(data,main,outline)
dev.off()

outline<-TRUE
file_outliers<-"+outliers"
filename<-paste0("wait_bycore_cpu",file_outliers,".",suffix,".png")
openpng(filename)
main<-paste("CPU Queue wait times (",suffix,")")
data<-bkupdata%>%filter(Node.Type=="CPU")
data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)
makeboxplot_bycore(data,main,outline)
dev.off()
data<-bkupdata

outline<-FALSE
file_outliers<-"-outliers"
filename<-paste0("wait_bycore_cpu",file_outliers,".",suffix,".png")
openpng(filename)
main<-paste0("CPU Queue wait times (",suffix,")\n outliers removed")
data<-bkupdata%>%filter(Node.Type=="CPU")
data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)
makeboxplot_bycore(data,main,outline)
dev.off()
data<-bkupdata

outline<-TRUE
title_outliers<-""
file_outliers<-"+outliers"
filename<-paste0("wait_byqueue_bycore_cpu",file_outliers,".",suffix,".png")
openpng(filename)
par(mfrow=c(2,3))
for (q in c("dev","medium","q1","q4","long")) {
  data<-bkupdata
  data$Queue<-factor(data$Queue,c("dev","small","medium","q1","q4","long"))
  data<-data%>%filter(Queue==q)
  data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)
  main<-paste0("CPU Queue wait times for ",q,title_outliers)
  makeboxplot_bycore(data,main,outline)
}
dev.off()

outline<-FALSE
title_outliers<-"\n(outliers removed)"
file_outliers<-"-outliers"
filename<-paste0("wait_byqueue_bycore_cpu",file_outliers,".",suffix,".png")
openpng(filename)
par(mfrow=c(2,3))
for (q in c("dev","medium","q1","q4","long")) {
  data<-bkupdata
  data$Queue<-factor(data$Queue,c("dev","small","medium","q1","q4","long"))
  data<-data%>%filter(Queue==q)
  data$CoresGroup<-factor(data$CoresGroup,coresgroup_sort)
  main<-paste0("CPU Queue wait times for ",q,title_outliers)
  makeboxplot_bycore(data,main,outline)
}
dev.off()

gpudata<-bkupdata%>%filter(Node.Type=="GPU")
gpudata[gpudata$CoresGroup=="24","CoresGroup"]<-"1"
gpudata[gpudata$CoresGroup=="25-96","CoresGroup"]<-"2 - 4"
gpudata[gpudata$CoresGroup=="97-240","CoresGroup"]<-"5 - 10"
gpudata[gpudata$CoresGroup=="241-960","CoresGroup"]<-"11 - 40"
gpudata[gpudata$CoresGroup==">960","CoresGroup"]<-"> 40"
#gpudata$CoresGroup<-factor(gpudata$CoresGroup,c("1","2 - 4","5 - 10","11 - 40","> 40"))
gpudata$CoresGroup<-factor(gpudata$CoresGroup,c("1","2 - 4","5 - 10","11 - 40"))

outline<-TRUE
file_outliers<-"+outliers"
title_outliers<-""
filename<-paste0("wait_bycore_gpu",file_outliers,".",suffix,".png")
openpng(filename)
main<-paste0("GPU Queue wait times (",suffix,")",title_outliers)
data<-gpudata
makeboxplot_bycore(data,main,outline)
dev.off()

outline<-FALSE
file_outliers<-"-outliers"
title_outliers<-"\n(outliers removed)"
filename<-paste0("wait_bycore_gpu",file_outliers,".",suffix,".png")
openpng(filename)
main<-paste0("GPU Queue wait times (",suffix,")",title_outliers)
data<-gpudata
makeboxplot_bycore(data,main,outline)
dev.off()

outline<-TRUE
file_outliers<-"+outliers"
title_outliers<-""
filename<-paste0("wait_byqueue_bycore_gpu",file_outliers,".",suffix,".png")
openpng(filename)
par(mfrow=c(1,2))
for (q in c("gpunormal","gpulong")) {
  data<-gpudata%>%filter(Queue==q)
  main<-paste0("GPU Queue wait times for ",q,title_outliers)
  makeboxplot_bycore(data,main,outline)
}
dev.off()

outline<-FALSE
file_outliers<-"-outliers"
title_outliers<-"\n(outliers removed)"
filename<-paste0("wait_byqueue_bycore_gpu",file_outliers,".",suffix,".png")
openpng(filename)
par(mfrow=c(1,2))
for (q in c("gpunormal","gpulong")) {
  data<-gpudata%>%filter(Queue==q)
  main<-paste0("GPU Queue wait times for ",q,title_outliers)
  makeboxplot_bycore(data,main,outline)
}
dev.off()
