#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

#install.packages("xlsx")
library(xlsx)

# Load template
file<-"application_usage-template.xlsx"
wb <- loadWorkbook(file)

# Cores Summary sheet
sheets <- getSheets(wb)
sheet <- sheets[['Core Summary']]
rows <- getRows(sheet)
cells <- getCells(rows,colIndex=2)
csvf<-paste0("cores-mean.",suffix,".csv")
d<-read.csv(csvf,header=FALSE)
cell <- cells[[1]]
setCellValue(cell,d[1,2])
cell <- cells[[2]]
setCellValue(cell,d[2,2])
cell <- cells[[3]]
setCellValue(cell,d[3,2])
cell <- cells[[4]]
setCellValue(cell,d[4,2])
#
cell <- cells[[8]]
setCellValue(cell,hours)
#
csvf<-paste0("gpus-mean.",suffix,".csv")
d<-read.csv(csvf,header=FALSE)
cell <- cells[[13]]
setCellValue(cell,d[1,2])
cell <- cells[[14]]
setCellValue(cell,d[2,2])
cell <- cells[[15]]
setCellValue(cell,d[3,2])
cell <- cells[[16]]
setCellValue(cell,d[4,2])
#
csvf<-paste0("total.",suffix,".csv")
d<-read.csv(csvf,header=TRUE)
cell <- cells[[9]]
setCellValue(cell,d[1,"Combined"])
cell <- cells[[20]]
setCellValue(cell,d[1,"GPU"]/24.0)

# Write out completed spreadsheet
fileOutput<-paste0("application_usage-",suffix,".xlsx")
saveWorkbook(wb,file=fileOutput)
forceFormulaRefresh(file=fileOutput, output=NULL, verbose=FALSE)

#write.xlsx(data,file="application_usage-template.xlsx",sheetName = "All Data",append = TRUE)
