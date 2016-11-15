#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

load(file=alldata_R)
load(file=users_R)
filter<-"GIS"
data<-data%>%filter(Organization==filter)
filter<-paste0(filter,".")

source("PBS-Application-Stats-Generate.R")
