################################################################################
# WARNING: This script assumes > 20+ cpu cores - do not run on a laptop without
# adjusting these two parameters:

cores1 = 5L
cores2 = 4L

#user needs to have GDAL installed on your machine for this work
#library(RCurl)
library(XML)
library(raster)
library(gdalUtils)
library(httr)
library(RCurl)
library(parallel)

#39.464743, -121.734355 are the coordinates of rice research station of interest
###user needs to define air_qualDir###
# Assume that the script is being run in collection/
dir = "aerosol_rasters"
if(!file.exists(dir))
    dir.create(dir)

## air_qualDir <- 'C:/Users/smdevine/Desktop/DSI_meetings/air_pollution_crop_yield_project/'
if (!file.exists(file.path(dir, 'results'))) {
  dir.create(file.path(dir, 'results'))
}
if (!file.exists(file.path(dir, 'temp'))) {
  dir.create(file.path(dir, 'temp'))
}

#get coordinates of interest in long lat Clarke 1866 projection (the projection of the MODIS data), assuming coordinates of interest are in long lat WGS84
crs_clarke <- '+proj=longlat +ellps=clrk66 +no_defs'
res_station <- SpatialPoints(cbind(-121.734355, 39.464743), proj4string = crs('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'))
res_station <- spTransform(res_station, crs_clarke) #coordinates don't change; just the ellipsoid assumption changes

#set up a sequence of dates of interest
# Do all of this outside of loop to avoid repeated recalculation
startday <- "055" #this is the first available day of MODIS data
startyear <- "2000"
startdate <- strptime(paste0(startday, startyear), '%j%Y')
enddate <- strptime("12/31/2016", '%m/%d/%Y')
datesequence <- seq.Date(from=as.Date(startdate), to=as.Date(enddate), by='day')

doyr <- format.Date(datesequence, '%j')
yr <- format.Date(datesequence, '%Y')

# base_url <- 'https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/MOD09CMA/'
# Look at this different data product
base_url <- 'https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/MOD04_L2/'
base_url2 <- paste0(base_url, yr, '/', doyr, '/')

# Define once 
result_file = paste0(dir, '/results/AOD_riceyield_airqual_project.csv')

## Setup the results file
if(!file.exists(paste0(dir, '/results/AOD_riceyield_airqual_project.csv')))
    write.csv(data.frame(Aerosol_Type_Land = NA,
                         Corrected_Optical_Depth_Land = NA,
                         Corrected_Optical_Depth_Land_wav2p1 = NA,
                         filename=NA),
              file = result_file,
              row.names = FALSE)

# Data we are interested in from other data products:
# corrected optical depth land
# aerosol type land
# https://modis-atmos.gsfc.nasa.gov/MOD04_L2/format.html

# Set curl handle so repeated connections use the same handle
curl = getCurlHandle(useragent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                     followlocation = TRUE, verbose = TRUE)

get_target_links = function(base_urls, curl = getCurlHandle())
{
    links = lapply(base_urls, function(url){
        doc = htmlParse(getURL(url, curl = curl))
        tmp = getHTMLLinks(doc)
        grep("\\.hdf$", tmp, value = TRUE)
    })
    do.call(c, links)
}

# Subset to only the flights where the sensors are over our area of interest
tars = get_target_links(base_url2)
times = as.numeric(gsub(".*MOD04_L2\\.A[0-9]+\\.([0-9]{4})\\..*", "\\1", tars))
tars = tars[times > 1700 & times < 2100]

# Define the function here and then use inside an mclapply
get_MODIS_subset= function(tar, cores2 = cores2){

    fname = gsub(".*(MOD04_L2[.]A.*$)", "\\1", tar)

    # Don't download if we already have the data in the results
    if(!any(grepl(fname, readLines(result_file)))){
        file_url <- paste0("https://ladsweb.modaps.eosdis.nasa.gov", tar)
        dest_file = paste0(dir, "/temp/", fname)
        # this fixed a problem
        # https://gis.stackexchange.com/questions/213923/open-hdf4-files-using-gdal-on-windows
        download.file(file_url, destfile = dest_file,
                      mode = 'wb') 
        fname_tif <- gsub('hdf', 'tif', dest_file, fixed=TRUE) 
        sbs <- get_subdatasets(dest_file)
        regstring = paste(c("Aerosol_Type_Land",
                            "Aerosol_Cloud_Fraction_Land",
                            "Corrected_Optical_Depth_Land",
                            "Corrected_Optical_Depth_Land_wav2p")
        sbs_sub_idx = grep(,
                           sbs)
        ans = do.call(c, mclapply(sbs_sub_idx, function(i){
            fname_tmp = gsub(".tif", paste0(i,".tif"), fname_tif)
            on.exit(file.remove(fname_tmp))
            
            gdal_translate(src_dataset = dest_file,
                           dst_dataset = fname_tmp,
                           of = 'GTiff', sd_index = i) #should print NULL on the screen
            aod_tif <- raster(fname_tmp)
            on.exit(file.remove(fname_tmp))
            aod_value <- extract(aod_tif, res_station)
            structure(aod_value,
                      names = gsub("^.*\\.hdf:mod04:", "", sbs[i]))
        }, mc.cores = cores2))
        
        file.remove(dest_file)
        
        results <- data.frame(t(ans),
                              filename=fname)
        write.table(results, sep = ",",
                    file = result_file,
                    row.names = FALSE, append = TRUE, col.names = FALSE)
    }
}

mclapply(tars, function(x) try(get_MODIS_subset(x)), mc.cores = cores1)


