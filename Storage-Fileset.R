#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

f1<-paste0("storage-byfileset.",suffix,".csv")
f2<-paste0("storage-fileset-category.",suffix,".csv")

s1<-read.csv(f1)
s2<-read.csv(f2)

s3<-merge(s1,s2,all.x=TRUE,all.y=FALSE,sort=FALSE)
s3<-s3%>%filter(Fileset!="home1:users",Fileset!="home1:astar")
s3$type<-as.character(s3$type)
s3$type[is.na(s3$type)&s3$Filesystem=="home"]<-"HOME_NOT_FILESET"
s3$type[is.na(s3$type)&s3$Filesystem=="home1"]<-"DATA_NOT_PROJECT"
s3[s3$type=="HOME_PROJECTS"&s3$quota==1,"type"]<-"HOME_PROJECTS_EXPIRED"
s3$quota[s3$type=="HOME_NOT_FILESET"]<-0
s3$quota[s3$type=="HOME_PROJECTS_EXPIRED"]<-0
s3$type<-as.factor(s3$type)
s3$GB[is.na(s3$GB)]<-0
s3$quota[is.na(s3$quota)]<-0

summary<-s3%>%group_by(type)%>%summarize(Usage.GB=sum(GB),Quota.GB=sum(quota))%>%arrange(desc(Usage.GB))

f3<-paste0("storage-byfileset-summary.",suffix,".csv")
write.csv(summary,file=f3,row.names=FALSE)