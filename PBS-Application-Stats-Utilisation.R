#!/usr/bin/env Rscript
cat("generate utillisation based on partial time accounting\n")

source("config.R")
source("PBS-Application-Stats-Common.R")

# Inputs
pbsreport<-paste0("pbs-report.cleaned.partial.",suffix,".csv")
jobcores<-paste0("cores.",suffix,".csv")
usernames<-paste0("usernames.",suffix,".csv")
project<-paste0("project.",suffix,".csv")
apps<-paste0("alljobs.",suffix,".csv")
ngpuscsv<-paste0("ngpus.",suffix,".csv")

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
data[grepl("^gpu",data$Queue),"Node.Type"]<-"GPU"
data[grepl("gpu",data$Execution.Hosts)&grepl("^R[0-9]",data$Queue),"Node.Type"]<-"GPU"
data[grepl("dgx",data$Execution.Hosts),"Node.Type"]<-"DGX"

# Merge in separately calculated data on cores per job
cores<-read.csv(file=jobcores,header=TRUE)
data<-merge(data,cores,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Multiply cores by wall time to get CoreHours
data$CoreHours<-as.numeric(data$Cores)*as.numeric(data$Wall.Time.Hours)

# Create new column with Job Index removed
data$Job.ID.NoIndex<-gsub('\\[\\d+\\]','[]',data$Job.ID)

ngpus<-read.csv(file=ngpuscsv,header=FALSE,colClasses=c("character","numeric"))
colnames(ngpus)<-c("Job.ID.NoIndex","ngpus")
data<-merge(data,ngpus,all.x=TRUE,all.y=FALSE,sort=FALSE)
data$ngpus[is.na(data$ngpus)]<-0
data$GPU.Hours<-data$ngpus*data$Wall.Time.Hours

# merge in names of users
users<-read.csv(usernames)

data<-merge(data,users,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Convert high level orgs to a factor to make sure they are all included
data$Organization.HighLevel<-factor(data$Organization.HighLevel,allorgs)

# Correction for unused reservations
source("PBS-Application-Stats-Unused.R")

data_cpu<-data%>%filter(Node.Type=="CPU")
data_gpu<-data%>%filter(Node.Type=="GPU")

# Convert to organisation format so that reserved nodes are counted
data_cpu_org<-data_cpu%>%group_by(Organization)%>%summarize(Organization.HighLevel=unique(Organization.HighLevel),CoreHours=sum(CoreHours),NumJobs=length(Job.ID))
data_cpu_org<-rbind(data_cpu_org,unused)
data_cpu_org$CoreHours<-as.numeric(data_cpu_org$CoreHours)
data_cpu_org$NumJobs<-as.integer(data_cpu_org$NumJobs)
data_gpu_org<-data_gpu%>%group_by(Organization)%>%summarize(Organization.HighLevel=unique(Organization.HighLevel),GPUHours=sum(CoreHours/24.0),NumJobs=length(Job.ID))
data_gpu_org$NumJobs<-as.integer(data_gpu_org$NumJobs)

# Total core hours
total_cpu<-sum(data_cpu_org$CoreHours)
total_gpu<-sum(data_gpu_org$GPUHours)*24.0
total_corehours<-data.frame(total_cpu+total_gpu,total_cpu,total_gpu)
colnames(total_corehours)<-c("Combined","CPU","GPU")
rownames(total_corehours)<-suffix

total<-paste0("partial.",suffix,".csv")
write.csv(total_corehours,total)
cat("utilisation data written\n")
