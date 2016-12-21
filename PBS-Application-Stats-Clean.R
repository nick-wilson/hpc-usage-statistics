#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Inputs
pbsreport<-paste0("pbs-report.cleaned.",suffix,".csv")
jobcores<-paste0("cores.",suffix,".csv")
usernames<-paste0("usernames.",suffix,".csv")
apps<-paste0("alljobs.",suffix,".csv")

# load in csv data from pbsreport and rename the columns
cat("load from csv\n")
data<-read.csv(file=pbsreport,header=TRUE,sep="|",skip=1)
cat("rename columns\n")
data<-rename(data,Execution.Hosts=Host.s.,Core.Memory=Memory,Virtual.Memory=Memory.1,Suspend.Time=Time,Date.Created=Created)

# convert seconds into hours
cat("seconds->hours\n")
data$Wall.Time.Hours<-as.numeric(data$Wall.Time)/3600.0
data$Wait.Time.Hours<-as.numeric(data$Wait.Time)/3600.0
data$CPU.Time.Hours<-as.numeric(data$CPU.Time)/3600.0
data$Suspend.Time.Hours<-as.numeric(data$Suspend.Time)/3600.0

# Check Execution hosts for string gpu to classify job as CPU or GPU
cat("classify as CPU or GPU\n")
data$Node.Type<-"CPU"
data[grepl("gpu",data$Execution.Hosts),"Node.Type"]<-"GPU"

# Merge in separately calculated data on cores per job
cat("merge in cores per job\n")
cores<-read.csv(file=jobcores,header=TRUE)
data<-merge(data,cores,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Multiply cores by wall time to get CoreHours
cat("calculate core hours\n")
data$CoreHours<-as.numeric(data$Cores)*as.numeric(data$Wall.Time.Hours)

# Create new column with Job Index removed and match that against application data
cat("create job id without index\n")
data$Job.ID.NoIndex<-gsub('\\[\\d+\\]','[]',data$Job.ID)
jobnames<-read.csv(file=apps,header=FALSE,colClasses="character")
colnames(jobnames)<-c("Job.ID.NoIndex","Application.Name")
data<-merge(data,jobnames,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$Application.Name[is.na(data$Application.Name)]<-"Unknown"

# merge in names of users
cat("read in user information\n")
users<-read.csv(usernames)
# edits for misplaced CREATE usernames
cat("clean user information\n")
org<-"ETHZ"
vec_u<-c("secpjf")
for (u in vec_u){
 if(any(users$Username==u)){
  users[users$Username==u,"Organization"]<-org
 }
}
org<-"NRD"
vec_u<-c("nrdmgb","nrdzw","nrdmela","nrdnbka")
for (u in vec_u){
 if(any(users$Username==u)){
  users[users$Username==u,"Organization"]<-org
 }
}
org<-"SINBERBEST"
vec_u<-c("sbbrlg")
for (u in vec_u){
 if(any(users$Username==u)){
  users[users$Username==u,"Organization"]<-org
 }
}
org<-"SMART"
vec_u<-c("smrqx","smrpvr")
for (u in vec_u){
 if(any(users$Username==u)){
  users[users$Username==u,"Organization"]<-org
 }
}
org<-"TUM-CREATE"
vec_u<-c("tumjiaj")
for (u in vec_u){
 if(any(users$Username==u)){
  users[users$Username==u,"Organization"]<-org
 }
}
if (any(users$Organization=="MIT")) {users[users$Organization=="MIT","Organization"]<-"SMART"}
## cannot use the following line as it makes a new factor
#if (any(users$Organization=="CREATE")) {users[users$Organization=="CREATE","Organization"]<-"CREATE-OTHERS"}

cat("merge user information with job information\n")
data<-merge(data,users,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Categorize organizations
cat("categorize organizations\n")
data$Organization.HighLevel<-"Other"
# NUS
data[grepl("NUS",data$Organization),"Organization.HighLevel"]<-"NUS"
# NTU
data[data$Organization=="NTU","Organization.HighLevel"]<-"NTU"
# A*STAR
data[data$Organization=="GIS"|data$Organization=="IHPC"|data$Organization=="BII"|data$Organization=="IMCB"|data$Organization=="SCEI"|data$Organization=="I2R"|data$Organization=="BMSI"|data$Organization=="ICES"|data$Organization=="DSI"|data$Organization=="IMRE"|data$Organization=="IME"|data$Organization=="SIMT"|data$Organization=="IBN","Organization.HighLevel"]<-"A*STAR"
# CREATE
data[data$Organization=="CREATE"|data$Organization=="BEARS-BERKELEY"|data$Organization=="CARES"|data$Organization=="E2S2"|data$Organization=="ETHZ"|data$Organization=="NRD"|data$Organization=="SINBERBEST"|data$Organization=="SINBERISE"|data$Organization=="SMART"|data$Organization=="TUM-CREATE","Organization.HighLevel"]<-"CREATE"
# 

# write out data for use in other scripts
cat("write data to file\n")
save(data,file=alldata_R)
save(users,file=users_R)
