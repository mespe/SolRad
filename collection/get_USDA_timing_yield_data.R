
source("getTimingFuns.R")

############################################################################
# Some variables for the user to set:

api.key.path <- #File where you store your api key
usda.api.key <- readLines(api.key.path)
years <- 1992:2015  #Interval of years that you are interested in
#These are the columns from the crop yield data that will be kept
columns.keep <- c('year','county_name','Value') 
#These are the columns from the crop timing data that will be kept
columns.keep.timing <- c('year','commodity_desc','unit_desc','reference_period_desc','Value')

#######################################################################################
# Main script

# Get yield data from USDA. User can add additional parameters to call.
rice.yield<-get.USDA.yield.data(api.key = usda.api.key, year = years,county_name="COLUSA")
# Clean dataframe to usable format.
rice.yield<-clean.crop.yield(rice.yield, columns.keep)

# Get crop timing data from USDA. 
rice.emerged<-get.USDA.crop.timing(usda.api.key,feature = 'RICE - PROGRESS, MEASURED IN PCT EMERGED')
rice.harvested<-get.USDA.crop.timing(usda.api.key, feature = 'RICE - PROGRESS, MEASURED IN PCT HARVESTED')

# Clean crop timing data
columns.keep.timing <- c('year','commodity_desc','unit_desc','reference_period_desc','Value')
rice.emerged <- remove.rows.timing(rice.emerged,columns.keep.timing)
rice.harvested <- remove.rows.timing(rice.harvested,columns.keep.timing)

# Combine timing data for both crop emerged and crop harvested
weekly.crop.timing <- combine.harvest.emerged(years,rice.emerged,rice.harvested)

# Add timing data to dataframe with yield data
rice.yield <- add.yield.data(rice.yield,weekly.crop.timing)
