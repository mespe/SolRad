#user needs to have GDAL installed on your machine for this work
#library(RCurl)
library(XML)
library(raster)
library(gdalUtils)
library(httr)
#39.464743, -121.734355 are the coordinates of rice research station of interest
###user needs to define air_qualDir###
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
startday <- "055" #this is the first available day of MODIS data
startyear <- "2000"
startdate <- strptime(paste0(startday, startyear), '%j%Y')
enddate <- strptime("12/31/2016", '%m/%d/%Y')
datesequence <- seq.Date(from=as.Date(startdate), to=as.Date(enddate), by='day')

library(parallel)

doyr <- format.Date(datesequence, '%j')
yr <- format.Date(datesequence, '%Y')
base_url <- 'https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/MOD09CMA/'
base_url2 <- paste0(base_url, yr, '/', doyr, '/')

result_file = paste0(dir, '/results/AOD_riceyield_airqual_project.csv')

## Setup the results file
if(!file.exists(paste0(dir, '/results/AOD_riceyield_airqual_project.csv')))
    write.csv(data.frame(date=NA,
                         AOT_at_500nm=NA,
                         filename=NA),
              
                                        #data_layer=NA,
                                        #longitude=NA,
                                        #latitude=NA),
              file = result_file,
              row.names = FALSE)


foo = function(i){
    x = base_url2[i]
    get_output <- GET(x)
    urls <- readHTMLTable(rawToChar(get_output$content),
                          stringsAsFactors = FALSE)
    fname <- urls$`ftp-directory-list`[3,1]
 #   browser()
    if(!any(grepl(fname, readLines(result_file)))){
        file_url <- paste0(x, fname)
        dest_file = paste0(dir, "/temp/", fname)
        ## setwd(file.path(dir, 'temp')) # This is dangerous
        download.file(file_url, destfile = dest_file,
                      mode = 'wb') #this fixed a problem https://gis.stackexchange.com/questions/213923/open-hdf4-files-using-gdal-on-windows
        fname_tif <- gsub('hdf', 'tif', dest_file, fixed=TRUE) 
        ##gdalinfo(fname) #we got a good ole hdf4 file!  must set mode='wb' in download.file above for this to work or manually download files from the URL on my windows machine
        sbs <- get_subdatasets(dest_file) #we need subdataset 12 "Coarse Resolution AOT at 550 nm"
        gdal_translate(src_dataset = dest_file,
                       dst_dataset = fname_tif,
                       of = 'GTiff', sd_index = 12) #should print NULL on the screen
        aod_tif <- raster(fname_tif)
        aod_value <- extract(aod_tif, res_station)
        file.remove(dest_file)
        file.remove(fname_tif)
        results <- data.frame(date=datesequence[i],
                              AOT_at_500nm=aod_value,
                              filename=fname)
        
                                        #data_layer=sbs[12],
                                        #longitude=coordinates(res_station)[1],
                                        #latitude=coordinates(res_station)[2])
        write.table(results, sep = ",",
                    file = result_file,
                    row.names = FALSE, append = TRUE, col.names = FALSE)
    }
}

mclapply(seq_along(base_url2), function(i) try(foo(i)), mc.cores = 8L)

##     next
##   }
##   result <- data.frame(date=datesequence[i], AOT_at_500nm=aod_value, data_layer=sbs[12], filename=fname, longitude=coordinates(res_station)[1], latitude=coordinates(res_station)[2])
##   ## results <- rbind(results, result) # this is a super inefficient operation
##   write.csv(results, 'AOD_riceyield_airqual_project.csv', row.names = FALSE)
## }

