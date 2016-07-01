library(data.table)
library(dplyr)
library(readxl)

data.table::fread('input/integrity12.csv')
it12 = readxl::read_excel('input/integrity12.xls')
head(it12)
names(it12)[1:19]
