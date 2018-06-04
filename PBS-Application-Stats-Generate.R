
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
org2data<-paste0("org2_walltime.",filter,suffix,".csv")
app_cpu<-paste0("application_usage_cpu.",filter,suffix,".csv")
app_gpu<-paste0("application_usage_gpu.",filter,suffix,".csv")
top100_cpu<-paste0("top100_cpu.",filter,suffix,".csv")
top100_gpu<-paste0("top100_gpu.",filter,suffix,".csv")
total<-paste0("total.",filter,suffix,".csv")
stats_by_core_cpu<-paste0("stats_by_core_cpu.",filter,suffix,".csv")
stats_by_core_gpu<-paste0("stats_by_core_gpu.",filter,suffix,".csv")
cpuwall_cpu<-paste0("cpu_walltime_by_user_by_application_cpu.",filter,suffix,".csv")
cpuwall_gpu<-paste0("cpu_walltime_by_user_by_application_gpu.",filter,suffix,".csv")
project_walltime<-paste0("project_walltime.",filter,suffix,".csv")
project_by_user<-paste0("project_by_user.",filter,suffix,".csv")
project_by_stakeholder<-paste0("project_by_stakeholder.",filter,suffix,".csv")
project_storage<-paste0("storage-byproject.",suffix,".csv")

data<-data%>%filter(Node.Type!="DGX")
data_cpu<-data%>%filter(Node.Type=="CPU")
data_gpu<-data%>%filter(Node.Type=="GPU")

# Write data on all jobs
write.csv(data,file=alldata,row.names=FALSE)

# Application by Organisation
cat("Application by Organisation\n")
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

# Calculate CPU/Walltime efficiency per user per application on CPU nodes
tmpdata<-data_cpu%>%group_by(Username,Application.Name)%>%summarise(sum(CPU.Time.Hours),sum(CoreHours),sum(CPU.Time.Hours)/sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","Application","CPUHours","CoreHours","Ratio","NumJobs","Name","Organization","Organization.HighLevel")
tmpdata<-arrange(tmpdata,Ratio)
write.csv(tmpdata,file=cpuwall_cpu,row.names=FALSE)
rm(tmpdata)

# Calculate CPU/Walltime efficiency per user per application on GPU nodes
tmpdata<-data_gpu%>%group_by(Username,Application.Name)%>%summarise(sum(CPU.Time.Hours),sum(CoreHours),sum(CPU.Time.Hours)/sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","Application","CPUHours","CoreHours","Ratio","NumJobs","Name","Organization","Organization.HighLevel")
tmpdata<-arrange(tmpdata,Ratio)
write.csv(tmpdata,file=cpuwall_gpu,row.names=FALSE)
rm(tmpdata)

# Calculate CPU corehours per user
cat("Calculate corehours per user\n")
tmpdata<-data_cpu%>%group_by(Username,Application.Name)%>%rename(Top.Application=Application.Name)%>%summarise(CoreHours=sum(CoreHours))%>%arrange(desc(CoreHours))
top<-tmpdata[!duplicated(tmpdata$Username),]%>%select(Username,Top.Application)
tmpdata<-data_cpu%>%group_by(Username)%>%summarise(sum(CoreHours),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","CoreHours","NumJobs","Name","Organization","Organization.HighLevel")
tmpdata<-merge(tmpdata,top,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata<-arrange(tmpdata,desc(CoreHours))%>%select(Username,Name,Organization,CoreHours,NumJobs,Top.Application)
write.csv(tmpdata,file=userdata_cpu)
rm(tmpdata)

# Calculate GPU corehours per user
tmpdata<-data_gpu%>%group_by(Username,Application.Name)%>%rename(Top.Application=Application.Name)%>%summarise(CoreHours=sum(CoreHours))%>%arrange(desc(CoreHours))
top<-tmpdata[!duplicated(tmpdata$Username),]%>%select(Username,Top.Application)
tmpdata<-data_gpu%>%group_by(Username)%>%summarise(sum(CoreHours),sum(CoreHours/24.0),length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
colnames(tmpdata)<-c("Username","CoreHours","GPUHours","NumJobs","Name","Organization","Organization.HighLevel")
tmpdata<-merge(tmpdata,top,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata<-arrange(tmpdata,desc(CoreHours))%>%select(Username,Name,Organization,GPUHours,NumJobs,Top.Application,CoreHours)
write.csv(tmpdata,file=userdata_gpu)
rm(tmpdata)

# Calculate corehours per user per application
tmpdata<-data_cpu%>%group_by(Username,Application.Name)%>%rename(Application=Application.Name)%>%summarise(CoreHours=sum(CoreHours),NumJobs=length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)%>%select(Application,Username,Name,Organization,CoreHours,NumJobs)%>%arrange(Application,CoreHours)
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
tmpdata$CoreHours<-tmpdata$CoreHours/24.0
tmpdata$Cores<-tmpdata$Cores/24.0
tmpdata<-tmpdata%>%rename(GPUHours=CoreHours,GPUs=Cores)
colnames(tmpdata)<-c("GPU Hours","Application","Username","Job ID","Queue","GPUs","Wall time","Wait time")
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
tmpdata<-data_gpu%>%group_by(Application.Name,Username)%>%rename(Application=Application.Name)%>%summarise(GPUHours=sum(CoreHours/24.0),CoreHours=sum(CoreHours),NumJobs=length(Job.ID))
tmpdata<-tmpdata%>%group_by(Application)%>%summarize(GPUHours=sum(GPUHours),CoreHours=sum(CoreHours),NumJobs=sum(NumJobs),NumUsers=length(Username))%>%select(Application,GPUHours,NumJobs,NumUsers,CoreHours)%>%arrange(desc(GPUHours))
write.csv(tmpdata,file=app_gpu)
rm(tmpdata)

cat("Corehours per organisation\n")
data_cpu_org<-data_cpu%>%group_by(Organization)%>%summarize(Organization.HighLevel=unique(Organization.HighLevel),CoreHours=sum(CoreHours),NumJobs=length(Job.ID))
data_cpu_org<-rbind(data_cpu_org,unused)
data_cpu_org$CoreHours<-as.numeric(data_cpu_org$CoreHours)
data_cpu_org$NumJobs<-as.integer(data_cpu_org$NumJobs)
data_gpu_org<-data_gpu%>%group_by(Organization)%>%summarize(Organization.HighLevel=unique(Organization.HighLevel),GPUHours=sum(CoreHours/24.0),NumJobs=length(Job.ID))
data_gpu_org$NumJobs<-as.integer(data_gpu_org$NumJobs)

# Calculate CPU corehours per organisation
tmpdata<-data_cpu_org%>%select(-Organization.HighLevel)%>%arrange(desc(CoreHours))
write.csv(tmpdata,file=orgdata_cpu)
rm(tmpdata)

# Calculate GPU corehours per organisation
tmpdata<-data_gpu_org%>%select(-Organization.HighLevel)%>%arrange(desc(GPUHours))
write.csv(tmpdata,file=orgdata_gpu)
rm(tmpdata)

# Calculate CPU corehours per high-level organisation
tmpdata<-data_cpu_org%>%group_by(Organization.HighLevel)%>%summarise(CoreHours=sum(CoreHours),NumJobs=sum(NumJobs))%>%arrange(desc(CoreHours))
for (org in levels(tmpdata$Organization.HighLevel)){if(!any(tmpdata$Organization.HighLevel==org)){tmpdata<-rbind(tmpdata,c(org,"0","0"))}}
write.csv(tmpdata,file=org2data_cpu)
rm(tmpdata)

# Calculate GPU corehours per high-level organisation
tmpdata<-data_gpu_org%>%group_by(Organization.HighLevel)%>%summarise(GPUHours=sum(GPUHours),NumJobs=sum(NumJobs))%>%arrange(desc(GPUHours))
for (org in levels(tmpdata$Organization.HighLevel)){if(!any(tmpdata$Organization.HighLevel==org)){tmpdata<-rbind(tmpdata,c(org,"0","0"))}}
write.csv(tmpdata,file=org2data_gpu)
rm(tmpdata)

# Calculate CPU corehours on CPU and GPU nodes per high-level organisation
tmpdatac<-data_cpu_org%>%rename(CoreHours.CPU=CoreHours,NumJobs.CPU=NumJobs)
tmpdatag<-data_gpu_org%>%mutate(CoreHours.GPU=GPUHours*24.0)%>%rename(NumJobs.GPU=NumJobs)
tmpdata<-merge(tmpdatac,tmpdatag,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata[is.na(tmpdata)] <- 0
tmpdata<-tmpdata%>%group_by(Organization.HighLevel)%>%summarize(CoreHours.CPU=sum(CoreHours.CPU),NumJobs.CPU=sum(NumJobs.CPU),CoreHours.GPU=sum(CoreHours.GPU),NumJobs.GPU=sum(NumJobs.GPU))
for (org in levels(tmpdata$Organization.HighLevel)){if(!any(tmpdata$Organization.HighLevel==org)){tmpdata<-rbind(tmpdata,data.frame(Organization.HighLevel=org,CoreHours.CPU=0.0,NumJobs.CPU=0,CoreHours.GPU=0.0,NumJobs.GPU=0))}}
tmpdata<-merge(tmpdata,tmpdatag,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata<-tmpdata%>%mutate(CoreHours=CoreHours.CPU+CoreHours.GPU,NumJobs=NumJobs.CPU+NumJobs.GPU)%>%select(Organization.HighLevel,CoreHours,NumJobs,CoreHours.CPU,NumJobs.CPU,CoreHours.GPU,NumJobs.GPU)%>%arrange(desc(CoreHours))
write.csv(tmpdata,file=org2data)
rm(tmpdata,tmpdatac,tmpdatag)

# Total core hours
cat("Total core hours\n")
total_cpu<-sum(data_cpu_org$CoreHours)
total_gpu<-sum(data_gpu_org$GPUHours)*24.0
total_corehours<-data.frame(total_cpu+total_gpu,total_cpu,total_gpu)
colnames(total_corehours)<-c("Combined","CPU","GPU")
rownames(total_corehours)<-suffix
write.csv(total_corehours,total)

# Calculate CPU stats split by core
cat("Stats by core count\n")
tmpdata<-data_cpu%>%group_by(CoresGroup)%>%summarise(length(Job.ID),sum(CoreHours),median(Wait.Time.Hours),mean(Wait.Time.Hours))
tmpdata<-tmpdata[match(coresgroup_sort,tmpdata$CoresGroup),]
colnames(tmpdata)<-c("Cores","Number of Jobs","Total Core Hours","Median Wait (Hours)","Mean Wait (Hours)")
tmpdata[is.na(tmpdata)] <- 0
write.csv(tmpdata,file=stats_by_core_cpu,row.names=FALSE)
rm(tmpdata)

# Calculate GPU stats split by core
tmpdata<-data_gpu%>%group_by(CoresGroup)%>%summarise(length(Job.ID),sum(CoreHours)/24.0,median(Wait.Time.Hours),mean(Wait.Time.Hours))
coresgroup_sort_gpu<-c("24","25-96","97-240","241-960",">960")
tmpdata<-tmpdata[match(coresgroup_sort_gpu,tmpdata$CoresGroup),]
colnames(tmpdata)<-c("GPUs","Number of Jobs","Total GPU Hours","Median Wait (Hours)","Mean Wait (Hours)")
tmpdata$GPUs<-c("1","2-4","5-10","11-40",">40")
tmpdata[is.na(tmpdata)] <- 0
write.csv(tmpdata,file=stats_by_core_gpu,row.names=FALSE)
rm(tmpdata)

# Project corehours
cat("Project core hours\n")
tmpdata<-data%>%group_by(Project)%>%summarise(CoreHours=sum(CoreHours),length(Job.ID))
colnames(tmpdata)<-c("Project","CoreHours","NumJobs")
s<-read.csv(project_storage)
tmpdata<-merge(tmpdata,s,all.x=TRUE,all.y=TRUE,sort=FALSE)
tmpdata$CoreHours[is.na(tmpdata$CoreHours)] <- 0.0
tmpdata$NumJobs[is.na(tmpdata$NumJobs)] <- 0
#levels(tmpdata$home_gb)<-c(levels(tmpdata$home_gb),"-1")
tmpdata$home_gb<-as.integer(tmpdata$home_gb)
tmpdata$home_gb[is.na(tmpdata$home_gb)] <- -1
tmpdata<-tmpdata%>%arrange(desc(CoreHours),desc(home_gb))
tmpdata$Project_Short<-gsub('(A.STAR-|NUS-|Industry-|NTU-|SUTD-|SMU-)','',tmpdata$Project)
write.csv(tmpdata,file=project_walltime)
#
tmpdata$Project.Stakeholder<-tmpdata$Project
tmpdata$Project.Stakeholder<-gsub(     'NUS-11......',     'NUS-11xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(     'NTU-12......',     'NTU-12xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(  'A.STAR-13......',  'A*STAR-13xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-14......','Industry-14xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(    'SUTD-15......',    'SUTD-15xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub(     'NIS-16......',     'NIS-16xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-20......','Industry-20xxxxxx',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Industry-21......','Industry-21xxxxxx',tmpdata$Project.Stakeholder)
#
tmpdata$Project.Stakeholder<-gsub('personal-.*','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('Unknown','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('resv','Personal',tmpdata$Project.Stakeholder)
tmpdata$Project.Stakeholder<-gsub('30003671','Personal',tmpdata$Project.Stakeholder)
tmpdata[tmpdata$home_gb==-1,"home_gb"]<-0
tmpdata<-tmpdata%>%group_by(Project.Stakeholder)%>%summarise(CoreHours=sum(CoreHours),NumJobs=sum(NumJobs),Storage.GB=sum(home_gb))%>%arrange(desc(CoreHours),desc(Storage.GB))
write.csv(tmpdata,file=project_by_stakeholder)
rm(tmpdata)

# Corehours per user per project
cat("Project core hours\n")
tmpdata<-data%>%group_by(Username,Project)%>%summarise(CoreHours=sum(CoreHours),NumJobs=length(Job.ID))
tmpdata<-merge(tmpdata,users,all.x=TRUE,all.y=FALSE,sort=FALSE)
tmpdata<-tmpdata%>%select(Username,Organization,Project,CoreHours,NumJobs,Name,Organization.HighLevel)%>%arrange(desc(CoreHours))
tmpdata$Project_Short<-gsub('(A.STAR-|NUS-|Industry-|NTU-|SUTD-|SMU-)','',tmpdata$Project)
write.csv(tmpdata,file=project_by_user)
rm(tmpdata)
