#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)
load(file=users_R)

# Check for unknown applications
source("PBS-Application-Stats-Unknown.R")

# Correction for unused reservations
source("PBS-Application-Stats-Unused.R")

# combined statistics
filter<-""
source("PBS-Application-Stats-Generate.R")

#copy data for reuse by each filtered pass through the statistics generation
#could be refactored to avoid this copy if required
odata<-data
ounused<-unused

if (report_org==1) {

 # Stats by stakeholder
 for (dfilter in allorgs){
  cat("\nStats for ",dfilter,"\n")
  filter<-dfilter
  if (dfilter=="A*STAR") {
   filter<-"ASTAR"
  }
  data<-odata%>%filter(Organization.HighLevel==dfilter)
  unused<-ounused%>%filter(Organization.HighLevel==dfilter)
  filter<-paste0(filter,".")
  source("PBS-Application-Stats-Generate.R")
 }

 # Stats for selected organizations
 for (filter in c("GIS","IHPC","KOMTECH")) {
  cat("\nStats for ",filter,"\n")
  data<-odata%>%filter(Organization==filter)
  unused<-ounused%>%filter(Organization==filter)
  filter<-paste0(filter,".")
  source("PBS-Application-Stats-Generate.R")
 }

} # report_org==1

# Stats for Deep Learning applications
if (report_dl==1){
 cat("\nStats for DL\n")
 data<-odata%>%filter(Application.Name=="keras"|Application.Name=="Caffe"|Application.Name=="Torch"|Application.Name=="Theano"|Application.Name=="darknet"|Application.Name=="TensorFlow")
 unused<-ounused%>%filter(Organization=="XXXX")
 filter<-"MACHINELEARNING."
 source("PBS-Application-Stats-Generate.R")
} # report_dl==1
