library(data.table)
library(dplyr)
library(readxl)

## load csv files
dts = lapply(paste0('input/',grep('\\.csv',list.files('input/'),value=T)),fread)
## drop blank empty columns
dts = lapply(dts, function(x) x[,colSums(!(is.na(x)|x=='')) != 0,with=F])
years = 2012:2016
for (i in 1:length(dts)){dts[[i]]$Year = years[i]}




lapply(1:5, function(x) dts[[x]]$Year <- years[x])
dts[[2]]$Year
dts[[2]]$Year = years[2]

lapply(dts,dim)
 
lapply(dts, function(x) !grepl('Column',names(it12)),with=F)

it12 = data.table::fread('input/integrity12.csv')
it12 = it12[,!grepl('Column',names(it12)),with=F]

it13 = data.table::fread('input/integrity12.csv')
it13 = it12[,!grepl('Column',names(it12)),with=F]



it12 = it12[,!grepl('Column',names(it12)),with=T]


ans2 <- DT[list("R","h")])


rm(test)

test = read.csv('input/integrity12.csv')

names(it12)


head(test)
head(it12)
names(it12)[1:19]
names(test)


