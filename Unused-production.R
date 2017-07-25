#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

cat("Calculate unused Production queue utilisation\n")

# Inputs
pbsreport<-paste0("production.pbs-report.cleaned.",suffix,".csv")
jobcores<-paste0("production.cores.",suffix,".csv")

# load in csv data from pbsreport and rename the columns
cat("load from csv\n")
data<-read.csv(file=pbsreport,header=TRUE,sep="|",skip=1)
cat("rename columns\n")
data<-rename(data,Execution.Hosts=Host.s.,Core.Memory=Memory,Virtual.Memory=Memory.1,Suspend.Time=Time,Date.Created=Created)

# convert seconds into hours
cat("seconds->hours\n")
data$Wall.Time.Hours<-as.numeric(data$Wall.Time)/3600.0

# Merge in separately calculated data on cores per job
cat("merge in cores per job\n")
cores<-read.csv(file=jobcores,header=TRUE)
data<-merge(data,cores,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Multiply cores by wall time to get CoreHours
cat("calculate core hours\n")
data$CoreHours<-as.numeric(data$Cores)*as.numeric(data$Wall.Time.Hours)

unused<-data.frame()

production_corehours<-as.numeric(data%>%summarise(sum(CoreHours)))
production_available<-as.numeric(hours*production_cores)
production_unused<-production_available-production_corehours

if ( production_unused < 0 ) {
 production_unused<-as.numeric(0.0)
}

cat("Production queue core hours used: ",production_corehours,"\nProduction queue reserved core hours: ",production_available,"\nProduction queue unused core hours: ",production_unused,"\n")
unused<-rbind(unused,c("GIS-UNUSED","A*STAR",production_unused,0))
colnames(unused)<-c("Organization","Organization.HighLevel","CoreHours","NumJobs")

write.csv(unused,file=unused_csv,row.names=FALSE)

