## Exploring the yield and solar radiation data
## March 2017

library(zoo)

yield <- read.csv("../data/rice_yield_avg_timing.csv", stringsAsFactors = FALSE)

# Using the daily solar radiation data
srad <- read.csv("../data/CIMIS1992_2016.csv",
                 stringsAsFactors = FALSE)

# Remove obs. 926 - solrad value is 8x higher than other stations
srad[srad$Date == "1992-07-14",]
srad <- srad[-926,]

yield[,5:7] <- lapply(yield[,5:7], as.Date)
srad$Date <- as.Date(srad$Date, "%Y-%m-%d")

srad <- aggregate(DaySolRadAvg.Value ~ Date, data = srad, mean, na.rm = TRUE)

ss <- seq(min(srad$Date), max(srad$Date), by = "day")
ss[!ss %in% srad$Date]

srad$DaySolRadAvg.Value <- na.approx(srad$DaySolRadAvg.Value)
srad$Date[is.na(srad$DaySolRadAvg.Value)]
##### Revised version that uses dates rather than week number

sum_srad <- function(sol_rad, start, end){
    i <- sol_rad$Date %in% seq(start, end, by = "day")
    sum(sol_rad$DaySolRadAvg.Value[i])
}

#vegetative phase = emerge to flower
yield$veg_srad <- sapply(1:nrow(yield), function(i){
    sum_srad(srad, yield$EMERGED[i], yield$HEADED[i])
})

# grain-fill = flower to harvest
yield$gf_srad <- sapply(1:nrow(yield), function(i){
    sum_srad(srad,yield$HEADED[i], yield$HARVESTED[i])
})

yield$total_srad <- sapply(1:nrow(yield), function(i){
    sum_srad(srad,yield$EMERGED[i], yield$HARVESTED[i])
})

##########
# Remove 2016
yield <- yield[-25,]

plot(yield_lb_ac ~ total_srad, data = yield)

mod <- lm(yield_lb_ac ~ total_srad, data = yield)
abline(mod)


########## Plot all three ##########
i <- grep("srad", colnames(yield))

par(mfrow = c(1,3))
lapply(i, function(j){

    plot(yield_lb_ac ~ yield[,j], data = yield,
         main = colnames(yield[j]),
         xlab = "Sum solar radiation",
         ylab = "Yield (lbs/ac)",
         pch = 16)
    
    mod <- lm(yield_lb_ac ~ yield[,j], data = yield)
    abline(mod)
    summary(mod)
    })

# Looks like very little effect of vegetative
# the impact is for grain fill and then season total

###########
# Quick and dirty model selection
library(MASS)
mm <- lm(yield_lb_ac ~ veg_srad + gf_srad + total_srad, data = yield)
stepAIC(mm)


########### Is this confounding from the planting date#####

plot(veg_srad ~ format(EMERGED, "%j"), yield)


##### Previous code using week numbers - probably broken######
source("../collection/get_weekly_rice_growing.R")o

ans2 <- lapply(split_rad, function(x){
    i <- match(paste(x$Group.1, x$Group.2),
               paste(weekly.rice.growing$YEAR, weekly.rice.growing$WEEK))
    sum(x$x * weekly.rice.growing$RICE_GROWING_PCT[i])
    
})
yield$srad2 <- numeric(25)
yield$srad2[1:24] <- do.call(c, ans2)

plot(srad ~srad2, yield[-25,])


plot(Value ~ srad2, data = yield[-25,])

mod2 <- lm(Value ~ srad2, data = yield[-25,])
abline(mod2)

plot(srad~year, yield[-25,], ylim = c(700000, 1100000), type = "b")
lines(srad2~year, yield[-25,], pch = 16)

plot(I(srad - srad2) ~ year, yield[-25,])

library(xyplot)
xyplot(RICE_GROWING_PCT ~ WEEK , groups =YEAR, data = weekly.rice.growing, type = "l")
