# Using the USDA API to get covariates
# M. Espe
# 2017 March

source("get_USDA_data.R")
load("../data/yield_w_srad.rda")

api_key <- readLines("~/Dropbox/usda_api_key.txt")

# yield <- read.csv("../data/rice_yield_avg_timing.csv", stringsAsFactors = FALSE)
# Variables of interest
vars <- c("AREA PLANTED",
          "AREA HARVESTED")

covars <- lapply(vars, function(x)
    try(get_USDA_data(api_key, year = 1992:2016,
                  statisticcat_desc=x, agg_level = "STATE",
                  reference_period_desc = "YEAR",
                  source_desc = "SURVEY")))

tmp <- lapply(covars, "[", c("short_desc","Value", "year"))

tmp <- lapply(tmp, function(x) x[grep("GRAIN", x$short_desc, invert = TRUE),]) 

yield$planted_acres <- rev(as.numeric(gsub(",", "", tmp[[1]]$Value)))
yield$harvested_acres <- rev(as.numeric(gsub(",", "", tmp[[2]]$Value)))

# Occurance of cold temperatures
weather <- read.csv("../data/CIMIS1992_2016.csv", stringsAsFactors = FALSE)
weather$Date <- as.Date(weather$Date)

# First need to estimate PI
# Using the GDD model
temps <- aggregate(cbind(DayAirTmpMin.Value, DayAirTmpMax.Value) ~ Date,
                   data = weather, median, na.rm = TRUE)
colnames(temps) <- c("date", "tmin","tmax")

getPI <- function(weather, start, end)
{
    idx <- weather$date %in% seq(start, end, 1)
    # Constants fix in Sharifi et al., 2016
    x <- weather[idx,]
    x$tmin[x$tmin > 14.2] <- 14.2
    x$tmax[x$tmax > 27.7] <- 27.7
    x$gdd <- ((x$tmin + x$tmax) / 2) - 10
    x$date[which(cumsum(x$gdd) > 473)[1]]
}

yield$PI <- as.Date(sapply(1:nrow(yield), function(i)
    getPI(temps, yield$EMERGED[i], yield$HEADED[i])), "1970-01-01")

# Get accumulated cooling and heating

getTempStress <- function(weather, start, end, lthrsh = 13, hthrsh = 35.7)
{
    idx <- weather$date %in% seq(start, end, 1)
    # Constants fix in Sharifi et al., 2016
    x <- weather[idx,]
    cool <-  sum(x$tmin[x$tmin <= lthrsh] - lthrsh, na.rm = TRUE)
    heat <-  sum(x$tmax[x$tmax >= hthrsh] - hthrsh, na.rm = TRUE)
    return(data.frame(cool = cool, heat = heat))
}

ans <- do.call(rbind, lapply(1:nrow(yield), function(i)
    getTempStress(temps, yield$PI[i] + 7, yield$HEADED[i] - 7)))
ans2 <- do.call(rbind, lapply(1:nrow(yield), function(i)
    getTempStress(temps, yield$HEADED[i] - 7, yield$HEADED[i] + 7)))
colnames(ans2) <- c("fl_cool","fl_heat")

yield <- cbind(yield, ans, ans2)

save(yield, file = "../data/yield_w_covars.rda")

## Quick LASSO
y <- yield[,4]
vars <- c("veg_srad", "gf_srad", "planted_acres", "cool","heat","fl_cool","fl_heat")
X <- yield[,vars]

X <- sapply(X, function(x){
    if(is(x, "Date"))
        x <- as.numeric(format(x, "%j"))
    x
})
X <- cbind(X, X[,5] + rnorm(25, 0, 1))
library(glmnet)

fit = glmnet(X, y)
plot(fit, label = TRUE)
fit = cv.glmnet(X, y)
plot(fit)
coef(fit, s = "lambda.min")

# See what stepAIC does
library(MASS)
mod <- lm(yield_lb_ac ~ veg_srad + gf_srad + heat + year,
          data = yield)
stepAIC(mod, direction = "forward")

# Try the Bayesian fit
library(rstanarm)
options(mc.cores = 2L)

bayes.fit <- stan_glm(scale(y) ~ apply(X, 2, scale), prior = normal())
bayes.fit2 <- stan_glm(scale(y) ~ apply(X, 2, scale), prior = hs())

compare(waic(bayes.fit), waic(bayes.fit2))
plot(bayes.fit2)
summary(yield)
