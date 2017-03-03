source("getTimingFuns.R")
source("get_USDA_data.R")

############################################################################
# Some variables for the user to set:

api.key.path <- "~/Dropbox/usda_api_key.txt"#File where you store your api key
usda.api.key <- readLines(api.key.path)
years <- 1992:2016  #Interval of years that you are interested in
#These are the columns from the crop yield data that will be kept
columns.keep <- c('year','county_name','Value') 
#These are the columns from the crop timing data that will be kept
columns.keep.timing <- c('year','commodity_desc','unit_desc','reference_period_desc','Value')

#######################################################################################
# Main script

# Get yield data from USDA. User can add additional parameters to call.
# Use same fuction for all API calls
rice.yield<-get_USDA_data(api_key = usda.api.key, year = years, agg_level = "STATE",
                          source_desc = "SURVEY", reference_period_desc = "YEAR",
                          short_desc = "RICE - YIELD, MEASURED IN LB / ACRE")

# Clean dataframe to usable format.
##rice.yield<-clean.crop.yield(rice.yield, columns.keep)

# Get crop timing data from USDA. 
rice.emerged<-get_USDA_data(api_key = usda.api.key, statisticcat_desc = "PROGRESS",
                            agg_level = "STATE", year = years,
                            short_desc = 'RICE - PROGRESS, MEASURED IN PCT EMERGED')


rice.harvested<-get_USDA_data(api_key = usda.api.key, statisticcat_desc = "PROGRESS",
                            agg_level = "STATE", year = years,
                            short_desc = 'RICE - PROGRESS, MEASURED IN PCT HARVESTED')

# Clean crop timing data
columns.keep.timing <- c('year','commodity_desc','unit_desc','reference_period_desc','Value')
rice.emerged <- remove.rows.timing(rice.emerged,columns.keep.timing)
rice.harvested <- remove.rows.timing(rice.harvested,columns.keep.timing)

# Combine timing data for both crop emerged and crop harvested
weekly.crop.timing <- combine.harvest.emerged(years,rice.emerged,rice.harvested)

# Add timing data to dataframe with yield data
# not sure this is what we want to be doing
# rice.yield <- add.yield.data(rice.yield,weekly.crop.timing)

# need to collapse this down to a single obs per year
weekly.split <- split(weekly.crop.timing, weekly.crop.timing$YEAR)

weekly.tmp <- do.call(rbind, lapply(weekly.split, getAvgDates))

rice.yield <- merge(rice.yield, weekly.tmp, by.x = "year", by.y = "YEAR")

write.csv(rice.yield, file = "state_rice_yield.csv", row.names = FALSE)
