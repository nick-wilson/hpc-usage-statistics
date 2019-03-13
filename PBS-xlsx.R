#!/usr/bin/env Rscript
options(java.parameters = "-Xmx1024m")
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
  rm(cells)
  rm(rows)
  rm(sheet)
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
#
csvf<-paste0("dgx/gpus-mean_dgx.",suffix,".csv")
tmp<-read.csv(csvf,header=FALSE)
cell <- cells[[23]]
setCellValue(cell,tmp[1,2])
cell <- cells[[24]]
setCellValue(cell,tmp[2,2])
rm(tmp)
csvf<-paste0("dgx/total.",suffix,".csv")
tmp<-read.csv(csvf,header=TRUE)
cell <- cells[[25]]
setCellValue(cell,tmp[1,"GPU.Hours"])
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
# 10,000 placeholders
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
# 10,000 placeholders
sc<-1
ec<-3
prefix<-'storage-byfileset'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Storage By Org'
sc<-2
ec<-8
prefix<-'storage-byorg2'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Active Users'
sc<-1
ec<-2
prefix<-'active-totals'
tmp<-myread(prefix)
myupdate(sheet_name,sc,ec,df=tmp)
nactive<-tmp[nrow(tmp),2]
prefix<-'user-summary'
tmp<-myread(prefix)
ninactive<-tmp[1,2]-nactive
nexpired<-tmp[2,2]
ntotal<-tmp[3,2]
sheet <- sheets[[sheet_name]]
rows <- getRows(sheet)
cells <- getCells(rows,colIndex=2)
cell <- cells[[1]]
setCellValue(cells[[15]],nactive)
setCellValue(cells[[16]],ninactive)
setCellValue(cells[[17]],nexpired)
setCellValue(cells[[18]],ntotal)

t<-"cpu"
u<-"CPU"
sheet_name<-paste0('Applications ',u)
# 5000 placeholders
sc<-1
ec<-5
prefix<-paste0('application_usage_',t)
myupdate(sheet_name,sc,ec,df=myread(prefix))

t<-"gpu"
u<-"GPU"
sheet_name<-paste0('Applications ',u)
# 5000 placeholders
sc<-1
ec<-5
prefix<-paste0('application_usage_',t)
tmp<-myread(prefix)
tmp<-tmp%>%filter(GPUHours>5)
myupdate(sheet_name,sc,ec,df=tmp)

for (t in c("cpu","gpu")){
  u<-"CPU"
  if (t=="gpu"){u="GPU"}
  sheet_name<-paste0('By Cores ',u)
  sc<-1
  ec<-5
  prefix<-paste0('stats_by_core_',t)
  myupdate(sheet_name,sc,ec,df=myread(prefix))

  sheet_name<-paste0('User Walltime ',u)
  # 5000 placeholders
  sc<-1
  ec<-7
  prefix<-paste0('user_walltime_',t)
  myupdate(sheet_name,sc,ec,df=myread(prefix))
  
  sheet_name<-paste0('Project ',u)
  # 100 placeholders
  sc<-1
  ec<-4
  prefix<-paste0('project_by_stakeholder_',t)
  myupdate(sheet_name,sc,ec,df=myread(prefix))
  
  sheet_name<-paste0('Org HighLevel ',u)
  # 100 placeholders
  sc<-1
  ec<-4
  prefix<-paste0('org2_walltime_',t)
  myupdate(sheet_name,sc,ec,df=myread(prefix))
  
  sheet_name<-paste0('Org Breakdown ',u)
  # 100 placeholders
  sc<-1
  ec<-4
  prefix<-paste0('org_walltime_',t)
  myupdate(sheet_name,sc,ec,df=myread(prefix))
  
  sheet_name<-paste0('Largest Jobs ',u)
  # 100 placeholders
  sc<-1
  ec<-9
  prefix<-paste0('top100_',t)
  myupdate(sheet_name,sc,ec,df=myread(prefix))
}

sheet_name<-'ApplicationsDGX'
# 1000 placeholders
sc<-1
ec<-5
prefix<-'dgx/application_usage_dgx'
tmp<-myread(prefix)
tmp<-tmp%>%filter(GPU.Hours>1)
myupdate(sheet_name,sc,ec,df=tmp)
#myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'User DGX'
# 1000 placeholders
sc<-1
ec<-7
prefix<-'dgx/user_walltime_dgx'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Projects DGX'
# 100 placeholders
sc<-1
ec<-4
prefix<-'dgx/project_usage_dgx'
myupdate(sheet_name,sc,ec,df=myread(prefix))

sheet_name<-'Org Breakdown DGX'
# 100 placeholders
sc<-1
ec<-4
prefix<-'dgx/org_walltime_dgx'
myupdate(sheet_name,sc,ec,df=myread(prefix))

# Write out completed spreadsheet
fileOutput<-paste0("application_usage-",suffix,".xlsx")
saveWorkbook(wb,file=fileOutput)
forceFormulaRefresh(file=fileOutput, output=NULL, verbose=FALSE)

#write.xlsx(data,file=fileOutput,sheetName = "All Data",append = TRUE)
