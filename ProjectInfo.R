#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

pfile<-paste0('project_walltime.',suffix,'.csv')
p<-read.csv(pfile)
p<-subset(p,select=-X)

ifile<-paste0('project-info.',suffix,'.csv')
i<-read.csv(ifile)

q<-merge(p,i,all.x=TRUE,all.y=FALSE,sort=FALSE)
q$Project.Name<-as.character(q$Project.Name)
q$Project.Name[is.na(q$Project.Name)]<-""
q$Project.Requestor<-as.character(q$Project.Requestor)
q$Project.Requestor[is.na(q$Project.Requestor)]<-""

r<-q%>%arrange(desc(CoreHours),desc(home_gb))
#r$Project_Short<-gsub('(A.STAR-|NUS-|Industry-|NTU-|SUTD-|SMU-)','',r$Project)
r<-r%>%select(-Project_Short)
r$home_gb[r$home_gb==-1]<-""

ofile<-paste0('project_walltime_info.',suffix,'.csv')
write.csv(r,file=ofile)
