#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)

# Calculate active users
active<-data%>%group_by(Organization.HighLevel)%>%summarise(Active.Users=length(unique(Username)))
total_active<-sum(active$Active.Users)
for (org in levels(active$Organization.HighLevel)){if(!any(active$Organization.HighLevel==org)){active<-rbind(active,c(org,"0"))}}
levels(active$Organization.HighLevel)<-c(levels(active$Organization.HighLevel),"Total")
active<-rbind(active,c("Total",total_active))
active<-active%>%arrange(Organization.HighLevel)
active_totals<-paste0("active-totals.",suffix,".csv")
write.csv(active,file=active_totals,row.names=FALSE)