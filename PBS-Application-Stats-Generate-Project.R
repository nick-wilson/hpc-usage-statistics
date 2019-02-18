
# Outputs
project_walltime_cpu<-paste0("project_walltime_cpu.",filter,suffix,".csv")
project_by_stakeholder_cpu<-paste0("project_by_stakeholder_cpu.",filter,suffix,".csv")
project_walltime_gpu<-paste0("project_walltime_gpu.",filter,suffix,".csv")
project_by_stakeholder_gpu<-paste0("project_by_stakeholder_gpu.",filter,suffix,".csv")

data<-data%>%filter(Node.Type!="DGX")
data_cpu<-data%>%filter(Node.Type=="CPU")
data_gpu<-data%>%filter(Node.Type=="GPU")

# Project corehours
cat("Project core hours CPU\n")
tmpdata<-data_cpu%>%group_by(Project)%>%summarise(CoreHours=sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Project","CoreHours","NumJobs")
tmpdata$CoreHours[is.na(tmpdata$CoreHours)] <- 0.0
tmpdata$NumJobs[is.na(tmpdata$NumJobs)] <- 0
tmpdata$Project_Short<-gsub('(NUS-|NTU-|A.STAR-|Industry-|SUTD-|NIS-|NSCC-|TCOMS-)','',tmpdata$Project)
write.csv(tmpdata,file=project_walltime_cpu)
#
tmpdata$Project.Stakeholder<-tmpdata$Project
tmpdata$Project.Stakeholder<-gsub(     'NUS-11......',     'NUS-11xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(     'NTU-12......',     'NTU-12xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(  'A.STAR-13......',  'A*STAR-13xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-14......','Industry-14xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(    'SUTD-15......',    'SUTD-15xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(     'NIS-16......',     'NIS-16xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-2.......','Industry-2xxxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(   'TCOMS-........',   'TCOMS-xxxxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(    'NSCC-........',    'NSCC-xxxxxxxx',tmpdata$Project.Stakeholder)
#
tmpdata$Project.Stakeholder<-gsub('resv','NSCC-xxxxxxxx',tmpdata$Project.Stakeholder)
tmpdata[grepl("^Industry-2......$",tmpdata$Project.Stakeholder),"Project.Stakeholder"]<-'Industry-2xxxxxxx'
#
tmpdata$Project.Stakeholder<-gsub('personal-.*','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Unknown','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('30003671','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('10031963','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('10019921','Personal',tmpdata$Project.Stakeholder)
#
tmpdata<-tmpdata%>%group_by(Project.Stakeholder)%>%summarise(CoreHours=sum(CoreHours),NumJobs=sum(NumJobs))%>%arrange(desc(CoreHours))
write.csv(tmpdata,file=project_by_stakeholder_cpu)
rm(tmpdata)

cat("Project core hours GPU\n")
tmpdata<-data_gpu%>%group_by(Project)%>%summarise(GPUHours=sum(CoreHours)/24.0,length(Job.ID))
colnames(tmpdata)<-c("Project","GPUHours","NumJobs")
tmpdata$GPUHours[is.na(tmpdata$GPUHours)] <- 0.0
tmpdata$NumJobs[is.na(tmpdata$NumJobs)] <- 0
tmpdata$Project_Short<-gsub('(NUS-|NTU-|A.STAR-|Industry-|SUTD-|NIS-|NSCC-|TCOMS-)','',tmpdata$Project)
write.csv(tmpdata,file=project_walltime_gpu)
#
tmpdata$Project.Stakeholder<-tmpdata$Project
tmpdata$Project.Stakeholder<-gsub(     'NUS-11......',     'NUS-11xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(     'NTU-12......',     'NTU-12xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(  'A.STAR-13......',  'A*STAR-13xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-14......','Industry-14xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(    'SUTD-15......',    'SUTD-15xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(     'NIS-16......',     'NIS-16xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-2.......','Industry-2xxxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(   'TCOMS-........',   'TCOMS-xxxxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(    'NSCC-........',    'NSCC-xxxxxxxx',tmpdata$Project.Stakeholder)
#
tmpdata$Project.Stakeholder<-gsub('resv','NSCC-xxxxxxxx',tmpdata$Project.Stakeholder)
tmpdata[grepl("^Industry-2......$",tmpdata$Project.Stakeholder),"Project.Stakeholder"]<-'Industry-2xxxxxxx'
#
tmpdata$Project.Stakeholder<-gsub('personal-.*','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Unknown','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('30003671','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('10031963','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('10019921','Personal',tmpdata$Project.Stakeholder)
#
tmpdata<-tmpdata%>%group_by(Project.Stakeholder)%>%summarise(GPUHours=sum(GPUHours),NumJobs=sum(NumJobs))%>%arrange(desc(GPUHours))
write.csv(tmpdata,file=project_by_stakeholder_gpu)
rm(tmpdata)
