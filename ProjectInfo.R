#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

pfile<-paste0('project_walltime.',suffix,'.csv')
p<-read.csv(pfile)
p<-subset(p,select=-X)

ifile<-paste0('project-info.',suffix,'.csv')
i<-read.csv(ifile)

q<-merge(p,i,all.x=TRUE,all.y=FALSE,sort=FALSE)
q$Project_Name<-as.character(q$Project_Name)
q$Project_Name[is.na(q$Project_Name)]<-""
q$PI<-as.character(q$PI)
q$PI[is.na(q$PI)]<-""

r<-q%>%arrange(desc(CoreHours),desc(home_gb))
#r$Project_Short<-gsub('(A.STAR-|NUS-|Industry-|NTU-|SUTD-|SMU-)','',r$Project)
r<-r%>%select(-Project_Short)
r$home_gb[r$home_gb==-1]<-""

ofile<-paste0('project_walltime_info.',suffix,'.csv')
write.csv(r,file=ofile)
