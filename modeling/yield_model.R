#
#
#
yield = read.csv("../data/yield_w_srad.csv", stringsAsFactors = FALSE)

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
