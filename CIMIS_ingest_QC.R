#script assumes that desired temporal coverage (in years) is determined during CIMIS data query, so defining a subset of years is not a part of this script

#focus of QC check is currently on solar radiation data.  but concept is to expand last function to include other CIMIS variables (eg. temp) with different specifications needed

#script ignores NAs.  No gap filling is currently performed.

#script will create two subdirectories from where the CIMIS data is located: 
#(1) QC_results: two files are created for each station.  '[stationID]_timeseries_QCsummary.txt' describes if temporal gaps exists in a station's dataset.  'missing_solrad_counts_[stationID & years].csv' descrbes how many missing solar radiation values occurred by each month across all years.  We do not currently distinguish between NAs that occur at night versus during the day.
#(2) aggregated_data: two files are created for each station: summaries of solar radiation and temperature during the growing season by day and by year.  This includes aggregated estimates of solar radiation as follows: daily sums, annual sums, and annual average of daily sums.  And aggregated estimates of temperature as follows: daily minimums and maximums and annual averages of daily min and max.

#define where data is located and where output from this script will go
mainDir <- 'C:/Users/smdevine/Desktop/DSI_meetings/air_pollution_crop_yield_project/data/CIMIS'
growseasonDir <- 'C:/Users/smdevine/Desktop/DSI_meetings/air_pollution_crop_yield_project/data'

#crop yield data for start and stop of each growing season
setwd(growseasonDir)
cropyields <- read.csv('state_rice_yield.csv', stringsAsFactors = FALSE)
#head(cropyields)

#output folders created if necessary for QC summaries and aggregated output
QC_results <- 'QC_results'
aggregated_data <- 'aggregated_data'
if (file.exists(file.path(mainDir, QC_results)) == FALSE) {
  dir.create(file.path(mainDir, QC_results))
} #this is where QC results will be saved
if (file.exists(file.path(mainDir, aggregated_data)) == FALSE) {
  dir.create(file.path(mainDir, aggregated_data))
} #this is where aggregated output will be saved; if raw data is to be aggregated by a weighted avg approach to aggregating data, this still needs to be done

#function to count NAs
count_NAs <- function(x) {
  sum(is.na(x))
}

#set the working directory
setwd(mainDir)

#locate all the station data csv files (this could be for future analysis when there will be more than one station's data
fnames <- list.files(mainDir, pattern = glob2rx('*.csv'))

#loop through these csv files, assuming all are CIMIS data files with same structure

#for (i in 1:length(fnames)) { #to be used later to run functions on a sequence of csv files indexed in fnames

#define a function to handle date data and report QC issues with dates
fix_time <- function() {
  setwd(mainDir)
  df <- read.csv(fnames[i], stringsAsFactors = FALSE)
  df$Hour..PST. <- as.character(df$Hour..PST.)
  j <- which(nchar(df$Hour..PST.) < 4) #find the hours that have less than 4 characters; these are missing initial zeroes
  df$Hour..PST.[j] <- paste('0', df$Hour..PST.[j], sep = '') #add zeroes to those hours identified in 'j' above
  df$Date.time <- strptime(paste(df$Date, as.character(df$Hour..PST.)), "%m/%d/%Y %H%M", tz="US/Arizona") #function to go from character to "POSIXlt" class representing dates and times, tz is "US/Arizona" because CIMIS does not use daylight savings time
  if (is.na(tail(df$Date.time, 1))) {
    df <- df[-nrow(df), ] #remove the last row of the data.frame has NA for the date; it was for Colusa
  }
  time_series_hourly <- seq(from=df$Date.time[1], to=tail(df$Date.time, 1), by='hour')
  time_series_hourly <- as.POSIXlt(time_series_hourly, tz="US/Arizona")
  if (nrow(df) < length(time_series_hourly)) { #then some times are missing, they need to be merged in from the synthetic time series
    z <- !(time_series_hourly %in% df$Date.time)
    missing_times <- as.POSIXlt(time_series_hourly[z])
    warning_message1 <- paste('WARNING! There are', as.character(length(missing_times)), 'missing times in this stations time series:', paste(missing_times, collapse=', '))
    setwd(file.path(mainDir, QC_results))
    time_series_QC <- file(paste(df$Stn.Name[1], '_stnID_', df$Stn.Id[1], "_timeseries_QCsummary.txt", sep=''))
    writeLines(warning_message1, time_series_QC)
    close(time_series_QC)
    time_series_hourly_df <- as.data.frame(time_series_hourly)
    colnames(time_series_hourly_df) <- 'Date.time'
    time_series_hourly_df$Date.time <- as.POSIXlt(time_series_hourly_df$Date.time, tz='US/Arizona')
    df <- merge(df, time_series_hourly_df, by='Date.time', all = TRUE) #success!
    df <- df[order(df$Date.time), ] #ensure date time order is correct
  }
  if (nrow(df) > length(time_series_hourly)) {#then there are duplicate times
    stop("There are duplicate rows for the same times in the CIMIS data, such that there are more rows in the dataframe than expected.") #if this happens, we need to add some code to fix
  }
  df$Date <- as.Date(df$Date.time, format='%m/%d/%Y') #add simplified date column
  df$Year <- strftime(df$Date.time, format='%Y')
  df$Month <- strftime(df$Date.time, format='%m')
  df$Day <- strftime(df$Date.time, format='%d')
  df$Week <- strftime(df$Date.time, format = '%U')
  df$DOY <- strftime(df$Date.time, format = '%j')
  #write.csv(df, paste(df$Stn.Name[1], '_', as.character(min(df$Year)), '_', as.character(max(df$Year)), '_time_fixed.csv', sep=''), row.names = FALSE)
  return(df)
}

i=1 #use this for the time being if there is only one station's data.  With more than one CIMIS station data set, function could be put inside loop and applied to each station's data, along with the functions below.
CIMIS_df <- fix_time()

#growing season function
growseason_trim <- function(df, df2) {
    growseason_indices <- vector(mode = 'integer')
    for (i in 1:nrow(df)) {
      j <- match(df$Year[i], df2$year)
      if (df$Week[i] %in% df2$avg_emerg[j]:df2$avg_harv[j]) {
        growseason_indices <- c(growseason_indices, i)
      }
    }
    df <- df[growseason_indices, ]
    return(df)
  }

CIMIS_df_growseason <- growseason_trim(CIMIS_df, cropyields)

#temp arguments to run function manually  
varname <- 'Sol.Rad..W.sq.m.'
df <- CIMIS_df_growseason
negpolicy <- 'Yes'
#function to aggregate CIMIS variables by different temporal scales
#CIMIS_var_aggregate <- function(df, varname, max, negpolicy) { #gaps
  # varname = variable of interest in the CIMIS dataset
  # max = upper threshould for expected value of variable; quantitites greater than this threshold reported on and possibly changed to NA (not currently implemented)
  # min = lower threshould for expected value of variable; quantitites less than this threshold reported on and possibly changed to NA (not currently implemented)
  # negpolicy = 'yes' to change negative values of solar radiation to 0
  # gaps_allowed = maximum number of NAs allowed before growing season aggregated data is processed to NA for a given year with missing data (not currently implemented)
  if (varname == 'Sol.Rad..W.sq.m.') {
    if (negpolicy == 'Yes') {  
      df[[varname]][which(df[varname] < 0)] <- 0 #convert negative numbers to 0 for solar radiation--SHOULD I do this?  Colusa had three values at -6999, which is obviously non-sensical.
    }
    NA_count_matrix <- as.data.frame(tapply(df[[varname]], list(df$Year, df$Month), count_NAs))
    daily_solrad <- as.data.frame(tapply(df[[varname]], df$Date, sum, na.rm=TRUE))
    colnames(daily_solrad) <- paste(varname, '_sum_daily', sep = '')
    daily_solrad$Date <- strptime(rownames(daily_solrad), format='%Y-%m-%d')
    daily_solrad$NA_count_hourly <- tapply(df[[varname]], df$Date, count_NAs)
    daily_solrad$TMIN <- tapply(df$Air.Temp..C., df$Date, min, na.rm=TRUE) #this and other lines referring to temperature could go into a separate part of this function
    daily_solrad$TMAX <- tapply(df$Air.Temp..C., df$Date, max, na.rm=TRUE)
    daily_solrad$Year <- strftime(daily_solrad$Date, format='%Y')
    annual_solrad <- as.data.frame(tapply(df[[varname]], df$Year, sum, na.rm=TRUE))
    colnames(annual_solrad) <- paste(varname, '_sum_growing_season', sep = '')
    annual_solrad[[paste(varname, '_mean_daily_sums', sep = '')]] <- tapply(daily_solrad[[paste(varname, '_sum_daily', sep = '')]], daily_solrad$Year, mean, na.rm=TRUE)
    annual_solrad$Year <- as.integer(rownames(annual_solrad))
    annual_solrad$NA_count_hourly <- tapply(df[[varname]], df$Year, count_NAs)
    annual_solrad$Growing_Start_DOY <- as.numeric(tapply(df$DOY, df$Year, min))
    annual_solrad$Growing_Stop_DOY <- as.numeric(tapply(df$DOY, df$Year, max))
    annual_solrad$Growing_length <- annual_solrad$Growing_Stop - annual_solrad$Growing_Start
    annual_solrad$mean_TMIN_C <- tapply(daily_solrad$TMIN, daily_solrad$Year, mean)
    annual_solrad$mean_TMAX_C <- tapply(daily_solrad$TMAX, daily_solrad$Year, mean)
    setwd(file.path(mainDir, aggregated_data))
    write.csv(daily_solrad, paste('daily_solrad_summary_', df$Stn.Name[1], '_', as.character(min(df$Year)), '_', as.character(max(df$Year)), '.csv', sep=''), row.names = FALSE)
    write.csv(annual_solrad, paste('annual_solrad_summary_', df$Stn.Name[1], '_', as.character(min(df$Year)), '_', as.character(max(df$Year)), '.csv', sep=''), row.names = FALSE)
    setwd(file.path(mainDir, QC_results))
    write.csv(NA_count_matrix, paste('missing_solrad_counts_', df$Stn.Name[1], '_', as.character(min(df$Year)), '_', as.character(max(df$Year)), '.csv', sep=''))
}

#} #to end future loop through multiple CIMIS station datasets 
  