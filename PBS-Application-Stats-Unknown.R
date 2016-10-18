#!/usr/bin/env Rscript

unknown_job_csv<-'unknown_job.csv'
unknown_gpujob_csv<-'unknown_gpujob.csv'
unknown_user_csv<-'unknown_user.csv'

library(dplyr,warn.conflicts=FALSE)

load("data.Rdata")
unknown<-data%>%filter(Application.Name=="Unknown")%>%arrange(desc(CoreHours))
write.csv(unknown,file=unknown_job_csv)
unknown_gpu<-unknown%>%filter(Q=="GPU")%>%arrange(desc(CoreHours))
write.csv(unknown_gpu,file=unknown_gpujob_csv)
unknown_user<-unknown%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(unknown_user)<-c("Username","CoreHours","NumJobs")
unknown_user<-unknown_user%>%arrange(desc(CoreHours))
write.csv(unknown_user,file=unknown_user_csv)
cat("\nTotal: ",sum(unknown$CoreHours),"\n\n")
unknown%>%select(Username,Job.ID,Queue,CoreHours,Application.Name)%>%head(n=20)
cat("\n")
unknown_gpu%>%select(Username,Job.ID,Queue,CoreHours,Application.Name)%>%head(n=5)
cat("\n")
head(unknown_user)
cat("\n")
