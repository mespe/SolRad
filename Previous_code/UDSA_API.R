## Interface to USDA Quickstats
## M. Espe
## STA 242
## Apr 2015

##' Find possible values for commodities
##'
##' Returns the possible values for commodities.
##'
##' @title List commodities in USDA Quickstats database
##' @param api_key USDA API key for request
##' @return character vector of commodities
##'
##' @author Matt Espe
##'
list_USDA_commodities <- function(api_key)
{
    require(RCurl)
    require(jsonlite)

    get_param_vals_url <-
        'http://quickstats.nass.usda.gov/api/get_param_values/'

    fromJSON(getForm(get_param_vals_url, key = api_key,
                     param= 'commodity_desc'))
}

##' Gets potential number of records
##'
##' Returns the number of records for a potential query
##'     of the USDA Quckstats database.
##' @title Get USDA counts
##' @param api_key character string of API key
##' @param ... \code{key = value} pairs of search terms of query.
##'    The "key" must match USDA Quickstats parameter names.  A
##'    complete list of these can be found at http://quickstats.nass.usda.gov/api.
##'    Additional arguments can also be passed to \code{getForm}.
##'
##' @return number of records returned by entered query
##'
##' @author Matt Espe
##'
get_USDA_count <- function(api_key, ...)
{
    require(RCurl)
    require(jsonlite)

    get_data_count_url <-
        'http://quickstats.nass.usda.gov/api/get_counts/'

    n <- as.numeric(fromJSON(getForm(get_data_count_url, key = api_key,
                                     source_desc = 'SURVEY', ...))[[1]])

    if(n > 50000) warning('Too many results for one request!')
    n
}

##' Returns data from USDA QuickData API
##'
##' Retrieve data from a USDA Quickstats API
##' @title Get USDA data
##' @param api_key character string of API key
##' @param commodity character string of desired commondity
##' @param year currently limited to one year
##'
##' @param ... additional args passed to \code{getForm}
##' @return dataframe of requested query
##'
##' @author Matt Espe
##'
get_USDA_data <- function(api_key, commodity, year, agg_level_desc = 'STATE',
                     freq_desc = 'ANNUAL', ...)
{
    require(RCurl)
    require(jsonlite)

    get_param_data_url <-
        'http://quickstats.nass.usda.gov/api/api_GET/'
    ## Restrict to Survey data to keep records manageable
    fromJSON(getForm(get_param_data_url, key = api_key,
                     commodity_desc = commodity, year = year,
                     agg_level_desc = agg_level_desc,
                     freq_desc = freq_desc, ...))[[1]]
}



