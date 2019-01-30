#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

tmp<-paste0('storage.',suffix,'.csv')
storage<-read.csv(tmp)
total_gb<-storage$home_gb+storage$home1_gb+storage$scratch_gb+storage$secure_gb+storage$seq_gb
storage<-cbind(storage,total_gb)
tmp<-paste0('usernames.',suffix,'.csv')
usernames<-read.csv(tmp)
storage<-merge(storage,usernames,all.x=TRUE,all.y=FALSE,sort=FALSE)
storage$Organization.HighLevel<-factor(storage$Organization.HighLevel,allorgs)

tmp<-paste0('storage-byorg2.',suffix,'.csv')
write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_tb=sum(home_gb)/1000.0,home1_tb=sum(home1_gb)/1000.0,scratch_tb=sum(scratch_gb)/1000.0,secure_tb=sum(secure_gb)/1000.0,seq_tb=sum(seq_gb)/1000.0,total_tb=sum(total_gb)/1000.0))
tmp<-paste0('storage-byorg.',suffix,'.csv')
write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
tmp<-paste0('storage-byuser.',suffix,'.csv')
write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))

if (report_org==1) {
 ostorage<-storage

 # Stats by stakeholder
 for (dfilter in allorgs){
  filter<-dfilter
  if (dfilter=="A*STAR") {
   filter<-"ASTAR"
  }
  filter<-paste0(filter,".")
  storage<-ostorage%>%filter(Organization.HighLevel==dfilter)
  tmp<-paste0('storage-byorg2.',filter,suffix,'.csv')
  write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_tb=sum(home_gb)/1000.0,home1_tb=sum(home1_gb)/1000.0,scratch_tb=sum(scratch_gb)/1000.0,secure_tb=sum(secure_gb)/1000.0,seq_tb=sum(seq_gb)/1000.0,total_tb=sum(total_gb)/1000.0))
  tmp<-paste0('storage-byorg.',filter,suffix,'.csv')
  write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
  tmp<-paste0('storage-byuser.',filter,suffix,'.csv')
  write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))
 }

 # Stats for selected organizations
 for (dfilter in c("GIS","IHPC","KOMTECH")){
  filter<-dfilter
  filter<-paste0(filter,".")
  storage<-ostorage%>%filter(Organization==dfilter)
  tmp<-paste0('storage-byorg2.',filter,suffix,'.csv')
  write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_tb=sum(home_gb)/1000.0,home1_tb=sum(home1_gb)/1000.0,scratch_tb=sum(scratch_gb)/1000.0,secure_tb=sum(secure_gb)/1000.0,seq_tb=sum(seq_gb)/1000.0,total_tb=sum(total_gb)/1000.0))
  tmp<-paste0('storage-byorg.',filter,suffix,'.csv')
  write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
  tmp<-paste0('storage-byuser.',filter,suffix,'.csv')
  write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))
 }

} # report_org==1
