#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

#install.packages("xlsx")
library(xlsx)

# Load template
file<-"template.xlsx"
wb <- loadWorkbook(file)
sheets <- getSheets(wb)

myread<-function(prefix){
  csvf<-paste0(prefix,".",suffix,".csv")
  df<-read.csv(csvf,header=TRUE)
  return(df)
}
  
myupdate<-function(sheet_name,sc,ec,df){
  print(sheet_name)
  sheet <- sheets[[sheet_name]]
  # manual double loop over rows and columns
  # pre-formatted template has first 1000 rows filled with spaces
  # otherwise getCells() does not return valid objects
  # the ideal would be to add rows without affecting formatting
  nc<-ec-sc+1
  ##DEBUG##print(nc)
  for (i in seq(1,nrow(df))){
    k<-i+1
    rows<-getRows(sheet,rowIndex=k)
    cells <- getCells(rows,colIndex=1:nc)
    for (j in seq(sc,ec)){
      jj<-j-sc+1
      ##DEBUG##print(i)
      ##DEBUG##print(j)
      ##DEBUG##print(jj)
      ##DEBUG##print("set")
      setCellValue(cells[[jj]],df[i,j],showNA=FALSE)
    }
  }
  ## If you don't want to preserve formatting you can just use
  # addDataFrame(df,sheet,col.names=FALSE,row.names=FALSE,startRow=2,startColumn=1)
  return
}

# Queue First Job sheet
sheet_name<-'Queue First Job'
sc<-1
ec<-9
prefix<-'queue_firstrun'
tmp<-myread(prefix)
# convert text % to numerical value for pre-formatted Excel cells
tmp$percent_10min<-as.numeric(sub("%", "", tmp$percent_10min))/100.0
tmp$percent_120min<-as.numeric(sub("%", "", tmp$percent_120min))/100.0
myupdate(sheet_name,sc,ec,tmp)
rm(tmp)

# Cores Summary sheet
sheet <- sheets[['Core Summary']]
rows <- getRows(sheet)
cells <- getCells(rows,colIndex=2)
csvf<-paste0("cores-mean.",suffix,".csv")
tmp<-read.csv(csvf,header=FALSE)
cell <- cells[[1]]
setCellValue(cell,tmp[1,2])
cell <- cells[[2]]
setCellValue(cell,tmp[2,2])
cell <- cells[[3]]
setCellValue(cell,tmp[3,2])
cell <- cells[[4]]
setCellValue(cell,tmp[4,2])
#
cell <- cells[[8]]
setCellValue(cell,hours)
#
csvf<-paste0("gpus-mean.",suffix,".csv")
tmp<-read.csv(csvf,header=FALSE)
cell <- cells[[13]]
setCellValue(cell,tmp[1,2])
cell <- cells[[14]]
setCellValue(cell,tmp[2,2])
cell <- cells[[15]]
setCellValue(cell,tmp[3,2])
cell <- cells[[16]]
setCellValue(cell,tmp[4,2])
rm(tmp)
#
csvf<-paste0("total.",suffix,".csv")
tmp<-read.csv(csvf,header=TRUE)
cell <- cells[[9]]
setCellValue(cell,tmp[1,"Combined"])
cell <- cells[[20]]
setCellValue(cell,tmp[1,"GPU"]/24.0)
rm(tmp)

sheet_name<-'Project Usage'
sc<-1
ec<-7
prefix<-'project_walltime_info'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Project Stakeholder'
sc<-1
ec<-5
prefix<-'project_by_stakeholder'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Project Status'
sc<-1
ec<-6
prefix<-'ams-projects'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Personal Status'
sc<-1
ec<-6
prefix<-'ams-personal'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Storage Summary'
sc<-1
ec<-3
prefix<-'storage-byfileset-summary'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Storage by Fileset'
sc<-1
ec<-3
prefix<-'storage-byfileset'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Storage By Org'
sc<-2
ec<-8
prefix<-'storage-byorg2'
myupdate(sheet_name,sc,ec,df=myread(prefix))

# sheet_name<-'xxx'
# sc,ec<-xxx
# prefix<-'xxx'
# myupdate(sheet_name,sc,ec,df=myread(prefix))


# Project Stakeholder -> project_by_stakeholder.$DATE_RANGE.csv 5
# Project Status -> ams-projects.$DATE_RANGE.csv 6
# Personal Status -> ams-personal.$DATE_RANGE.csv 6
# Storage Summary -> storage-byfileset-summary.$DATE_RANGE.csv 3
# Storage by Fileset -> storage-byfileset.$DATE_RANGE.csv 3
# Storage By Org -> storage-byorg2.$DATE_RANGE.csv 9x7
# Active Users ->  active-totals.$DATE_RANGE.csv
# 
# By Cores CPU ->  stats_by_core_cpu.$DATE_RANGE.csv
# Applications CPU -> application_usage_cpu.$DATE_RANGE.csv
# User Walltime CPU -> user_walltime_cpu.$DATE_RANGE.csv
# Org HighLevel CPU -> org2_walltime_cpu.$DATE_RANGE.csv
# Org Breakdown CPU ->  org_walltime_cpu.$DATE_RANGE.csv
# Largest Jobs CPU -> top100_cpu.$DATE_RANGE.csv
# 
# By Cores GPU ->  stats_by_core_gpu.$DATE_RANGE.csv
# Applications GPU -> application_usage_gpu.$DATE_RANGE.csv
# User Walltime GPU -> user_walltime_gpu.$DATE_RANGE.csv
# Org HighLevel GPU -> org2_walltime_gpu.$DATE_RANGE.csv
# Org Breakdown GPU ->  org_walltime_gpu.$DATE_RANGE.csv
# Largest Jobs GPU -> top100_gpu.$DATE_RANGE.csv
#
# Cumulative
#
# DGX sheet


# Write out completed spreadsheet
fileOutput<-paste0("application_usage-",suffix,".xlsx")
saveWorkbook(wb,file=fileOutput)
forceFormulaRefresh(file=fileOutput, output=NULL, verbose=FALSE)

#write.xlsx(data,file=fileOutput,sheetName = "All Data",append = TRUE)
