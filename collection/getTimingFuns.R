### Code for extracting and cleaning data from USDA
### Code for API calls by Matt Espe (April 2015) and Melissa Kardish (January 2017)
### Code for cleaning and combining data by Henry Kvinge (February 2017)
#
#
### This code pulls data from the USDA API on both rice crop yields and timing in CA.
### The code puts this into a usable format and then combines both sets of data into 
### a single dataframe. The user can pick what years they are interested in, as well as
### specifying the counties that they want yield data from (note however that timing
### data only exists at the state level). The code removes a significant number of the
### columns returned from the API call. The user can choose to change what columns are 
### kept (change variables 'columns.keep' and 'columns.keep.timing').
###
### Also note that at the moment, yield data is given in (lbs/acre).
###
### After running the code, the dataframe 'rice.yield' will contain both the yield
### data and the timing data.

###############################################################################
# Functions

# Duplicates get_USDA_data
# get.USDA.yield.data <- function(api.key, year=years, commodity=c("RICE"), state="CALIFORNIA", statisticcat_desc = "YIELD", agg_level="COUNTY",...){
#   # Gets crop yield data from USDA API.
#   #
#   # Args:
#   #   api_key: the API key you use for the USDA website.
#   #   new.row: a dataframe that is the new row you want to add.
#   #
#   # Returns:
#   #   A datframe with new.row as the first row and the subsequent
#   #   rows equal to df.
#   require(RCurl)
#   require(jsonlite)
  
#   #API url
#   get.data.url <-
#     'https://quickstats.nass.usda.gov/api/api_GET/' 
  
#   fromJSON(getForm(
#     get.data.url, 
#     key = api.key,
#     commodity_desc = commodity, 
#     year = year, ##can be a range
#     state_name = state, ##default set to CALIFORNIA for our questions here
#     statisticcat_desc = statisticcat_desc, ##set default to YIELD statistics
#     agg_level_desc=agg_level, ##used county as default, can also use 
#     ...))[[1]]
# }

clean.crop.yield <- function(df,col.names){
  # Put crop yield data in a form we can use, this includes
  # removing unnecessary columns and converting string entries
  # to numeric entries.
  #
  # Args:
  #   df: yield dataframe to be cleaned.
  #   col.names: names of columns you want to keep.
  #
  # Returns:
  #   A cleaned dataframe.
  df <- df[col.names]
  names(df)[names(df)=="Value"] <- "yield"
  df['yield'] <- lapply(df['yield'], FUN = function(x) as.numeric(gsub(",", "", x)))
  df['year'] <- as.numeric(df$year)
  df
}

insertRow <- function(df,new.row,r){
  # Inserts a new first row to a dataframe.
  #
  # Args:
  #   df: the dataframe you want to add a row to.
  #   new.row: a dataframe that is the new row you want to add.
  #   r: the index at which you would like to add your new row. There
  #      is an assumption here r <= #rows+1 in df
  #
  # Returns:
  #   A datframe which is equal to df with new.row inserted
  #   at index r.
  if (r == nrow(df)+1){
    df <- rbind(df,new.row)
  } else if (r == 1){
    df <- rbind(new.row,df)
  } else {
    df <- rbind(df[1:r-1,],new.row,df[r:nrow(df),])
  }
  df
}

fill.missing.weeks <- function(df) {
  # Takes a dataframe with data for some subset of the 52 weeks
  # in the year and adds data for the missing weeks.
  #
  # Args:
  #   df: the dataframe you want to add missing weeks to.
  #
  # Returns:
  #   A dataframe with data for all 52 weeks.
  #
  first.week <- df[[1]][1] # Find first week we have data for.
  last.week <- df[[1]][[nrow(df)]] # Find last week we have data for.
  # Construct the a row for week 1 and week 52.
  new.first.row <- data.frame(week = first.week-1,Value = 0,YEAR = df[[3]][1])
  new.last.row <- data.frame(week = last.week+1,Value = 100,YEAR = df[[3]][1])
  while (first.week > 1){
    # Iterate from first week we have data from to week 1, adding missing rows with
    # crop value 0 (no crop emerged/harvested yet)
    df <- insertRow(df,new.first.row,1)
    first.week <- first.week-1
    new.first.row <- data.frame(week = first.week-1,Value = 0,YEAR = df[[3]][1])
  }
  while (last.week < 52){
    # Iterate from last week we have data from to week 52, adding missing rows with
    # crop value 100 (all crop emerged/harvested already)
    df <- insertRow(df,new.last.row,nrow(df)+1)
    last.week <- last.week + 1
    new.last.row <- data.frame(week = last.week+1,Value = 100,YEAR = df[[3]][1])
  }
  if (nrow(df) != 52){
    # Check that all 52 weeks are present
    for (week in 1:52){
      # If not all weeks present iterate through and find missing rows and add them.
      if (df[[1]][week] != week){
        # value.week is the number of weeks missing in a given interval
        value.week <- df[[1]][week]-df[[1]][week-1]
        # value.diff is the change in crop emerged/harvested during the interval
        value.diff <- df[[2]][week]-df[[2]][week-1]
        # Get a linear estimation of how much of the crop emerged/was harversted
        # during this interval
        step <- value.diff/value.week + df[[1]][week-1]
        new.row <- data.frame(week = week,Value = step,YEAR = df[[3]][1])
        df <- insertRow(df,new.row,week)
      }
    }
  }
  df
}


remove.rows.timing <- function(df,columns.keep){
  # Removes some of the uneccessary columns from the crop timing dataframe obtained 
  # from API and reformats the numbering of the weeks.
  #
  # Args:
  #   df: Crop timing dataframe obtained from API
  #
  # Returns:
  #   Modified dataframe.
  df <- df[columns.keep]  # Use only columns we actually need.
  # Change entries "week #x" to "x$.
  df['week'] <- sapply(strsplit(as.character(df$'reference_period_desc'),'#'),'[',2)
  # Make the entries of 'week' and 'Value' numeric.
  df['week'] <- sapply(df['week'],as.numeric)
  df['Value'] <- sapply(df['Value'],as.numeric)
  df
}

combine.harvest.emerged <- function(years,rice.emerged,rice.harvested) {
  # Combines data about the time rice emerged to the time it was harvested.
  #
  # Args:
  #   rice.emerged: dataframe with weekly percentage of rice emerged
  #   rice.harvested: dataframe with weekly percentage of rice harvested
  #
  # Returns:
  #   dataframe with percentage.growing variable.
  weekly.crop.timing <- list()
  for (i in years){
    # Loop through all years requested and for each, re-index rows and add missing weeks.
    temp <- data.frame(week=subset(rice.emerged, year == i)['week'],
                       VALUE=subset(rice.emerged, year == i)['Value'],YEAR = i)
    temp2 <- data.frame(week=subset(rice.harvested, year == i)['week'],
                        VALUE=subset(rice.harvested, year == i)['Value'],YEAR = i)
    rownames(temp) <- NULL
    rownames(temp2) <- NULL
    temp <- fill.missing.weeks(temp)
    temp2 <- fill.missing.weeks(temp2)
    temp['percentage.harvested'] <- temp2['Value']/100
    temp['percentage.emerged'] <- temp['Value']/100
    weekly.crop.timing <- rbind(weekly.crop.timing,temp)
  }
  weekly.crop.timing['percentage.growing'] = weekly.crop.timing['percentage.emerged'] - 
    weekly.crop.timing['percentage.harvested']
  weekly.crop.timing
}


## This appears to be duplicate code from above

# get.USDA.crop.timing <- function(usda.api.key, feature, commodity=c("RICE"), year=years, state="CALIFORNIA", agg_level="STATE",...){
#   require(RCurl)
#   require(jsonlite)
  
#   get.data.url <-
#     'https://quickstats.nass.usda.gov/api/api_GET/' ##fixed URL, seems NASS switched from http to https
  
#   fromJSON(getForm(
#     get.data.url,
#     key = usda.api.key,
#     source_desc = 'SURVEY',
#     sector_desc = 'CROPS',
#     group_desc = 'FIELD CROPS',
#     commodity_desc = commodity, 
#     statisticcat_desc = 'PROGRESS',
#     short_desc = feature,
#     year = year, ##can be a range
#     freq_desc = 'WEEKLY',
#     agg_level_desc=agg_level, ##used county as default, can also use 
#     state_name = state, ##default set to CALIFORNIA for our questions here
#     #statisticcat_desc = statisticcat_desc, ##set default to YIELD statistics
#     ...))[[1]]
# }

add.yield.data <- function(rice.yield,weekly.crop.timing){
  # Add yield data to timing dataframe.
  #
  # Args:
  #   rice.yield: dataframe with yield data
  #   weekly.crop.timing: dataframe with timing data
  #
  # Returns:
  #   a dataframe with both yield and timing data
  rice.yield <- rice.yield[rep(row.names(rice.yield),52),1:3]
  rice.yield <- rice.yield[ order(rice.yield[,1]), ]
  rice.yield[c('week','percentage.growing')] <- weekly.crop.timing[c('week','percentage.growing')]
  rownames(rice.yield) <- NULL
  rice.yield
}



getAvgDates <- function(riceDF){
    avg_emerg <- findAvg(riceDF$percentage.growing[1:30], riceDF$week[1:30])
    avg_harv <- findAvg(riceDF$percentage.growing[30:52], riceDF$week[30:52])
    
    return(data.frame(YEAR = unique(riceDF$YEAR),
                      avg_emerg, avg_harv))
}

findAvg <- function(percents, weeks){
    # Finds the 50% point, given a vector with weekly %
    # x: vector representing 
    if(any(percents == 0.500))
        return(weeks[percents == 0.500])

    weeks[which.min(abs(0.50 - percents))]

}

