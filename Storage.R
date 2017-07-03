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

tmp<-paste0('storage-byorg2.',suffix,'.csv')
write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
tmp<-paste0('storage-byorg.',suffix,'.csv')
write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
tmp<-paste0('storage-byuser.',suffix,'.csv')
write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))


if ( monthly==1) {
ostorage<-storage
dfilter<-"A*STAR"
storage<-ostorage%>%filter(Organization.HighLevel==dfilter)
filter<-"ASTAR."
tmp<-paste0('storage-byorg2.',filter,suffix,'.csv')
write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
tmp<-paste0('storage-byorg.',filter,suffix,'.csv')
write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
tmp<-paste0('storage-byuser.',filter,suffix,'.csv')
write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))

for (filter in c("NUS","NTU","CREATE","SUTD")){
 storage<-ostorage%>%filter(Organization.HighLevel==filter)
 filter<-paste0(filter,".")
 tmp<-paste0('storage-byorg2.',filter,suffix,'.csv')
 write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
 tmp<-paste0('storage-byorg.',filter,suffix,'.csv')
 write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
 tmp<-paste0('storage-byuser.',filter,suffix,'.csv')
 write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))
}

# Stats for Individual Organizations
for (filter in c("GIS","IHPC")) {
 storage<-ostorage%>%filter(Organization==filter)
 filter<-paste0(filter,".")
 tmp<-paste0('storage-byorg2.',filter,suffix,'.csv')
 write.csv(file=tmp,storage%>%group_by(Organization.HighLevel)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
 tmp<-paste0('storage-byorg.',filter,suffix,'.csv')
 write.csv(file=tmp,storage%>%group_by(Organization)%>%summarise(home_gb=sum(home_gb),home1_gb=sum(home1_gb),scratch_gb=sum(scratch_gb),secure_gb=sum(secure_gb),seq_gb=sum(seq_gb),total_gb=sum(total_gb))%>%arrange(desc(total_gb)))
 tmp<-paste0('storage-byuser.',filter,suffix,'.csv')
 write.csv(file=tmp,storage%>%select(-ends_with("_files"))%>%arrange(desc(total_gb)))
}
}
