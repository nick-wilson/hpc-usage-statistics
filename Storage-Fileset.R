#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

f1<-paste0("storage-fileset-usage.",suffix,".csv")
f2<-paste0("storage-fileset-category.",suffix,".csv")

s1<-read.csv(f1)
s2<-read.csv(f2)

s3<-merge(s1,s2,all.x=TRUE,all.y=FALSE,sort=FALSE)
s3<-s3%>%filter(Fileset!="home1:users",Fileset!="home1:astar")
s3$type<-as.character(s3$type)
s3$type[is.na(s3$type)&s3$Filesystem=="home"]<-"HOME_NOT_FILESET"
s3$type[is.na(s3$type)&s3$Filesystem=="home1"]<-"DATA_NOT_PROJECT"
s3[s3$type=="HOME_PROJECTS"&s3$quota==1,"type"]<-"HOME_PROJECTS_EXPIRED"
s3[s3$Fileset=="home:csibio","type"]<-"HOME_PROJECTS_EXPIRED"
s3$type<-factor(s3$type,fileset_types)
s3$quota[s3$type=="HOME_NOT_FILESET"]<-0
s3$quota[s3$type=="HOME_PROJECTS_EXPIRED"]<-0
s3$type<-as.factor(s3$type)
s3$GB[is.na(s3$GB)]<-0
s3$quota[is.na(s3$quota)]<-0

s3<-s3%>%arrange(desc(GB))

f3<-paste0("storage-byfileset.",suffix,".csv")
write.csv(s3,file=f3,row.names=FALSE)

# Add placeholder entry so all levels are reported by summarize command
placeholder<-s3[1,]
placeholder[1,"Fileset"]<-"home:csibio"
placeholder[1,"GB"]<-0
placeholder[1,"quota"]<-0
placeholder[1,"Filesystem"]<-"home"
placeholder[1,"type"]<-"HOME_PROJECTS_CSIBIO"
s3<-rbind(s3,placeholder)

#summary<-s3%>%group_by(Filesystem,type)%>%summarize(Usage.GB=sum(GB),Quota.GB=sum(quota))%>%arrange(Filesystem,desc(Usage.GB))%>%ungroup()%>%select(-Filesystem)
summary<-s3%>%group_by(type)%>%summarize(Usage.GB=sum(GB),Quota.GB=sum(quota))
f4<-paste0("storage-byfileset-summary.",suffix,".csv")
write.csv(summary,file=f4,row.names=FALSE)
