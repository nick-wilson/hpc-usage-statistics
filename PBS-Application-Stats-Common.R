
alldata_R<-paste0("data.",suffix,".Rdata")
users_R<-paste0("users.",suffix,".Rdata")
unused_csv<-paste0("unused.",suffix,".csv")

# vector to sort by core count
# should be same as labels in cleaning script, used in generate script
# TODO: refactor to an array with min,max,label
coresgroup_sort<-c("1","2-23","24","25-96","97-240","241-576",">576")

# Organizations to report against
allorgs<-c("A*STAR","NTU","NUS","SUTD","TCOMS","Industry","GOV","CREATE","SMU","NSCC","ADMIN")

#fileset_types<-c("HOME_PROJECTS","HOME_PROJECTS_CSIBIO","HOME_NOT_FILESET","HOME_PROJECTS_EXPIRED","HOME_HOMEDIRS","DATA_PROJECTS","DATA_NOT_PROJECT")
fileset_types<-c("HOME_PROJECTS","HOME_NOT_FILESET","HOME_PROJECTS_EXPIRED","HOME_HOMEDIRS","DATA_PROJECTS","DATA_NOT_PROJECT")

library(methods)
library(dplyr,warn.conflicts=FALSE)
