#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# files
p_before<-read.csv(paste0("ams-baseline.",suffix,".csv"))
p_after<-read.csv(paste0("ams-projects.",suffix,".csv"))
p_used<-read.csv(paste0("project_walltime.",suffix,".csv"))
f_out<-paste0("ams-diff.",suffix,".csv")
f_out_summary<-paste0("ams-diff-summary.",suffix,".csv")

before<-p_before%>%filter(serviceunit=="cpu_hrs")%>%select(name,ams_before=total_debits_reconciled)
after<-p_after%>%filter(serviceunit=="cpu_hrs")%>%select(name,ams_after=total_debits_reconciled)
used<-p_used%>%select(name=Project_Short,used=CoreHours)

# clean baseline AMS data
tmp<-as.character(before$ams_before)
tmp<-as.numeric(tmp)
before$ams_before<-tmp
before<-na.omit(before)
before$name<-as.character(before$name)

# clean final AMS data
tmp<-as.character(after$ams_after)
tmp<-as.numeric(tmp)
after$ams_after<-tmp
after<-na.omit(after)
after$name<-as.character(after$name)

# clean project walltime
used$name<-as.character(used$name)

# merge data together
merged<-merge(after,before,all.x=FALSE,all.y=FALSE)
diff<-merge(used,merged,all.x=FALSE,all.y=FALSE)
diff$ams<-diff$ams_after-diff$ams_before
diff$diff<-diff$ams-diff$used

# sort and write
diff<-diff%>%arrange(desc(diff))
write.csv(diff,f_out,row.names = FALSE)

# calculate statistics and write
diff_abs<-sum(abs(diff$diff))
diff_sum<-sum(diff$diff)
diff_over<-sum(diff$diff[which(diff$diff>0)])
diff_under<-sum(diff$diff[which(diff$diff<0)])
df<-data.frame(suffix,diff_abs,diff_sum,diff_over,diff_under)
write.csv(df,f_out_summary,row.names = FALSE)

# print statistics
print(df)
