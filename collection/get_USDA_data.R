### code for extracting USDA data
### code structure from Matt Espe Apr 2015
### code by Melissa Kardish January 2017

### This code is written to extract data from the USDA API.
### We are aiming to extract crop yield data from the database to look at with respect to solar radiation
### This code requires an API key that can be acquired https://quickstats.nass.usda.gov/api and used as api_key in the get_USDA_data funtion
### More than one crop can be added by adding it to the commodity input vector
### On 1/25/17 This extracts all rice data available on the county level in California which begins in 1953 and runs through 2015 (2016 onwards not available for rice); some crop data begins in 1850 (county level data in CA begins in 1919 for cotton)
### The defaults in this code are to extract the data we likely need for this function. Any additional functionality from the USDA can be specified (e.g., can specify one county; for Colusa County:
	## colusa<-get_USDA_data(api_key,county_name="COLUSA")
### On this initial look at data, later filtering will have to be done on unit_desc ("LB / ACRE" vs. "LB / NET PLANTED ACRE")

get_USDA_data <- function(api_key, commodity=c("RICE"), year=1953:2017, state="CALIFORNIA", statisticcat_desc = "YIELD", agg_level="COUNTY",...){
    require(RCurl)
    require(jsonlite)

    get_data_url <-
        'https://quickstats.nass.usda.gov/api/api_GET/' ##fixed URL, seems NASS switched from http to https
        
    fromJSON(getForm(
    		  get_data_url, 
    		  key = api_key,
                     commodity_desc = commodity, 
                     year = year, ##can be a range
                     state_name = state, ##default set to CALIFORNIA for our questions here
                     statisticcat_desc = statisticcat_desc, ##set default to YIELD statistics
                     agg_level_desc=agg_level, ##used county as default, can also use 
                     ...))[[1]]
}

##rice_yield<-get_USDA_data(api_key)
