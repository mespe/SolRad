# Simple script to retrieve the data from CIMIS
# Mar 2017
# M. Espe

# Relies on the Rcimis package which we wrote -
# you can install this from Github

library(devtools)
install_github("mespe/Rcimis")

library(Rcimis)

# Get every station in the area of focus
# Stations #12, 30, 32, 6, 235

targets <- StnInfo[as.numeric(StnInfo$StationNbr) %in% c(6,12,30,32,235),]

all_weather <- lapply(1992:2016, function(year){
    ans <- lapply(c(6,12,30,32,235), function(stn){
        try(CIMISweather(startDate = paste0(year, "-01-01"), endDate = paste0(year,"-12-30"),
                         targets = stn, .opts= list(verbose = TRUE)))
    })
    do.call(rbind, ans[!sapply(ans, is, "try-error")])    
})

all_weather <- do.call(rbind, all_weather)

write.csv(all_weather, file = "../data/CIMIS1992_2016.csv", row.names = FALSE)
