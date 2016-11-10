#!/usr/bin/env Rscript
source("config.R")
csv_raw<-paste0("usernames-raw.",suffix,".csv")
csv_fixed<-"usernames-fixed.csv"
csv_out<-paste0("usernames.",suffix,".csv")
data_raw<-read.csv(file=csv_raw,header=TRUE)
data_fixed<-read.csv(file=csv_fixed,header=TRUE)
data<-rbind(data_fixed,data_raw)
data<-data[!duplicated(data$Username),]
write.csv(data,file=csv_out,row.names=FALSE)
