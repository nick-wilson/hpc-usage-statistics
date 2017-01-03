
alldata_R<-'data.Rdata'
users_R<-'users.Rdata'

# vector to sort by core count
# should be same as labels in cleaning script, used in generate script
# TODO: refactor to an array with min,max,label
coresgroup_sort<-c("1","2-24","25-96","97-240","241-960",">960")

library(dplyr,warn.conflicts=FALSE)
