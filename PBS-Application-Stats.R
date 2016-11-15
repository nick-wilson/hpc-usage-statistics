#!/usr/bin/env Rscript

source("config.R")

# Inputs
pbsreport<-paste0("pbs-report.cleaned.",suffix,".csv")
jobcores<-paste0("cores.",suffix,".csv")
usernames<-paste0("usernames.",suffix,".csv")
apps<-paste0("alljobs.",suffix,".csv")

# Outputs
alldata<-paste0("alldata.",suffix,".csv")
userdata<-paste0("user_walltime.",suffix,".csv")
app_by_user<-paste0("application_by_user.",suffix,".csv")
orgdata_cpu<-paste0("org_walltime_cpu.",suffix,".csv")
orgdata_gpu<-paste0("org_walltime_gpu.",suffix,".csv")
org2data_cpu<-paste0("org2_walltime_cpu.",suffix,".csv")
org2data_gpu<-paste0("org2_walltime_gpu.",suffix,".csv")
appcpu<-paste0("application_usage_cpu.",suffix,".csv")
appgpu<-paste0("application_usage_gpu.",suffix,".csv")
top100<-paste0("top100.",suffix,".csv")

library(dplyr,warn.conflicts=FALSE)

# load in csv data from pbsreport and rename the columns
data<-read.csv(file=pbsreport,header=TRUE,sep="|",skip=1)
data<-rename(data,Execution.Hosts=Host.s.,Core.Memory=Memory,Virtual.Memory=Memory.1,Suspend.Time=Time,Date.Created=Created)

# convert seconds into hours
data$Wall.Time.Hours<-as.numeric(data$Wall.Time)/3600.0
data$Wait.Time.Hours<-as.numeric(data$Wait.Time)/3600.0
data$CPU.Time.Hours<-as.numeric(data$CPU.Time)/3600.0
data$Suspend.Time.Hours<-as.numeric(data$Suspend.Time)/3600.0

# Check Execution hosts for string gpu to classify job as CPU or GPU
data$Node.Type<-"CPU"
data[grepl("gpu",data$Execution.Hosts),"Node.Type"]<-"GPU"

# Merge in separately calculated data on cores per job
cores<-read.csv(file=jobcores,header=TRUE)
data<-merge(data,cores,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Multiply cores by wall time to get CoreHours
data$CoreHours<-as.numeric(data$Cores)*as.numeric(data$Wall.Time.Hours)

# Create new column with Job Index removed and match that against application data
data$Job.ID.NoIndex<-gsub('\\[\\d+\\]','[]',data$Job.ID)
jobnames<-read.csv(file=apps,header=FALSE,colClasses="character")
colnames(jobnames)<-c("Job.ID.NoIndex","Application.Name")
data<-merge(data,jobnames,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$Application.Name[is.na(data$Application.Name)]<-"Unknown"

# merge in names of users
users<-read.csv(usernames)
data<-merge(data,users,all.x=TRUE,all.y=FALSE,sort=FALSE)

# write out data for use in other scripts
write.csv(data,file=alldata)
save(data,file='data.Rdata')
save(users,file='users.Rdata')

# Categorize organizations
data$Organization.HighLevel<-"Other"
data[grepl("NUS",data$Organization),"Organization.HighLevel"]<-"NUS"
data[data$Organization=="NTU","Organization.HighLevel"]<-"NTU"
data[data$Organization=="GIS"|data$Organization=="IHPC"|data$Organization=="BII"|data$Organization=="IMCB"|data$Organization=="SCEI"|data$Organization=="I2R"|data$Organization=="BMSI"|data$Organization=="ICES"|data$Organization=="DSI"|data$Organization=="IMRE"|data$Organization=="IME"|data$Organization=="SIMT"|data$Organization=="IBN","Organization.HighLevel"]<-"A*STAR"

# write out data for use in other scripts
write.csv(data,file=alldata)
save(data,file='data.Rdata')
save(users,file='users.Rdata')

# Calculate corehours per user
user_corehours<-data%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
user_corehours<-merge(user_corehours,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(user_corehours)<-c("Username","CoreHours","NumJobs","Name","Organization")
user_corehours<-arrange(user_corehours,desc(CoreHours))
user_corehours<-user_corehours[,c(1,4,5,2,3)]
write.csv(user_corehours,file=userdata)

# Calculate corehours per user per application
user_corehours<-data%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
app_by_user_corehours<-data%>%group_by(Username,Application.Name)%>%summarise(sum(CoreHours),length(Job.ID))
app_by_user_corehours<-merge(app_by_user_corehours,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
app_by_user_corehours<-app_by_user_corehours[,c(2,1,5,6,3,4)]
colnames(app_by_user_corehours)<-c("Application","Username","Name","Organization","CoreHours","NumJobs")
app_by_user_corehours<-app_by_user_corehours%>%arrange(Application,CoreHours)
write.csv(app_by_user_corehours,file=app_by_user,row.names=FALSE)

# Calculate largest jobs
top100_corehours<-data%>%select(CoreHours,Application.Name,Username,Job.ID,Queue,Cores,Wall.Time.Hours,Wait.Time.Hours)%>%arrange(desc(CoreHours))%>%head(n=100)
colnames(top100_corehours)<-c("Core Hours","Application","Username","Job ID","Queue","Cores","Wall time","Wait time")
write.csv(top100_corehours,file=top100)

# Calculate corehours for CPU applications
df1<-data%>%filter(Node.Type=="CPU")%>%group_by(Application.Name,Username)%>%summarize(sum(CoreHours),length(Job.ID))
colnames(df1)<-c("Application.Name","Username","CoreHours","NumJobs")
df1<-df1%>%group_by(Application.Name)%>%summarize(sum(CoreHours),sum(NumJobs),length(Username))
colnames(df1)<-c("Application.Name","CoreHours","NumJobs","NumUsers")
df1<-arrange(df1,desc(CoreHours))
write.csv(df1,file=appcpu)

# Calculate corehours for GPU applications
df1<-data%>%filter(Node.Type=="GPU")%>%group_by(Application.Name,Username)%>%summarize(sum(CoreHours),length(Job.ID))
colnames(df1)<-c("Application.Name","Username","CoreHours","NumJobs")
df1<-df1%>%group_by(Application.Name)%>%summarize(sum(CoreHours),sum(NumJobs),length(Username))
colnames(df1)<-c("Application.Name","CoreHours","NumJobs","NumUsers")
df1<-arrange(df1,desc(CoreHours))
write.csv(df1,file=appgpu)

# Calculate CPU corehours per organisation
org_corehours_cpu<-data%>%filter(Node.Type=="CPU")%>%group_by(Organization)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(org_corehours_cpu)<-c("Organization","CoreHours","NumJobs")
org_corehours_cpu<-arrange(org_corehours_cpu,desc(CoreHours))
write.csv(org_corehours_cpu,file=orgdata_cpu)

# Calculate GPU corehours per organisation
org_corehours_gpu<-data%>%filter(Node.Type=="GPU")%>%group_by(Organization)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(org_corehours_gpu)<-c("Organization","CoreHours","NumJobs")
org_corehours_gpu<-arrange(org_corehours_gpu,desc(CoreHours))
write.csv(org_corehours_gpu,file=orgdata_gpu)

# Calculate CPU corehours per high-level organisation
org2_corehours_cpu<-data%>%filter(Node.Type=="CPU")%>%group_by(Organization.HighLevel)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(org2_corehours_cpu)<-c("Organization.HighLevel","CoreHours","NumJobs")
org2_corehours_cpu<-arrange(org2_corehours_cpu,desc(CoreHours))
write.csv(org2_corehours_cpu,file=org2data_cpu)

# Calculate GPU corehours per high-level organisation
org2_corehours_gpu<-data%>%filter(Node.Type=="GPU")%>%group_by(Organization.HighLevel)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(org2_corehours_gpu)<-c("Organization.HighLevel","CoreHours","NumJobs")
org2_corehours_gpu<-arrange(org2_corehours_gpu,desc(CoreHours))
write.csv(org2_corehours_gpu,file=org2data_gpu)
