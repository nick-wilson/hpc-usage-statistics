#!/usr/bin/env Rscript
library(dplyr,warn.conflicts=FALSE)
source("config.R")
suffix<-"20160901-20160930"

# Edit following section for different filters
filter<-"NTU"
load(file='data.Rdata')
data<-data%>%filter(Organization==filter)

alldata<-paste0("alldata.",filter,".",suffix,".csv")
userdata<-paste0("user_walltime.",filter,".",suffix,".csv")
app_by_user<-paste0("application_by_user.",filter,".",suffix,".csv")
orgdata<-paste0("org_walltime.",filter,".",suffix,".csv")
appcpu<-paste0("application_usage_cpu.",filter,".",suffix,".csv")
appgpu<-paste0("application_usage_gpu.",filter,".",suffix,".csv")

writedata<-data
colnames(writedata)<-c("Username","JobID","Job.ID","Queue","Job.Name","Date.Created","Package","Cores","Nodes","Memory","Memory.1","CPU.Time","Wall.Time","Wait.Time","Suspend.Time","Exit.Code","Node.Type","CoreHours","Application.Name","Name","Organization")
write.csv(writedata,file=alldata,row.names=FALSE)

load(file='users.Rdata')
user_corehours<-data%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
user_corehours<-merge(user_corehours,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(user_corehours)<-c("Username","CoreHours","NumJobs","Name","Organization")
user_corehours<-arrange(user_corehours,desc(CoreHours))
user_corehours<-user_corehours[,c(1,4,5,2,3)]
write.csv(user_corehours,file=userdata)

app_by_user_corehours<-data%>%group_by(Username,Application.Name)%>%summarise(sum(CoreHours),length(Job.ID))
app_by_user_corehours<-merge(app_by_user_corehours,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
app_by_user_corehours<-app_by_user_corehours[,c(2,1,5,6,3,4)]
colnames(app_by_user_corehours)<-c("Application","Username","Name","Organization","CoreHours","NumJobs")
app_by_user_corehours<-app_by_user_corehours%>%arrange(Application,CoreHours)
write.csv(app_by_user_corehours,file=app_by_user,row.names=FALSE)

df1<-data%>%filter(Q=="CPU")%>%group_by(Application.Name,Username)%>%summarize(sum(CoreHours),length(Job.ID))
colnames(df1)<-c("Application.Name","Username","CoreHours","NumJobs")
df1<-df1%>%group_by(Application.Name)%>%summarize(sum(CoreHours),sum(NumJobs),length(Username))
colnames(df1)<-c("Application.Name","CoreHours","NumJobs","NumUsers")
df1<-arrange(df1,desc(CoreHours))
write.csv(df1,file=appcpu)

df1<-data%>%filter(Q=="GPU")%>%group_by(Application.Name,Username)%>%summarize(sum(CoreHours),length(Job.ID))
colnames(df1)<-c("Application.Name","Username","CoreHours","NumJobs")
df1<-df1%>%group_by(Application.Name)%>%summarize(sum(CoreHours),sum(NumJobs),length(Username))
colnames(df1)<-c("Application.Name","CoreHours","NumJobs","NumUsers")
df1<-arrange(df1,desc(CoreHours))
write.csv(df1,file=appgpu)

org_corehours<-data%>%group_by(Organization)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(org_corehours)<-c("Organization","CoreHours","NumJobs")
org_corehours<-arrange(org_corehours,desc(CoreHours))
write.csv(org_corehours,file=orgdata)
