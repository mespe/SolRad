#  Script to calculate the stress experienced by each
# plot according to previous estimates
# M. Espe
# May 2017

weather = read.csv("../data/CIMIS1992_2016.csv", stringsAsFactors = FALSE)
weather$Date = as.Date(weather$Date)

yield = read.csv("../data/yield_w_srad.csv", stringsAsFactors = FALSE)

yield[,c("planted","head_date")] = lapply(yield[,c("planted","head_date")], as.Date)

# Inefficient, but only run once
ans = lapply(1:nrow(yield), function(i){
    
    idx = weather$Date %in% seq(yield$planted[i] + yield$pi[i] + 7,
                                yield$head_date[i] + 7, by = "1 day")
    tmp_weather = weather[idx,]
    boot = tmp_weather[1:(nrow(tmp_weather) - 7),]
    fl = tmp_weather[(nrow(tmp_weather) - 7):(nrow(tmp_weather)),]
        
    boot_cool = sum(boot$DayAirTmpMin.Value[boot$DayAirTmpMin.Value < 13.0] - 13,
                    na.rm = TRUE)
    boot_hot = sum(boot$DayAirTmpMax.Value[boot$DayAirTmpMax.Value > 36.0] - 37,
                   na.rm = TRUE)
    fl_cool = sum(fl$DayAirTmpMin.Value[fl$DayAirTmpMin.Value < 15.0] - 15,
                  na.rm = TRUE)
    fl_hot = sum(fl$DayAirTmpMax.Value[fl$DayAirTmpMax.Value > 36.0] - 37,
                 na.rm = TRUE)

    c(boot_cool, boot_hot, fl_cool, fl_hot)
    })

ans = do.call(rbind, ans)
colnames(ans) = c("boot_cool", "boot_hot", "fl_cool", "fl_hot")
yield = cbind(yield, ans)

# str(yield)

if(FALSE){
    par(mfrow = c(2,2))
    sapply(c("boot_cool", "boot_hot", "fl_cool", "fl_hot"), function(x)
        plot(yield[,"yield_lb"] ~ yield[,x],
             pch =16, col = rgb(0,0,0,0.3)))
}
yield$yield_kg = yield$yield_lb * 1.12
write.csv(yield, file = "../data/yield_w_stress.csv", row.names = FALSE)
