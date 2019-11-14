#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

p_before<-read.csv("ams-projects.previous.csv")
p_after<-read.csv(paste0("ams-projects.",suffix,".csv"))
f_out<-paste0("ams-diff.",suffix,".csv")

before<-p_before%>%filter(serviceunit=="cpu_hrs")%>%select(name,ams_before=total_debits_reconciled)
after<-p_after%>%filter(serviceunit=="cpu_hrs")%>%select(name,ams_after=total_debits_reconciled)

tmp<-as.character(before$ams_before)
tmp<-as.numeric(tmp)
before$ams_before<-tmp
before<-na.omit(before)
before$name<-as.character(before$name)

tmp<-as.character(after$ams_after)
tmp<-as.numeric(tmp)
after$ams_after<-tmp
after<-na.omit(after)
after$name<-as.character(after$name)

merged<-merge(after,before,all.x=FALSE,all.y=FALSE)

used<-read.csv("project_walltime.20191001-20191031.csv")
used<-p_used%>%select(name=Project_Short,used=CoreHours)
used$name<-as.character(used$name)

diff<-merge(used,merged,all.x=FALSE,all.y=FALSE)
diff$ams<-diff$ams_after-diff$ams_before
diff$diff<-diff$ams-diff$used

diff<-diff%>%arrange(desc(diff))
write.csv(diff,f_out,row.names = FALSE)
cat("AMS overcharging:\n")
print(sum(diff$diff[which(diff$diff>0)]))
cat("AMS undercharging:\n")
print(sum(diff$diff[which(diff$diff<0)]))
