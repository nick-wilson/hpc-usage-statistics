#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)
load(file=users_R)

# Correction for unused reservations
source("PBS-Application-Stats-Unused.R")
unused<-unused%>%filter(Organization=="XXXX")

# Characterize by Project/Personal
data$Type<-data$Project
data$Type<-as.factor(gsub('(NUS-|NTU-|A.STAR-|Industry-|SUTD-|NIS-|NSCC-|TCOMS-).*','Project',data$Type))
data$Type<-as.factor(gsub('(personal-.*|resv|Unknown)','Personal',data$Type))

#backup data
odata<-data

# Generate report of project jobs
cat("\nStats for Project Jobs"\n")
data<-odata%>%filter(Type=="Project")
filter<-"Projects."
source("PBS-Application-Stats-Generate.R")

# Generate report of personal jobs
cat("\nStats for Personal Jobs"\n")
data<-odata%>%filter(Type=="Project")
filter<-"Personal."
source("PBS-Application-Stats-Generate.R")

##cat("\nStats for Project Industry-20170004"\n")
## data<-data%>%filter(Project=="Industry-20170004")
## filter<-"P20170004."
## source("PBS-Application-Stats-Generate.R")
