## POWER to ORYZA
## M. Espe
## March 2015

##' Import data from NASA POWER into R
##'
##' This function imports data from the NASA POWER database
##'     at http://power.larc.nasa.gov/cgi-bin/cgiwrap/solar/agro.cgi.
##'
##' @title getPOWER
##'
##' @param lat latitude
##' @param lon longitude
##' @param ms start month
##' @param ds start day
##' @param ys start year
##' @param me end month
##' @param de end day
##' @param ye end year
##'
##' @return \code{data.frame} object with POWER data
##'
##' @author Matthew Espe
##'
getPOWER <- function(lat, lon, ms = 1, ds = 1, ys,
                     me = 12, de = 31, ye)
  # Access to NASA POWER Agroclimate database from R
  # lat = latitude
  # lon = longitude
  # ms/ds/ys = month/day/year of start
  # me/de/ye = month/day/year of end
 
{
# https://power.larc.nasa.gov/cgi-bin/agro.cgi?email=&step=1&lat=39.5&lon=-121.5&ms=1&ds=1&ys=2016&me=12&de=31&ye=2016&submit=Yes
    
    u = "https://power.larc.nasa.gov/cgi-bin/agro.cgi?"
    opts = list(cookie = "_ga=GA1.2.375198474.1477625090", verbose = TRUE, useragent = "R", referer = "https://power.larc.nasa.gov/cgi-bin/agro.cgi?", followlocation = TRUE)
  doc <- getForm(u, email="",
                 step = 1, lat = lat, lon = lon,
                 ms = ms, ds = ds, ys = ys,
                 me = me, de = de, ye = ye,
                 submit = "Yes",
                  p="swv_dwn"
                                      #                 .opts = opts
                 )

  head <- readLines(textConnection(doc), n = 15)

  idx <- which(grepl('@ WEYR', head))
  tbl <- read.table(textConnection(doc), skip = idx)
  colnames(tbl) <- tolower(strsplit(head[idx], ' +')[[1]][-1])
  return(tbl)
}

if(FALSE) {
library(RHTMLForms)
library(RCurl)
#doc <- getHTMLFormDescription(getURI(u), dropButtons = FALSE)
library(XML)
hdoc = htmlParse(getURI(u))
docName(hdoc) = u
doc <- getHTMLFormDescription(hdoc, dropButtons = FALSE)


my_fun <- createFunction(doc[[1]])

isc = sapply(formals(my_fun), is.character)
formals(my_fun)[isc] = lapply(formals(my_fun)[isc], XML:::trim)

my_fun(ys=1995, ye=1995, lat=39.5, lon=-121.5, .opts = list(verbose = TRUE)) # , p="swv_dwn")
}
