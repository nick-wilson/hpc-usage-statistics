#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

load(file=alldata_R)

unknown_job_csv<-paste0("unknown_job.",suffix,".csv")
unknown_gpujob_csv<-paste0("unknown_gpujob.",suffix,".csv")
unknown_user_csv<-paste0("unknown_user.",suffix,".csv")

unknown<-data%>%filter(Application.Name=="Unknown")%>%arrange(desc(CoreHours))
write.csv(unknown,file=unknown_job_csv)
unknown_gpu<-unknown%>%filter(Node.Type=="GPU")%>%arrange(desc(CoreHours))
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
