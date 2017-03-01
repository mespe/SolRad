# Script to explore the limits of the
# California Air Resources Board Data
# M. Espe
# Feb 2017

library(readxl)
library(RColorBrewer)
library(maps)
library(lattice)
library(raster)
library(rgdal)

############# Prep raster of rice area ########
# The raster file from the USDA is very large - I reduce it in size here
# and then save it as a small .Rda file that is more easily shared


# usda_rice <- raster("~/Dropbox/D--CDL-NASS_DATA_CACHE-extract_3_CDL_2015_stat_clip_20161101201010_1475574269.tif")
# usda_rice <- aggregate(usda_rice, fact = 100)
# usda_rice <- projectRaster(usda_rice, crs = CRS("+init=epsg:4326"))

# usda_rice <- crop(usda_rice, extent(-125, -120, 36, 41))
# usda_rice[usda_rice < 0.01] <- NA
# usda_rice <- trim(usda_rice)
# save(usda_rice, file = "rice_raster.Rda")
load("rice_raster.Rda")
###################################

data_dir <- "~/Downloads/"
carb <- read_excel(paste0(data_dir, "PM25Daily20150302.xlsx"))

carb_sites <- read_excel(paste0(data_dir, "Location.xlsx"))

# Get the stations in the Sac. Valley air basin
sac_basin <- carb_sites$Basin == "SV"

table(sac_basin)

sac_sites <- carb_sites$Site[sac_basin]

# plot the average air quality by location
avgPM2.5 <- aggregate(Value ~ Site, data = carb, median)

avgPM <- merge(avgPM2.5, carb_sites)

# Check to make sure merge worked - we lost many sites
sum(unique(carb$Site) %in% carb_sites$Site)

############## Spatial Coverage ################

# Quick plot of state
plot_bks <- cut(avgPM$Value, breaks = 9)
cc <- brewer.pal(n = 9, "Reds")[plot_bks]

map("state", "California")
points(y = avgPM$Latitude, avgPM$Longitude, pch = 16, col = cc)
map.axes()

# Not many in our region of interest - 13 total
i <- avgPM$Basin == "SV"
table(i)

# Plot those 13
map("state", "California", xlim = c(-125, -120), ylim = c(38,40))
plot(usda_rice, add = TRUE, col = "green", legend = FALSE)
map("county", add = TRUE)
points(y = avgPM$Latitude[i], avgPM$Longitude[i], pch = 16, cex = 1)
text(y = avgPM$Latitude[i], avgPM$Longitude[i], labels = avgPM$Site[i], pos = 4)
map.text("county", add = TRUE)
map.axes()

   # Many of those 13 are in Sacramento (not ideal) or
# north of the rice area
# We do not have great spatial coverage here
# But it is about equal to that of the CIMIS solar radiation obs.
# It appears there are 4-5 stations worth looking at
target_stations <- c(3249, 2958, 2744, 3783, 2115)

########### Temporal coverage #############

# What is how many days are recorded in that period
sum(carb$Site %in% target_stations)

# Separate these out to work with more
sacPM <- carb[carb$Site %in% target_stations,]

# Get rid of missing Values
sacPM <- sacPM[!is.na(sacPM$Value),]

# Missing some days
length(seq(min(sacPM$Date, na.rm = TRUE), max(sacPM$Date, na.rm = TRUE), by = "day"))
length(unique(sacPM$Date))

full_series <- do.call(seq, c(as.list(range(sacPM$Date, na.rm = TRUE)), by = "day"))
missing <- as.POSIXct(setdiff(full_series, sacPM$Date),
                      origin = "1970-01-01")

plot(sacPM$Date, sacPM$Value, pch = 16, col = rgb(0,0,0,.25))
rug(missing, col = "red")

# Look only during the growing season
inSeason <- function(dates, rr = 4:10, timestep = "%m"){
    as.integer(format(dates, timestep)) %in% rr
}

growing <- inSeason(sacPM$Date)
missing_grow <- inSeason(missing)

plot(sacPM$Date[growing], sacPM$Value[growing], pch = 16, col = rgb(0,0,0,.25))
rug(missing[missing_grow], col = "red")

# How many missing in each year during the season?
plot(table(missing_grow, format(missing, "%Y")))

# Many overlappying observations - good for error checking, etc.
table(growing, format(sacPM$Date, "%Y"))

unique(sacPM$Site)


################# Look at station coverage ##########
i <- order(sacPM$Date)
table(sacPM$Site, format(sacPM$Date, "%Y"))

xyplot(Value ~ Date, groups =  Site, data =sacPM[i,], type = "l")

write.csv(sacPM, "sac_PM25.csv", row.names = FALSE)
