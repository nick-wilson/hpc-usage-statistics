#!/usr/bin/env Rscript

source("config.R")

pbsreport<-paste0("pbs-report.final.",suffix,".csv")
apps<-paste0("alljobs.",suffix,".csv")

alldata<-paste0("alldata.",suffix,".csv")
userdata<-paste0("user_walltime.",suffix,".csv")
app_by_user<-paste0("application_by_user.",suffix,".csv")
orgdata<-paste0("org_walltime.",suffix,".csv")
appcpu<-paste0("application_usage_cpu.",suffix,".csv")
appgpu<-paste0("application_usage_gpu.",suffix,".csv")
top100<-paste0("top100.",suffix,".csv")

library(dplyr,warn.conflicts=FALSE)

data<-read.csv(file=pbsreport,header=TRUE,sep="|",skip=1)
data$JobIDm<-gsub('\\[\\d+\\]','[]',data$Job.ID)
data$Q<-"CPU"
data$Q[data$Queue=="gpunormal"]<-"GPU"
data$Q[data$Queue=="gpulong"]<-"GPU"
data$CoreHours<-as.numeric(data$Host.s.)*as.numeric(data$Wall.Time)/3600.0

jobnames<-read.csv(file=apps,header=FALSE,colClasses="character")
colnames(jobnames)<-c("JobIDm","Application.Name")

data<-merge(data,jobnames,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$Application.Name[is.na(data$Application.Name)]<-"Unknown"
users<-read.csv(file="usernames.csv")
data<-merge(data,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
write.csv(data,file=alldata)
save(data,file='data.Rdata')
save(users,file='users.Rdata')

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

top100_corehours<-data%>%select(CoreHours,Application.Name,Username,Job.ID,Queue,Host.s.,Wall.Time,Wait.Time)%>%arrange(desc(CoreHours))%>%head(n=100)
top100_corehours$Wall.Time<-as.numeric(top100_corehours$Wall.Time)/3600.0
top100_corehours$Wait.Time<-as.numeric(top100_corehours$Wait.Time)/3600.0
colnames(top100_corehours)<-c("Core Hours","Application","Username","Job ID","Queue","Cores","Wall time","Wait time")
write.csv(top100_corehours,file=top100)

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
