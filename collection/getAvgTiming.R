### Script adapted from Henry's script get_USDA_timing...
# M. Espe
# March 2017

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

vars <- c("EMERGED","HEADED","HARVESTED")

# Get everything in one shot
rice.timing <- lapply(vars, function(var){
    get_USDA_data(api_key = usda.api.key, statisticcat_desc = "PROGRESS",
                  agg_level = "STATE", year = years,
                  short_desc = paste0('RICE - PROGRESS, MEASURED IN PCT ', var))
})

# Clean
rice.timing <- lapply(rice.timing, mungeTiming)

ans <- lapply(seq_along(rice.timing), function(j){
    lapply(unique(rice.timing[[j]]$year), function(yr){
        # Loop over years and pull out the date of average XXX
        i <- rice.timing[[j]]$year == yr
        result <- findAvg(rice.timing[[j]]$Value[i], rice.timing[[j]]$week_ending[i])
        return(data.frame(result))
        })
})

ans <- lapply(ans, function(x) do.call(rbind, x))

ans <- lapply(seq_along(ans), function(i) {
    colnames(ans[[i]])[2] <- vars[i]
    return(ans[[i]])
    })

ans <- do.call(cbind, ans)
colnames(ans) <- vars
ans$year <- as.integer(format(ans[,1], "%Y"))

rice.yield <- merge(rice.yield, ans)

############ Munging on yield data ############

rice.yield$Value <- as.numeric(gsub(",", "", rice.yield$Value))

rice.yield <- rice.yield[,!grepl("week_ending|CV|^countr?y|_desc|_code|load_time|state_ansi|zip_5", colnames(rice.yield))]
colnames(rice.yield)[colnames(rice.yield) == "Value"] <- "yield_lb_ac"

write.csv(rice.yield, file = "../data/rice_yield_avg_timing.csv", row.names = FALSE)
