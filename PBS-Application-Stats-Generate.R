
# Outputs
alldata<-paste0("alldata.",filter,suffix,".csv")
app_by_org<-paste0("application_by_organization",filter,suffix,".csv")
userdata_cpu<-paste0("user_walltime_cpu.",filter,suffix,".csv")
userdata_gpu<-paste0("user_walltime_gpu.",filter,suffix,".csv")
app_by_org<-paste0("application_by_organization.",filter,suffix,".csv")
app_by_org_node<-paste0("application_by_organization_and_nodetype.",filter,suffix,".csv")
app_by_user_cpu<-paste0("application_by_user_cpu.",filter,suffix,".csv")
app_by_user_gpu<-paste0("application_by_user_gpu.",filter,suffix,".csv")
orgdata_cpu<-paste0("org_walltime_cpu.",filter,suffix,".csv")
orgdata_gpu<-paste0("org_walltime_gpu.",filter,suffix,".csv")
org2data_cpu<-paste0("org2_walltime_cpu.",filter,suffix,".csv")
org2data_gpu<-paste0("org2_walltime_gpu.",filter,suffix,".csv")
app_cpu<-paste0("application_usage_cpu.",filter,suffix,".csv")
app_gpu<-paste0("application_usage_gpu.",filter,suffix,".csv")
top100_cpu<-paste0("top100_cpu.",filter,suffix,".csv")
top100_gpu<-paste0("top100_gpu.",filter,suffix,".csv")
total<-paste0("total.",filter,suffix,".csv")
stats_by_core_cpu<-paste0("stats_by_core_cpu.",filter,suffix,".csv")
stats_by_core_gpu<-paste0("stats_by_core_gpu.",filter,suffix,".csv")
cpuwall_cpu<-paste0("cpu_walltime_by_user_by_application_cpu.",filter,suffix,".csv")
cpuwall_gpu<-paste0("cpu_walltime_by_user_by_application_gpu.",filter,suffix,".csv")

data_cpu<-data%>%filter(Node.Type=="CPU")
data_gpu<-data%>%filter(Node.Type=="GPU")

# Write data on all jobs
write.csv(data,file=alldata,row.names=FALSE)

# Application by Organisation
tmpdata<-data%>%group_by(Organization,Application.Name)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Organization","Application","CoreHours","NumJobs")
tmpdata<-tmpdata%>%arrange(Application,CoreHours)
write.csv(tmpdata,app_by_org,row.names=FALSE)
rm(tmpdata)

# Application by Organisation and Node Type
tmpdata<-data%>%group_by(Organization,Application.Name,Node.Type)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Organization","Application","NodeType","CoreHours","NumJobs")
write.csv(tmpdata,app_by_org_node,row.names=FALSE)
rm(tmpdata)

# Total core hours
total_corehours<-data.frame(sum(data$CoreHours),sum(data_cpu$CoreHours),sum(data_gpu$CoreHours))
colnames(total_corehours)<-c("Combined","CPU","GPU")
rownames(total_corehours)<-suffix
write.csv(total_corehours,total)

# Calculate CPU/Walltime efficiency per user per application on CPU nodes
tmpdata<-data_cpu%>%group_by(Username,Application.Name)%>%summarise(sum(CPU.Time.Hours),sum(CoreHours),sum(CPU.Time.Hours)/sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","Application","CPUHours","CoreHours","Ratio","NumJobs","Name","Organization")
tmpdata<-arrange(tmpdata,Ratio)
write.csv(tmpdata,file=cpuwall_cpu,row.names=FALSE)
rm(tmpdata)

# Calculate CPU/Walltime efficiency per user per application on GPU nodes
tmpdata<-data_gpu%>%group_by(Username,Application.Name)%>%summarise(sum(CPU.Time.Hours),sum(CoreHours),sum(CPU.Time.Hours)/sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","Application","CPUHours","CoreHours","Ratio","NumJobs","Name","Organization")
tmpdata<-arrange(tmpdata,Ratio)
write.csv(tmpdata,file=cpuwall_gpu,row.names=FALSE)
rm(tmpdata)

# Calculate CPU corehours per user
tmpdata<-data_cpu%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","CoreHours","NumJobs","Name","Organization")
tmpdata<-arrange(tmpdata,desc(CoreHours))
tmpdata<-tmpdata[,c(1,4,5,2,3)]
write.csv(tmpdata,file=userdata_cpu)
rm(tmpdata)

# Calculate GPU corehours per user
tmpdata<-data_gpu%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","CoreHours","NumJobs","Name","Organization")
tmpdata<-arrange(tmpdata,desc(CoreHours))
tmpdata<-tmpdata[,c(1,4,5,2,3)]
write.csv(tmpdata,file=userdata_gpu)
rm(tmpdata)

# Calculate corehours per user per application
tmpdata<-data_cpu%>%group_by(Username,Application.Name)%>%summarise(sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata<-tmpdata[,c(2,1,5,6,3,4)]
colnames(tmpdata)<-c("Application","Username","Name","Organization","CoreHours","NumJobs")
tmpdata<-tmpdata%>%arrange(Application,CoreHours)
write.csv(tmpdata,file=app_by_user_cpu,row.names=FALSE)
rm(tmpdata)

# Calculate corehours per user per application
tmpdata<-data_gpu%>%group_by(Username,Application.Name)%>%summarise(sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata<-tmpdata[,c(2,1,5,6,3,4)]
colnames(tmpdata)<-c("Application","Username","Name","Organization","CoreHours","NumJobs")
tmpdata<-tmpdata%>%arrange(Application,CoreHours)
write.csv(tmpdata,file=app_by_user_gpu,row.names=FALSE)
rm(tmpdata)

# Calculate largest CPU jobs
tmpdata<-data_cpu%>%select(CoreHours,Application.Name,Username,Job.ID,Queue,Cores,Wall.Time.Hours,Wait.Time.Hours)%>%arrange(desc(CoreHours))%>%head(n=100)
colnames(tmpdata)<-c("Core Hours","Application","Username","Job ID","Queue","Cores","Wall time","Wait time")
write.csv(tmpdata,file=top100_cpu)
rm(tmpdata)

# Calculate largest GPU jobs
tmpdata<-data_gpu%>%select(CoreHours,Application.Name,Username,Job.ID,Queue,Cores,Wall.Time.Hours,Wait.Time.Hours)%>%arrange(desc(CoreHours))%>%head(n=100)
colnames(tmpdata)<-c("Core Hours","Application","Username","Job ID","Queue","Cores","Wall time","Wait time")
write.csv(tmpdata,file=top100_gpu)
rm(tmpdata)

# Calculate corehours for CPU applications
tmpdata<-data_cpu%>%group_by(Application.Name,Username)%>%summarize(sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Application.Name","Username","CoreHours","NumJobs")
tmpdata<-tmpdata%>%group_by(Application.Name)%>%summarize(sum(CoreHours),sum(NumJobs),length(Username))
colnames(tmpdata)<-c("Application.Name","CoreHours","NumJobs","NumUsers")
tmpdata<-arrange(tmpdata,desc(CoreHours))
write.csv(tmpdata,file=app_cpu)
rm(tmpdata)

# Calculate corehours for GPU applications
tmpdata<-data_gpu%>%group_by(Application.Name,Username)%>%summarize(sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Application.Name","Username","CoreHours","NumJobs")
tmpdata<-tmpdata%>%group_by(Application.Name)%>%summarize(sum(CoreHours),sum(NumJobs),length(Username))
colnames(tmpdata)<-c("Application.Name","CoreHours","NumJobs","NumUsers")
tmpdata<-arrange(tmpdata,desc(CoreHours))
write.csv(tmpdata,file=app_gpu)
rm(tmpdata)

# Calculate CPU corehours per organisation
tmpdata<-data_cpu%>%group_by(Organization)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Organization","CoreHours","NumJobs")
tmpdata<-arrange(tmpdata,desc(CoreHours))
write.csv(tmpdata,file=orgdata_cpu)
rm(tmpdata)

# Calculate GPU corehours per organisation
tmpdata<-data_gpu%>%group_by(Organization)%>%summarise(sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Organization","CoreHours","NumJobs")
tmpdata<-arrange(tmpdata,desc(CoreHours))
write.csv(tmpdata,file=orgdata_gpu)
rm(tmpdata)

# Calculate CPU corehours per high-level organisation
tmpdata<-data_cpu%>%group_by(Organization.HighLevel)%>%summarise(CoreHours=sum(CoreHours),NumJobs=length(Job.ID))%>%arrange(desc(CoreHours))
for (org in levels(tmpdata$Organization.HighLevel)){if(!any(tmpdata$Organization.HighLevel==org)){tmpdata<-rbind(tmpdata,c(org,"0","0"))}}
write.csv(tmpdata,file=org2data_cpu)
rm(tmpdata)

# Calculate GPU corehours per high-level organisation
tmpdata<-data_gpu%>%group_by(Organization.HighLevel)%>%summarise(CoreHours=sum(CoreHours),NumJobs=length(Job.ID))%>%arrange(desc(CoreHours))
for (org in levels(tmpdata$Organization.HighLevel)){if(!any(tmpdata$Organization.HighLevel==org)){tmpdata<-rbind(tmpdata,c(org,"0","0"))}}
write.csv(tmpdata,file=org2data_gpu)
rm(tmpdata)

# Calculate CPU stats split by core
tmpdata<-data_cpu%>%group_by(CoresGroup)%>%summarise(length(Job.ID),sum(CoreHours),median(Wait.Time.Hours),mean(Wait.Time.Hours))
tmpdata<-tmpdata[match(coresgroup_sort,tmpdata$CoresGroup),]
colnames(tmpdata)<-c("Cores","Number of Jobs","Total Core Hours","Median Wait (Hours)","Mean Wait (Hours)")
write.csv(tmpdata,file=stats_by_core_cpu,row.names=FALSE)
rm(tmpdata)

# Calculate GPU stats split by core
tmpdata<-data_gpu%>%group_by(CoresGroup)%>%summarise(length(Job.ID),sum(CoreHours),median(Wait.Time.Hours),mean(Wait.Time.Hours))
tmpdata<-tmpdata[match(coresgroup_sort,tmpdata$CoresGroup),]
colnames(tmpdata)<-c("Cores","Number of Jobs","Total Core Hours","Median Wait (Hours)","Mean Wait (Hours)")
write.csv(tmpdata,file=stats_by_core_gpu,row.names=FALSE)
rm(tmpdata)
