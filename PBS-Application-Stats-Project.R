#!/usr/bin/env Rscript

source("config.R")
source("PBS-Application-Stats-Common.R")

# Load cleaned data
load(file=alldata_R)
load(file=users_R)

filter<-""
source("PBS-Application-Stats-Generate-Project.R")
