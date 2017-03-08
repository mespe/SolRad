source("CARB.R")

julian <- function(x){
    as.numeric(format(x, "%j"))
}

early <- as.numeric(format(sacPM$Date, "%Y")) %in% 1998:2006

plot(table(format(sacPM$Date[early], "%j")))

plot(diff(as.numeric(format(sacPM$Date[early], "%j"))) ~ as.numeric(format(sacPM$Date[early], "%Y")))


early.split <- split(sacPM[early,], paste(format(sacPM$Date[early], "%Y"), sacPM$Site[early]))

late.split <- split(sacPM[!early,], paste(format(sacPM$Date[!early], "%Y"), sacPM$Site[!early]))

ans <- lapply(early.split, function(x) julian(x$Date))

result <- lapply(late.split, function(late) {
    lapply(ans, function(early){
        browser()
        
        i <- match(julian(late$Date), early)
        full <- mean(late$Value, na.rm = TRUE)
        miss <- mean(late$Value[i], na.rm = TRUE)
        
        return(data.frame(full, miss))
        })

})

# It looks like some late sites are actually sampling less than daily
# but are using multiple methods, which makes it appear they are more complete than
# they really are. When we scale up, we need to figure out how to combine these

##### Duncan's suggestion of looking at the lag

stn.split <- split(sacPM, sacPM$Site)
lapply(stn.split, function(x) {
#    browser()
    i <- order(x$Date)
    x <- x[i,]
    plot(diff(x$Value) ~ I(diff(as.Date(x$Date))))
    })

par(mfrow = c(2,3))
lapply(stn.split, function(x){
    i <- order(x$Date)
    x <- x[i,]
    boxplot(x$Value[-1]~ I(diff(as.Date(x$Date))))
        

})

# It seems much more likely to have high values with the daily data vs the weekly.
# This could be an issue, since these higher values will throw off the calculation
# a mean

week <- function(x){
    as.integer(format(x, "%W"))
}

permWeekly <- function(late.split){
    ans <- lapply(late.split, function(x){
        weekly <- sapply(20:44, function(i){
            # Sample one value per week over the period of interest
            # to approximate the weekly values
            ##        browser()
            tmp <- x$Value[week(x$Date) == i]
            if(length(tmp) > 1)
                tmp <- sample(tmp, 1)
            if(length(tmp) == 0)
                return(NA)
            return(tmp)
        })
        ##browser()
        
        return(data.frame(weekly = median(weekly, na.rm = TRUE),
                          daily = median(x$Value[week(x$Date) %in% 20:44], na.rm = TRUE)))

    })

    aa <- do.call(rbind, ans)
}

# OK, looks like it is OK - more or less symetric with center at 0
# most of spread is betwee -1,1
aa <- permWeekly(late.split)
plot(density(aa[,"weekly"] - aa[,"daily"]), xlim = c(-6, 6), ylim = c(0,2))
sapply(1:100, function(y){
    aa <- permWeekly(late.split)
    lines(density(aa[,"weekly"] - aa[,"daily"]), col = rgb(0,0,0,.2))
})


################ Check the PM10 data for similar patterns ##############
data_dir <- "~/Downloads/"

pm10 <- read.csv(paste0(data_dir, "PM10_weekly_data_98_14.csv"), stringsAsFactors = FALSE)

# Make sure we are only looking at the sites in the sac valley
pm10 <- pm10[pm10$Site %in% sac_sites,]
pm10$Date <- as.Date(pm10$Date, "%m/%d/%Y")

plot(Value ~ Date, pm10, pch = 16, col = rgb(0,0,0,0.2))

# These data look to be truly weekly
plot(table( format(pm10$Date, "%Y")))


