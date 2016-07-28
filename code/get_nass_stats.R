
library(RCurl)
nass_key = '62511A98-594C-366D-9B15-8C11D5A4DFD0'

library(dplyr)
library(jsonlite)
base = "http://quickstats.nass.usda.gov/api/api_GET/?key="
#nass_key

call_acreage = "&source_desc=CENSUS&short_desc=FARM OPERATIONS - ACRES OPERATED&year__GE=2002&agg_level_desc=COUNTY&domain_desc=TOTAL"
call_acreage_per_operation = "&source_desc=CENSUS&short_desc=FARM OPERATIONS - AREA OPERATED, MEASURED IN ACRES / OPERATION&year__GE=2002&agg_level_desc=COUNTY&domain_desc=TOTAL"
call_acreage_per_operation_med = "&source_desc=CENSUS&short_desc=FARM OPERATIONS - AREA OPERATED, MEASURED IN ACRES / OPERATION, MEDIAN&year__GE=2002&agg_level_desc=COUNTY&domain_desc=TOTAL"
call_operations = "&source_desc=CENSUS&short_desc=FARM OPERATIONS - NUMBER OF OPERATIONS&year__GE=2002&agg_level_desc=COUNTY&domain_desc=TOTAL"
call_asset_value = "&source_desc=CENSUS&short_desc=AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $ / ACRE&year__GE=2002&agg_level_desc=COUNTY&domain_desc=TOTAL"

county_acreage = fromJSON(URLencode(paste0(base,nass_key,call_acreage))) %>% .[[1]]
county_acreage_per_operation = fromJSON(URLencode(paste0(base,nass_key,call_acreage_per_operation))) %>% .[[1]] 
county_acreage_per_operation_med = fromJSON(URLencode(paste0(base,nass_key,call_acreage_per_operation_med))) %>% .[[1]]
county_operations = fromJSON(URLencode(paste0(base,nass_key,call_operations))) %>% .[[1]] 

county_asset_value = fromJSON(URLencode(paste0(base,nass_key,call_asset_value))) %>% .[[1]] 

county_ag_summary = plyr::join_all(list(county_acreage,county_acreage_per_operation,
                                        county_acreage_per_operation_med,county_operations,
                                        county_asset_value),
                                   type='full')

keep = c('state_name','state_alpha','state_fips_code','county_name',
         'county_code','unit_desc','Value','year')
county_ag_wide = county_ag_summary %>% select(one_of(keep)) %>% spread(unit_desc,Value) %>%
rename(DOLLARS_PER_ACRES = `$ / ACRE`,ACRES_PER_OPERATION = `ACRES / OPERATION`,
       ACRES_PER_OPERATION_MEDIAN = `ACRES / OPERATION, MEDIAN`) %>%
  mutate(FIPS = paste0(state_fips_code,county_code))

write.csv(county_ag_wide,'input/ag_stats/county_ag_statistics.csv')

