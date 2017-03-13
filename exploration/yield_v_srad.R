## Exploring the yield and solar radiation data
## March 2017

yield <- read.csv("../data/state_rice_yield.csv", stringsAsFactors = FALSE)

srad <- read.csv("../data/daily_solrad_summary_Colusa_1992_2015.csv",
                 stringsAsFactors = FALSE)

srad$Date <- as.Date(srad$Date, "%Y-%m-%d")

srad_weekly <- aggregate(srad$Sol.Rad..W.sq.m._sum_daily,
                         list(format(srad$Date, "%Y"),
                              format(srad$Date, "%W")),
                         FUN = sum)

split_rad <- split(srad_weekly, srad_weekly$Group.1)

sum_srad <- function(sol_rad, start, end){
    i <- sol_rad$Group.2 %in% start:end
    sum(sol_rad$x[i])
}

ans <- lapply(1:nrow(yield), function(j){
##    browser()
    
    tmp <- split_rad[[as.character(yield$year[j])]]
    sum_srad(tmp, yield$avg_emerg[j], yield$avg_harv[j])
})

yield$srad <- do.call(c, ans)

#########
yield$Value <- as.numeric(gsub(",","", yield$Value))

plot(Value ~ srad, data = yield[-25,])

mod <- lm(Value ~ srad, data = yield[-25,])
abline(mod)

###########
source("../collection/get_weekly_rice_growing.R")

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
