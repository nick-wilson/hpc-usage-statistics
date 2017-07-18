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

if ( monthly==1) {
#copy data for reuse by each filtered pass through the statistics generation
#could be refactored to avoid this copy if required
odata<-data
ounused<-unused

# Stats for High-Level Institutions
# These are defined in the R script which cleans the data
dfilter<-"A*STAR"
data<-odata%>%filter(Organization.HighLevel==dfilter)
unused<-ounused%>%filter(Organization.HighLevel==dfilter)
filter<-"ASTAR."
source("PBS-Application-Stats-Generate.R")

for (filter in c("NUS","NTU","CREATE","SUTD")){
 data<-odata%>%filter(Organization.HighLevel==filter)
 unused<-ounused%>%filter(Organization.HighLevel==filter)
 filter<-paste0(filter,".")
 source("PBS-Application-Stats-Generate.R")
}

# Stats for Individual Organizations
for (filter in c("GIS","IHPC")) {
 data<-odata%>%filter(Organization==filter)
 unused<-ounused%>%filter(Organization==filter)
 filter<-paste0(filter,".")
 source("PBS-Application-Stats-Generate.R")
}

## ## CREATE
## ## BEARS-BERKELEY CARES E2S2 ETHZ NRD SinBerBEST SinBeRISE SMART TUM-CREATE
## for (filter in c("BEARS-BERKELEY","CARES","E2S2","ETHZ","NRD","SINBERBEST","SINBERISE","SMART","TUM-CREATE")) {
##  data<-odata%>%filter(Organization==filter)
##  filter<-paste0(filter,".")
##  source("PBS-Application-Stats-Generate.R")
## }

} # monthly=1
