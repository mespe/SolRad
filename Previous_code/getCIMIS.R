## Function to query CIMIS weather data
## M. Espe
## 2015

library(RCurl)
library(jsonlite)

## Key is stored separate and not shared
api_key <- readLines('~/Dropbox/CIMIS API key')

## Define function

##' Query the CIMIS API
##'
##' .. content for \details{} ..
##' @title Get CIMIS data
##' @param api_key a personal API key for accessing data
##' @param ... additional arguments in the form of "key = value" pairs
##'     passed along as query parameters
##' @param start start date, in ISO format ("YYYY-mm-dd")
##' @param end end date, in ISO format
##' @param url default URL to query
##' @return a data.frame object of query results
##'
##' @author Matthew Espe
##'
getCIMIS <- function(api_key, ...,
                     start, end,
                     url = "http://et.water.ca.gov/api/data")
{
  doc <- getForm(uri = url, appKey = api_key,
                 startDate = start, endDate = end,  ...)
  fromJSON(doc, flatten = TRUE)$Data$Providers$Records[[1]]
}

CIMISweather <- function(api_key, startyear, endyear, station_nbr, ...)
{
  tmp <- getCIMIS(api_key,
                  start = paste0(startyear, '-01-01'),
                  end = paste0(endyear, '-12-31'),
                  unitOfMeasure = 'M',
                  targets = station_nbr, ...)

  idx <- grep('[.]Qc$|[.]Unit$', colnames(tmp))
  tmp <- tmp[,-idx]
  
  data <- data.frame(
      date = as.Date(tmp$Date, "%Y-%m-%d"),
      station_nbr = station_nbr,
      doy = tmp$Julian,
      solrad = tmp[,"DaySolRadAvg.Value"],
      tmin = tmp[,"DayAirTmpMin.Value"],
      tmax = tmp[,"DayAirTmpMax.Value"],
      vp = tmp[,"DayVapPresAvg.Value"],
      wind = tmp[,"DayWindSpdAvg.Value"],
      precip = tmp[,"DayPrecip.Value"],
      stringsAsFactors = FALSE)

  data[,2:9] <- sapply(data[,2:9], function(x)
    as.numeric(as.character(x)))

  return(data)
}


get_station_info <- function(station_names){
  # Returns a comma separated list of station numbers
  # Given the station names

    stations <- getURL('http://et.water.ca.gov/api/station')
    tmp <- fromJSON(stations)
    i <- which(tmp$Stations$Name %in% station_names)
    data.frame(stn_nm = tmp$Stations$Name[i],
               stn_nbr = tmp$Stations$StationNbr[i],
               lat = do.call(rbind,strsplit(tmp$Stations$HmsLatitude[i], " / "))[,2],
               lon = do.call(rbind,strsplit(tmp$Stations$HmsLongitude[i], " / "))[,2],
               stn_ele = as.numeric(tmp$Stations$Elevation[i]) * 0.3048,
               stn_start = as.Date(tmp$Stations$ConnectDate[i], "%m/%d/%Y"),
               stn_end = as.Date(tmp$Stations$DisconnectDate[i], "%m/%d/%Y"),
               county = tmp$Stations$County[i],
               stringsAsFactors = FALSE)
  
}

