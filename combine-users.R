#!/usr/bin/env Rscript
csv_raw<-"usernames-raw.csv"
csv_fixed<-"usernames-fixed.csv"
csv_out<-"usernames.csv"
data_raw<-read.csv(file=csv_raw,header=TRUE)
data_fixed<-read.csv(file=csv_fixed,header=TRUE)
data<-rbind(data_fixed,data_raw)
data<-data[!duplicated(data$Username),]
write.csv(data,file=csv_out,row.names=FALSE)
