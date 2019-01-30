#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")
# Input file defined in make-email
filter<-""
email_csv<-paste0("email.",filter,suffix,".csv")
# Output file
user_email<-paste0("user_walltime_email",filter,suffix,".csv")

cat("load data\n")
load(file=alldata_R)
load(file=users_R)
email<-read.csv(email_csv)

cat("merge emails with other user information\n")
users<-merge(users,email,all.x=TRUE,all.y=FALSE,sort=FALSE)

# Emails of top users
cat("generate user statistics\n")
tmpdata<-data%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
cat("merge with user information\n")
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","CoreHours","NumJobs","Name","Organization","Email")
cat("sort data\n")
tmpdata<-tmpdata%>%arrange(desc(CoreHours))
cat("write to file\n")
write.csv(tmpdata[,c(1,4:6,2:3)],file=user_email)
rm(tmpdata)
