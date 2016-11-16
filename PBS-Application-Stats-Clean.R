#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Inputs
pbsreport<-paste0("pbs-report.cleaned.",suffix,".csv")
jobcores<-paste0("cores.",suffix,".csv")
usernames<-paste0("usernames.",suffix,".csv")
apps<-paste0("alljobs.",suffix,".csv")

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

# Categorize organizations
data$Organization.HighLevel<-"Other"
data[grepl("NUS",data$Organization),"Organization.HighLevel"]<-"NUS"
data[data$Organization=="NTU","Organization.HighLevel"]<-"NTU"
data[data$Organization=="GIS"|data$Organization=="IHPC"|data$Organization=="BII"|data$Organization=="IMCB"|data$Organization=="SCEI"|data$Organization=="I2R"|data$Organization=="BMSI"|data$Organization=="ICES"|data$Organization=="DSI"|data$Organization=="IMRE"|data$Organization=="IME"|data$Organization=="SIMT"|data$Organization=="IBN","Organization.HighLevel"]<-"A*STAR"

# write out data for use in other scripts
save(data,file=alldata_R)
save(users,file=users_R)
