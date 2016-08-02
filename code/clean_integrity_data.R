
library(data.table)
library(dplyr)
library(readxl)
library(knitr)
library(lubridate)
knitr::opts_chunk$set(echo = TRUE)
library(readxl)
rm(list=ls())

temp = read.csv('input/integrity_db/OID.OperationSearchResults.2016.7.1.3-57 PM.csv',na.strings = "",stringsAsFactors = F)
temp$Operation.ID = as.character(temp$Operation.ID)

names(temp) = gsub('\\/','.',names(temp))
names(temp) = gsub(' ','.',names(temp))

temp = temp %>% mutate(
  City_master = ifelse(!is.na(City),City,City.1),
  Country_master = ifelse(!is.na(Country),Country,Country.1),
  State_master = ifelse(!is.na(State.Province),State.Province,State.Province.1),
  ZIP.Postal.Code_master =ifelse(!is.na(ZIP.Postal.Code),Country,Country.1))


cert_df = temp %>% filter(grepl('United States',Country_master)) %>% select(Certifier.Name) %>% filter(!duplicated(Certifier.Name)) %>%
  arrange(Certifier.Name)
write.csv(cert_df,'input/competition_input/certifiers.csv')


temp = temp %>% filter(grepl('United States',Country_master)) %>%
  rename(Last_Date = Effective.Date.of.Operation.Status,
         Status = Operation.Certification.Status) %>%
  mutate(Last_Date = mdy(Last_Date)) %>% mutate(Dec_Date =decimal_date(Last_Date),Year = year(Last_Date),Month = month(Last_Date))  %>% rename(Certifier = Certifier.Name)


library(tidyr)

years = 2002:2016
uq.operator = unique(temp$Operation.ID)
op_year_combos = expand.grid(years,uq.operator)
colnames(op_year_combos) = c('Year','Operation.ID')
op_year_combos$Active = NA

still_active = filter(temp,Status =='Certified')
inactive = filter(temp,Status!='Certified')

op_year_combos$Active[match(still_active$Operation.ID,op_year_combos$Operation.ID)] = 1

temp_post_2002 = temp %>% filter(Year>2002)
year_vec = sapply(ifelse(temp_post_2002$Status=='Certified',2016,temp_post_2002$Year-1),function(x) 2002:x)

year_grid_expand = lapply(1:nrow(temp_post_2002),function(x)
  expand.grid(temp_post_2002$Operation.ID[x],year_vec[[x]]))

active_id_by_year =  do.call('rbind',year_grid_expand)
colnames(active_id_by_year) = c('Operation.ID','Year')



active_id_by_year$State_master = temp_post_2002$State_master[match(active_id_by_year$Operation.ID,temp_post_2002$Operation.ID)]
active_id_by_year$Certifier = temp_post_2002$Certifier[match(active_id_by_year$Operation.ID,temp_post_2002$Operation.ID)]


active_in_state = active_id_by_year %>% group_by(State_master,Year) %>% summarize(active_in_state = n())
active_in_state$State_Abb = state.abb[match(active_in_state$State_master,state.name)]
write.csv(active_in_state,'input/competition_input/operations_by_state_year.csv')

active_in_state_by_certifier = active_id_by_year %>% group_by(State_master,Year,Certifier) %>%
  summarize(active = n())
active_in_state_by_certifier$State_Abb = state.abb[match(active_in_state_by_certifier$State_master,state.name)]
write.csv(active_in_state_by_certifier,'input/competition_input/operations_by_state_year_certifier.csv')


cert_state_year = lapply(2002:2016,function(x) 
  as.matrix(table(
    as.character(
      active_in_state_by_certifier$Certifier[active_in_state_by_certifier$Year==x]),
    as.character(active_in_state_by_certifier$State_master[active_in_state_by_certifier$Year==x]))))

cert_state_year_df_list = lapply(1:length(cert_state_year),function(x) as.data.frame(cert_state_year[[x]]) %>%
                                   mutate(Year = (2002:2016)[x]))

cert_state_links = do.call('rbind',cert_state_year_df_list)
names(cert_state_links) = c('Certifier','State','Active','Year')
cert_state_links$Active = cert_state_links$Active == 1

write.csv(cert_state_links,'input/competition_input/certifier_in_state_by_year.csv')
