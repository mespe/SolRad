### code for extracting USDA data related to percentage of rice growing at any given time
### code structure from Matt Espe Apr 2015
### code by Henry Kvinge February 2007 modeled closely on code by Melissa Kardish January 2017

### This code is written to extract data from the USDA API.
### We are aiming to extract data from the database to 
### understand when rice crops were growing in California during a given year. 
### We want to eventually be able to compare this to solar radiation
### This code requires an API key that can be acquired from
### https://quickstats.nass.usda.gov/api and used as usda.api.key in the get_USDA_data function
### On 2/8/17 This extracts percentage rice emerged and percentage harvested (both weekly) 
### in California for each year specified. The output is a dataframe which has the year, the week
### number, the percentage of crop emerged, the percentage of crop harvested, and the percentage
### of the crop currently growing.

api.key.path <- '/Users/HK/Professional/solarradiation/HKChanges/usda-api-key' #File where you store your api key
usda.api.key <- readLines(api.key.path)

years <- 1990:2015 #Choose interval of years that you are interested in

insertFirstRow <- function(df, new.row) {
  # Inserts a new first row to a dataframe.
  #
  # Args:
  #   df: the dataframe you want to add a row to.
  #   new.row: a dataframe that is the new row you want to add.
  #
  # Returns:
  #   A datframe with new.row as the first row and the subsequent
  #   rows equal to df.
  df <- rbind(new.row,df)
  df
}

insertLastRow <- function(df, new.row) {
  # Inserts a new last row to a dataframe.
  #
  # Args:
  #   df: the dataframe you want to add a row to.
  #   new.row: a dataframe that is the new row you want to add.
  #
  # Returns:
  #   A datframe with new.row as the last row and the previous
  #   rows equal to df.
  df <- rbind(df,new.row)
  df
}

insertRow <- function(df,new.row,r){
  # Inserts a new first row to a dataframe.
  #
  # Args:
  #   df: the dataframe you want to add a row to.
  #   new.row: a dataframe that is the new row you want to add.
  #   r: the index at which you would like to add your new row. There
  #      is an assumption here 1 < r < #rows in df
  #
  # Returns:
  #   A datframe which is equal to df with new.row inserted
  #   at index r.
  df <- rbind(df[1:r-1,],new.row,df[r:nrow(df),])
  df
}

fillMissingWeeks <- function(df) {
  # Takes a dataframe with data for some subset of the 52 weeks
  # in the year and adds data for the missing weeks.
  #
  # Args:
  #   df: the dataframe you want to add missing weeks to.
  #
  # Returns:
  #   A dataframe with data for all 52 weeks.
  #
  # Note that there is an assumption that the existing weeks that we have data does 
  # not include week 1 or week 52
  first.week <- df[[1]][1] # Find first week we have data for.
  last.week <- df[[1]][[nrow(df)]] # Find last week we have data for.
  # Construct the a row for week 1 and week 52.
  new.first.row <- data.frame(WEEK = first.week-1,Value = 0,YEAR = df[[3]][1])
  new.last.row <- data.frame(WEEK = last.week+1,Value = 100,YEAR = df[[3]][1])
  while (first.week > 1){
    # Iterate from first week we have data from to week 1, adding missing rows with
    # crop value 0 (no crop emerged/harvested yet)
    df <- insertFirstRow(df,new.first.row)
    first.week <- first.week-1
    new.first.row <- data.frame(WEEK = first.week-1,Value = 0,YEAR = df[[3]][1])
  }
  while (last.week < 52){
    # Iterate from last week we have data from to week 52, adding missing rows with
    # crop value 100 (all crop emerged/harvested already)
    df <- insertLastRow(df,new.last.row)
    last.week <- last.week + 1
    new.last.row <- data.frame(WEEK = last.week+1,Value = 100,YEAR = df[[3]][1])
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
        new.row <- data.frame(WEEK = week,Value = step,YEAR = df[[3]][1])
        df <- insertRow(df,new.row,week)
      }
    }
  }
  df
}

remove.rows <- function(df,columns.keep){
  # Removes some of the uneccessary columns from the dataframe obtained from API and
  # reformats the numbering of the weeks.
  #
  # Args:
  #   df: Dataframe obtained from API
  #
  # Returns:
  #   Modified dataframe.
  df <- df[columns.keep]  # Use only columns we actually need.
  # Change entries "WEEK #x" to "x$.
  df['WEEK'] <- sapply(strsplit(as.character(df$'reference_period_desc'),'#'),'[',2)
  # Make the entries of 'WEEK' and 'Value' numeric.
  df['WEEK'] <- sapply(df['WEEK'],as.numeric)
  df['Value'] <- sapply(df['Value'],as.numeric)
  df
}

get.USDA.data <- function(usda.api.key, feature, commodity=c("RICE"), year=years, state="CALIFORNIA", agg_level="STATE",...){
    require(RCurl)
    require(jsonlite)

    get_data_url <-
        'https://quickstats.nass.usda.gov/api/api_GET/' ##fixed URL, seems NASS switched from http to https
        
    fromJSON(getForm(
    		  get_data_url,
    		  key = usda_api_key,
    		  source_desc = 'SURVEY',
    		  sector_desc = 'CROPS',
    		  group_desc = 'FIELD CROPS',
          commodity_desc = commodity, 
    		  statisticcat_desc = 'PROGRESS',
    		  short_desc = feature,
          year = year, ##can be a range
    		  freq_desc = 'WEEKLY',
    		  agg_level_desc=agg_level, ##used county as default, can also use 
          state_name = state, ##default set to CALIFORNIA for our questions here
                     #statisticcat_desc = statisticcat_desc, ##set default to YIELD statistics
                     ...))[[1]]
}

# Get data from API
rice.emerged<-get.USDA.data(usda.api.key,feature = 'RICE - PROGRESS, MEASURED IN PCT EMERGED')
rice.harvested<-get.USDA.data(usda.api.key, feature = 'RICE - PROGRESS, MEASURED IN PCT HARVESTED')
# Put dataframes in correct format
columns.keep <- c('year','commodity_desc','unit_desc','reference_period_desc','Value')
rice.emerged <- remove.rows(rice.emerged,columns.keep)
rice.harvested <- remove.rows(rice.harvested,columns.keep)

weekly.rice.growing <- list()
for (i in years){
  # Loop through all years requested and for each, re-index rows and add missing weeks.
  temp <- data.frame(WEEK=subset(rice.emerged, year == i)['WEEK'],
                     VALUE=subset(rice.emerged, year == i)['Value'],YEAR = i)
  temp2 <- data.frame(WEEK=subset(rice.harvested, year == i)['WEEK'],
                     VALUE=subset(rice.harvested, year == i)['Value'],YEAR = i)
  rownames(temp) <- NULL
  rownames(temp2) <- NULL
  temp <- fillMissingWeeks(temp)
  temp2 <- fillMissingWeeks(temp2)
  temp['HARVESTED_PCT'] <- temp2['Value']/100
  temp['EMERGED_PCT'] <- temp['Value']/100
  weekly.rice.growing <- rbind(weekly.rice.growing,temp)
}

# Reorganize some of the rows
weekly.rice.growing <- weekly.rice.growing[c('YEAR','WEEK','EMERGED_PCT','HARVESTED_PCT')]

# Create a new column that gives the percentage of rice growing at any given week by subtracting
# 'HARVESTED_PCT' from 'EMERGED_PCT'.
weekly.rice.growing['RICE_GROWING_PCT'] = weekly.rice.growing['EMERGED_PCT'] - 
  weekly.rice.growing['HARVESTED_PCT']



