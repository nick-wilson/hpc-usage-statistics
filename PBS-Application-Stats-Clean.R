#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Inputs
pbsreport<-paste0("pbs-report.cleaned.",suffix,".csv")
jobcores<-paste0("cores.",suffix,".csv")
usernames<-paste0("usernames.",suffix,".csv")
project<-paste0("project.",suffix,".csv")
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
data[grepl("^gpu",data$Queue),"Node.Type"]<-"GPU"
data[grepl("gpu",data$Execution.Hosts)&grepl("^R[0-9]",data$Queue),"Node.Type"]<-"GPU"

# Merge in separately calculated data on cores per job
cat("merge in cores per job\n")
cores<-read.csv(file=jobcores,header=TRUE)
data<-merge(data,cores,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Categorize Cores
cat("Categorize jobs by core count\n")
data$CoresGroup<-"Unknown"
data[data$Cores==1,"CoresGroup"]<-"1"
data[data$Cores>1&data$Cores<=23,"CoresGroup"]<-"2-23"
data[data$Cores==24,"CoresGroup"]<-"24"
data[data$Cores>24&data$Cores<=96,"CoresGroup"]<-"25-96"
data[data$Cores>96&data$Cores<=240,"CoresGroup"]<-"97-240"
data[data$Cores>240&data$Cores<=960,"CoresGroup"]<-"241-960"
data[data$Cores>960,"CoresGroup"]<-">960"

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
data$Application.Name[substring(data$Job.ID,1,1)=="A"]<-"Alpha Phase - Not logged"

projects<-read.csv(file=project,header=FALSE,colClasses="character")
colnames(projects)<-c("Job.ID.NoIndex","Project")
projects$Project<-as.factor(projects$Project)
levels(projects$Project)<-c(levels(projects$Project),"Unknown")
data<-merge(data,projects,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$Project[is.na(data$Project)]<-"Unknown"

# merge in names of users
cat("read in user information\n")
users<-read.csv(usernames)

cat("merge user information with job information\n")
data<-merge(data,users,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Convert high level orgs to a factor to make sure they are all included
allorgs<-c("A*STAR","NUS","NTU","CREATE","SUTD","Other")
data$Organization.HighLevel<-factor(data$Organization.HighLevel,allorgs)

# write out data for use in other scripts
cat("write data to file\n")
save(data,file=alldata_R)
save(users,file=users_R)
