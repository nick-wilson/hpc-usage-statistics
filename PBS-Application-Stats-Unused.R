

unused<-data.frame()

production_corehours<-as.numeric(data%>%filter(Queue=="production")%>%summarise(sum(CoreHours)))
production_available<-as.numeric(hours*production_cores)
unused<-rbind(unused,c("GIS-UNUSED","A*STAR",production_available-production_corehours,0))
colnames(unused)<-c("Organization","Organization.HighLevel","CoreHours","NumJobs")
