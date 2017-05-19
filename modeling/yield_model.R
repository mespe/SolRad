#
#
#
yield = read.csv("../data/yield_w_stress.csv", stringsAsFactors = FALSE)

mod = lm(yield_lb ~ veg_srad + rep_srad + gf_srad,
         data = yield)

summary(mod)


library(glmnet)

X = model.matrix(~ -1 + vg_avg_tmin + vg_avg_tmax + fl_avg_tmin + fl_avg_tmax +
                 gf_avg_tmin + gf_avg_tmax + se_avg_tmin + se_avg_tmax + veg_srad +  
                 rep_srad + gf_srad + grain_type, data = yield)

fit = glmnet(X, yield$yield_lb)

cv.fit = cv.glmnet(X, yield$yield_lb)

coef(cv.fit, s = "lambda.min")

################################################################################
X_scaled = X
X_scaled[,1:11] = apply(X[,1:11], 2, scale)

fit_scaled = glmnet(X_scaled, yield$yield_lb)

cv.fit_scaled = cv.glmnet(X_scaled, yield$yield_lb)

coef(cv.fit_scaled, s = "lambda.min")


################################################################################
# Checking out the projpred package

library(rstanarm)
library(projpred)
options(mc.cores = 2L)

yield = read.csv("../data/yield_w_stress.csv", stringsAsFactors = FALSE)

mod_data = yield[,!colnames(yield) %in% c("plot","rep","yield_lb","site","county")]
mod_data[,c("planted","head_date")] = lapply(mod_data[,c("planted","head_date")], function(x) as.numeric(format(as.Date(x), "%j")))

idx = !colnames(mod_data) %in% c("id","grain_type","trial_type")
mod_data[,idx] = lapply(mod_data[,idx], scale)

fit = stan_glmer(yield_kg ~
                   planted + (1|id) + dth + lodging + height + 
                   (1|grain_type) + moisture + (1|year) + (1|trial_type) + head_date + 
                   pi + vg_avg_tmin + vg_avg_tmax + fl_avg_tmin + fl_avg_tmax + 
                   gf_avg_tmin + gf_avg_tmax + se_avg_tmin + se_avg_tmax + veg_srad + 
                   rep_srad + gf_srad + boot_cool + boot_hot + fl_cool + fl_hot,   

                 family = gaussian(),
                 data = mod_data,
                 prior = hs(global_df = 3), iter = 500)

