## Exploring the data we have so far
## Feb 8 2017


cimis <- read.csv("~/Downloads/colusa_cimis_1992_2015.csv", stringsAsFactors = FALSE)

str(cimis)

cimis$Date <- as.Date(cimis$Date, "%m/%d/%Y")
cimis$Date.hr <- strptime(paste(cimis$Date, as.character(cimis$Hour..PST.)), "%m/%d/%Y %H%M")

plot(cimis$Sol.Rad..W.sq.m. ~ cimis$Date, type = "l")


grep("^[^[0-9]", cimis$Date, value = TRUE)

table(is.na(cimis$Date.hr), cimis$Hour..PST.)
## Deal with this later

solrad <- aggregate(Sol.Rad..W.sq.m. ~ Date, data = cimis, sum)
solrad <- solrad[order(solrad$Date),]

plot(Sol.Rad..W.sq.m. ~ as.Date(Date, "%m/%d/%Y"), solrad, ylim = c(0,1e4))

# Growing season
i <- as.numeric(format(cimis$Date, "%m")) %in% 5:9

plot(solrad$Sol.Rad..W.sq.m.[i] ~ as.numeric(format(solrad$Date[i], "%j")), type = "n")
sapply(1992:2015, function(year){
    lines(solrad$Sol.Rad..W.sq.m.[i][as.numeric(format(solrad$Date[i], "%Y")) == year],
          col = rgb(0,0,0,0.3))

})


maxSol <- aggregate(solrad$Sol.Rad..W.sq.m., list(as.numeric(format(solrad$Date, "%j"))),
                    max)

pdf("solrad_by_year.pdf", width = 10, height = 8)
par(mfrow = c(3,3))
sapply(1992:2015, function(year){
    ##browser()
    
    j <- (as.numeric(format(solrad$Date, "%m")) %in% 4:9) &
        (as.numeric(format(solrad$Date, "%Y")) == year)
    days <- as.numeric(format(solrad$Date[j], "%j"))
    plot(solrad$Sol.Rad..W.sq.m.[j] ~ days,
         type = "l",
         main = year,
         xaxt = "n",
         xlab = "Date",
         ylab = "Solar radiation",
         ylim = c(0,10000))
    axis(1, at = pretty(days),
         labels = format(as.Date(paste(pretty(days), "2015"), "%j %Y"), "%b %d"))
    lines(filter(maxSol$x, rep(1/21, 21)) ~ maxSol$Group.1, col = "red")
                   
    })
dev.off()



## Large negative values

tapply(cimis$Date, format(cimis$Date, "%Y"), length)
## 2012 missing

i <- format(cimis$Date, "%Y") == "2012"

which(!1:366 %in% as.numeric(unique(format(cimis$Date[i], "%j"))))
## Missing 328 and 329 in 2012 - might not matter because it is late in season

## GET USDA Data
source("../collection/get_USDA_data.R")
api_key <- readLines("~/Dropbox/usda_api_key.txt")

rice <- get_USDA_data(api_key)

## Need to coerce the values to other than character
colusa <- rice[rice$county_name == "COLUSA",]

unique(colusa$year)

j <- as.numeric(colusa$year) %in% 1992:2015

colusa <- colusa[j,]
colusa$Value <- as.numeric(gsub(",", "", colusa$Value))
plot(colusa$Value, pch = 16, cex = 4)
summary(colusa$Value)

grwSeason <- format(cimis$Date, "%j") %in% 120:240

ss <- tapply(cimis$Sol.Rad..W.sq.m.[grwSeason], format(cimis$Date[grwSeason], "%Y"), sum, na.rm = TRUE)

## Missing SolRad values
table(is.na(cimis$Sol.Rad..W.sq.m.[grwSeason]), format(cimis$Date[grwSeason], "%Y"))

plot(rev(colusa$Value) ~ ss, pch = 16, cex = 4)

mod <- lm(rev(colusa$Value) ~ ss)
abline(mod)

plot(ss ~ as.numeric(names(ss)), pch = 16, cex =4 )

##
rice$Value <- as.numeric(gsub(",", "", rice$Value))

library(lattice)
xyplot(Value ~ as.numeric(year) | county_name, data = rice, type = "l")


## Double values for same year lb/acre vs lb/net planted acre
rice[rice$county_name == "SUTTER", c("year","Value")]

plot(Value ~ as.numeric(year), data = rice[rice$county_name == "BUTTE",])
