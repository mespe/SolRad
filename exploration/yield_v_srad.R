## Exploring the yield and solar radiation data
## March 2017

library(zoo)
library(lattice)

yield <- read.csv("../data/rice_yield_avg_timing.csv", stringsAsFactors = FALSE)

# Using the daily solar radiation data
cimis <- read.csv("../data/CIMIS1992_2016.csv",
                 stringsAsFactors = FALSE)

# Remove obs. 926 - solrad value is 8x higher than other stations
cimis[cimis$Date == "1992-07-14",]
cimis <- cimis[-926,]

yield[,5:7] <- lapply(yield[,5:7], as.Date)
cimis$Date <- as.Date(cimis$Date, "%Y-%m-%d")

srad <- aggregate(DaySolRadAvg.Value ~ Date, data = cimis, mean, na.rm = TRUE)

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

mains <- c("Vegetative","Grain-filling", "Full season")
pdf("srad_v_yield.pdf", height = 6, width = 10)
par(mfrow = c(1,3))
lapply(i, function(j){

    plot(yield_lb_ac ~ yield[,j], data = yield,
         main = mains[which(i == j)],
         xlab = "Sum solar radiation",
         ylab = "Yield (lbs/ac)",
         pch = 16)
    
    mod <- lm(yield_lb_ac ~ yield[,j], data = yield)
    abline(mod)
    summary(mod)
})
dev.off()

# Looks like very little effect of vegetative
# the impact is for grain fill and then season total

###########
# Quick and dirty model selection
library(MASS)
mm <- lm(yield_lb_ac ~ veg_srad + gf_srad + total_srad, data = yield)
stepAIC(mm)

plot2var <- function(x, y, ...){
    plot(x, y, pch = 16, ...)
    mod <- lm(y~x)
    abline(mod)
    summary(mod)    
    }


########### Is this confounding from the heading date #####
pdf("srad_flowering.pdf", 6, 6)
with(yield, plot2var(as.numeric(format(HEADED, "%j")), gf_srad,
     ylab = expression(sum("solar radiation")),
     xlab = "Flowering date (day of year)"))
dev.off()

pdf("yield_flowering.pdf",6, 6)
with(yield, plot2var(as.numeric(format(HEADED, "%j")), yield_lb_ac,
     ylab = "Yield (lbs/ac)",
     xlab = "Flowering date (day of year)"))
dev.off()

# relationship between planting date and heading date
with(yield, plot2var(as.numeric(format(EMERGED, "%j")), as.numeric(format(HEADED, "%j")),
     ylab = "Flowering date (day of year)",
     xlab = "Flowering date (day of year)"))


########## Confounded by year? ############

with(yield, plot2var(as.numeric(format(HEADED, "%Y")), gf_srad,
     ylab = expression(sum("solar radiation")),
     xlab = "Year"))

plot(gf_srad ~ format(HEADED, "%Y"), yield,
     pch = 16)
mm <- lm(gf_srad ~ as.numeric(format(HEADED, "%Y")), yield)
abline(mm)


plot(

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

xyplot(RICE_GROWING_PCT ~ WEEK , groups =YEAR, data = weekly.rice.growing, type = "l")

########### What is causing variation in planting date? ##########
# Look one month before emergence to see if there are precip trends

yield$preplant_precip <- sapply(1:nrow(yield), function(i){
    days <- seq(yield$EMERGED[i] - 30, yield$EMERGED[i], by = 1)
    idx <- cimis$Date %in% days
    sum(cimis$DayPrecip.Value[idx], na.rm = TRUE)
})

pdf("precip_emerg.pdf", 6, 5)
with(yield, plot2var(as.numeric(format(EMERGED, "%j")), preplant_precip,
                     xlab = "Emergence date (day of year)",
                     ylab = expression(sum("precip. 30d prior to emergence (mm)"))))
dev.off()
