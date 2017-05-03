# Linking the solar-radiation to yiel

tars = list.files(".", "*.csv", recursive = TRUE)

dd = lapply(tars, read.csv, stringsAsFactors = FALSE)

names(dd) = tars

dd = lapply(dd, function(x){
    x$datetime = as.Date(x$datetime)
    x
})

by_day = lapply(dd, function(x){
    aggregate(solar.rad ~ datetime, data = x, sum)
})

# Load RES data
yield = read.csv("../data/RES_rice_data.csv", stringsAsFactors = FALSE)

yield[,c("planted","head_date")] = lapply(yield[,c("planted","head_date")], as.Date, format = "%Y-%m-%d")

# Definition of stages:
# veg = planting to PI
# rep = PI - heading
# gf = heading - 35 d after

# now sure which data set to use - set that here
srad = by_day[[3]]
srad = srad[order(srad$datetime),]

ans = sapply(1:nrow(yield), function(i){
    # slow code, but OK if only run once
    # browser()
    idx = srad$datetime %in% seq(yield$planted[i],
                                 yield$head_date[i] + 35,
                                 by = "1 day")
    tmp = srad$solar.rad[idx]
    return(c(veg_srad = sum(tmp[1:yield$pi[i]]),
             rep_srad = sum(tmp[yield$pi[i]:yield$dth[i]]),
             gf_srad = sum(tmp[yield$dth[i]:length(tmp)])))
    })
