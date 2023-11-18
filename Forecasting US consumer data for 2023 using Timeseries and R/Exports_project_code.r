## USE FORECAST LIBRARY.
#install.packages("dplyr")
library(forecast)
library(zoo)

## CREATE DATA FRAME. 

# Set working directory for locating files.
setwd("C:/Users/STSC/Documents/Spring23-Timeseries/Project/")

# Create data frame.

exports.data <- read.csv("USA-Exports.csv")

exports.data$Value <- as.numeric(gsub(",","",exports.data$Value))
#typeof(exports.data$Value)
#df1 <- data.frame(exports.data$Value)

head(exports.data$Value)
tail(exports.data$Value)

###### ts()

exports.ts <- ts(exports.data$Value,
                         start = c(1992, 1), end = c(2022, 12), freq = 12)
exports.ts

###### historical plot

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 270000), bty = "l",
     xlim = c(1990, 2024), main = "Historical plot") 
axis(1, at = seq(1990, 2024, 1), labels = format(seq(1990, 2024, 1)))
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

exp.plt <- stl(exports.ts, s.window = 'periodic')
autoplot(exp.plt, main = "plot graph")

#Autocorrelation plot for entire data
Acf(exports.ts)

############## predictability checking by various methods

#### approach 1 -Arima-AR(1)

export.predictability.ar1<- Arima(exports.ts, order = c(1,0,0))
summary(export.predictability.ar1)

ar1 <- 0.9993
s.e. <- 0.0010
null_mean <- 1
alpha <- 0.05
z.stat <- (ar1-null_mean)/s.e.
z.stat
p.value <- pnorm(z.stat)
p.value
if (p.value<alpha) {
  "Reject null hypothesis"
} else {
  "Accept null hypothesis"
}

#### approach 2 fpr predcitability

first.diff.data <- diff(exports.ts, lag = 1)
first.diff.data

Acf(first.diff.data, lag.max = 12, 
    main = "Autocorrelation for US Exports")

############# ACF plot

# finding autocorrelation chart and plot using Acf() function

autocor <- Acf(exports.ts, lag.max = 12, 
               main = "Autocorrelation for Us exports")
autocor

########### Data partition

# total data = 372
# valid = 84
# train = 372 - 84 = 288

nValid <- 84
nValid
nTrain <- length(exports.ts) - nValid
nTrain
train.ts <- window(exports.ts, start = c(1992, 1), end = c(1992, nTrain))
valid.ts <- window(exports.ts, start = c(1992, nTrain + 1), 
                   end = c(1992, nTrain + nValid))

train.ts
valid.ts


######## 1)two level forecast of (linear trend and seasonality , moving average for residuals)

trend.seas <- tslm(train.ts ~ trend + season)
summary(trend.seas)
trend.seas.pred <- forecast(trend.seas, h = nValid, level = 0)
trend.seas.pred

#two level forecast using regression model for linear trend
trend.reg <- tslm(train.ts ~ trend)
summary(trend.reg)
trend.reg.pred <- forecast(trend.reg, h = nValid, level = 0)
trend.reg.pred


############## decide window width

ma.trailing_3 <- rollmean(train.ts, k = 3, align = "right")
ma.trailing_6 <- rollmean(train.ts, k = 6, align = "right")
ma.trailing_12 <- rollmean(train.ts, k = 12, align = "right")


# Create forecast for the validation data for the window widths 
# of k = 4, 5, and 12. 
ma.trail_3.pred <- forecast(ma.trailing_3, h = nValid, level = 0)
ma.trail_3.pred
ma.trail_6.pred <- forecast(ma.trailing_6, h = nValid, level = 0)
ma.trail_6.pred
ma.trail_12.pred <- forecast(ma.trailing_12, h = nValid, level = 0)
ma.trail_12.pred

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 350000), bty = "l",
     xlim = c(1990, 2025), main = "Historical plot") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(ma.trailing_3, col = "blue", lwd = 2, lty = 2)
lines(ma.trail_3.pred$mean, col = "blue", lwd = 2, lty = 2)
lines(ma.trailing_6, col = "brown", lwd = 2, lty = 2)
lines(ma.trail_6.pred$mean, col = "brown", lwd = 2, lty = 2)
lines(ma.trailing_12, col = "green", lwd = 2, lty = 2)
lines(ma.trail_12.pred$mean, col = "green", lwd = 2, lty = 2)

legend(1992,340000, legend = c("Exports", 
                               "K=3",
                               "K=6", 
                               "K=12"), 
       col = c("black", "blue", "brown", "green"), 
       lty = c(1, 1, 1, 2), lwd =c(1, 2, 2, 2), bty = "n")
#legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
#       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 340000, "Training")
text(2020, 300000, "Validation")
text(2025, 300000, "Future")

# Use accuracy() function to identify common accuracy measures.
# Use round() function to round accuracy measures to three decimal digits.
round(accuracy(ma.trail_3.pred$mean, valid.ts), 3)
round(accuracy(ma.trail_6.pred$mean, valid.ts), 3)
round(accuracy(ma.trail_12.pred$mean, valid.ts), 3)

########## use window width k = 3 for regression residuals

trend.seas.res <- trend.seas$residuals
trend.seas.res
ma.trailing_3 <- rollmean(train.ts, k = 3, align = "right")
ma.trailing_3
# Apply trailing MA for residuals with window width k = 3
# for training partition.
ma.trail.res <- rollmean(trend.seas.res, k = 3, align = "right")
ma.trail.res

# Create residuals forecast for validation period.
ma.trail.res.pred <- forecast(ma.trail.res, h = nValid, level = 0)
ma.trail.res.pred

trend.reg <- tslm(train.ts ~ trend)
summary(trend.reg)
trend.reg.pred <- forecast(trend.reg, h = nValid, level = 0)
trend.reg.pred


fst.2level.train <- trend.seas$fitted.values + ma.trail.res


fst.2level <- trend.seas.pred$mean + ma.trail.res.pred$mean
fst.2level

#plot
plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 350000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data vs predictions for validation") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(fst.2level.train, col = "blue", lwd = 2, lty = 2)
lines(fst.2level, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")

#### two level with regression(trend),ma for residuals with width 3
trend.reg <- tslm(train.ts ~ trend)
summary(trend.reg)
trend.reg.pred <- forecast(trend.reg, h = nValid, level = 0)
trend.reg.pred

trend.reg.res <- trend.reg$residuals
trend.reg.res
ma.trailing_3 <- rollmean(train.ts, k = 3, align = "right")

# Apply trailing MA for residuals with window width k = 3
# for training partition.
ma.trail.res.reg <- rollmean(trend.reg.res, k = 3, align = "right")
ma.trail.res.reg

# Create residuals forecast for validation period.
ma.trail.reg.pred <- forecast(ma.trail.res.reg, h = nValid, level = 0)
ma.trail.reg.pred


fst.2level.train.reg <- trend.reg$fitted.values + ma.trail.res.reg

fst.2level.reg <- trend.reg.pred$mean + ma.trail.reg.pred$mean
fst.2level.reg

############### plot the predictions

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 270000), bty = "l",
     xlim = c(1990, 2024), main = "Historical plot") 
axis(1, at = seq(1990, 2024, 1), labels = format(seq(1990, 2024, 1)))
lines(fst.2level.train, col = "blue", lwd = 2, lty = 2)
lines(fst.2level, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 30000))
lines(c(2023, 2023), c(0, 30000))
text(2002, 3500, "Training")
text(2016.5, 3500, "Validation")
text(2020.2, 3500, "Future")
arrows(1991, 3400, 2013.9, 3400, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2014.1, 3400, 2018.9, 3400, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2019.1, 3400, 2021.3, 3400, code = 3, length = 0.1,
       lwd = 1, angle = 30)

#2 level model regression(only trend) and MA for residuals built over training data

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 270000), bty = "l",
     xlim = c(1990, 2024), main = "Historical plot") 
axis(1, at = seq(1990, 2024, 1), labels = format(seq(1990, 2024, 1)))
lines(fst.2level.train.reg, col = "blue", lwd = 2, lty = 2)
lines(fst.2level.reg, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 30000))
lines(c(2023, 2023), c(0, 30000))
text(2002, 3500, "Training")
text(2016.5, 3500, "Validation")
text(2020.2, 3500, "Future")
arrows(1991, 3400, 2013.9, 3400, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2014.1, 3400, 2018.9, 3400, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2019.1, 3400, 2021.3, 3400, code = 3, length = 0.1,
       lwd = 1, angle = 30)
####### accuracy measure

round(accuracy(trend.seas.pred$mean + ma.trail.res.pred$mean, valid.ts), 3)
#twolevel accuracy using regression only tend,ma for residuals over training data
round(accuracy(trend.reg.pred$mean+ ma.trail.reg.pred$mean, valid.ts), 3)
#round(accuracy((snaive(valid.ts))$fitted, valid.ts), 3)
#round(accuracy((naive(valid.ts))$fitted, valid.ts), 3)

######## entire dataset two level model

tot.trend.seas <- tslm(exports.ts ~ trend  + season)
summary(tot.trend.seas)

# Create regression forecast for future 12 periods.
tot.trend.seas.pred <- forecast(tot.trend.seas, h = 12, level = 0)
tot.trend.seas.pred

# Identify and display regression residuals for entire data set.
tot.trend.seas.res <- tot.trend.seas$residuals
tot.trend.seas.res

# Use trailing MA to forecast residuals for entire data set.
tot.ma.trail.res <- rollmean(tot.trend.seas.res, k = 3, align = "right")
tot.ma.trail.res

# Create forecast for trailing MA residuals for future 12 periods.
tot.ma.trail.res.pred <- forecast(tot.ma.trail.res, h = 12, level = 0)
tot.ma.trail.res.pred

# Develop 2-level forecast for future 12 periods by combining 
# regression forecast and trailing MA for residuals for future
# 12 periods.
tot.fst.2level.train <- tot.trend.seas$fitted.values + tot.ma.trail.res
tot.fst.2level <- tot.trend.seas.pred$mean + tot.ma.trail.res.pred$mean
tot.fst.2level

########## plot future predictions
plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 350000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data and future predictions") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(tot.fst.2level.train, col = "blue", lwd = 2, lty = 2)
lines(tot.fst.2level, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")
text(2025, 300000, "Future")


###### entire accuracy measures

round(accuracy(tot.trend.seas.pred$fitted + tot.ma.trail.res.pred$fitted, exports.ts), 3)
round(accuracy((snaive(exports.ts))$fitted, exports.ts), 3)
round(accuracy((naive(exports.ts))$fitted, exports.ts), 3)

################ two level regression(trend,sesonality),ar(1) for residuals
Acf(trend.seas$residuals, lag.max = 12, 
    main = "Autocorrelation for Exports Training Residuals")
# Use Arima() function to fit AR(1) model for training residuals. The Arima model of 
# order = c(1,0,0) gives an AR(1) model.
# Use summary() to identify parameters of AR(1) model. 
res.ar1 <- Arima(trend.seas$residuals, order = c(1,0,0))
summary(res.ar1)
res.ar1$fitted

# Use forecast() function to make prediction of residuals in validation set.
res.ar1.pred <- forecast(res.ar1, h = nValid, level = 0)
res.ar1.pred

# Use Acf() function to identify autocorrelation for the training 
# residual of residuals and plot autocorrelation for different lags 
# (up to maximum of 12).
Acf(res.ar1$residuals, lag.max = 12, 
    main = "Autocorrelation for Exports Training Residuals of Residuals")

train.two.level <- trend.seas$fitted.values + res.ar1$fitted
valid.two.level.pred <- trend.seas.pred$mean + res.ar1.pred$mean

######### plot predictions

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 300000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data vs prediction for validation data") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(train.two.level, col = "blue", lwd = 2, lty = 2)
lines(valid.two.level.pred, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")
###### accuracy

round(accuracy(trend.seas.pred$mean + res.ar1.pred$mean, valid.ts), 3)
round(accuracy((snaive(valid.ts))$fitted, valid.ts), 3)
round(accuracy((naive(valid.ts))$fitted, valid.ts), 3)

############### Model built over entire dataset

residual.ar1 <- Arima(tot.trend.seas$residuals, order = c(1,0,0))

# Use summary() to identify parameters of AR(1) model.
summary(residual.ar1)


residual.ar1.pred <- forecast(residual.ar1, h = 12, level = 0)
residual.ar1.pred
# Use Acf() function to identify autocorrelation for the residuals of residuals 
# and plot autocorrelation for different lags (up to maximum of 12).
Acf(residual.ar1$residuals, lag.max = 12, 
    main = "Autocorrelation for Residuals of Residuals for Entire Data Set")


# Identify forecast for the future 12 periods as sum of linear trend and 
# seasonal model and AR(1) model for residuals.

tot.fst.2level.train.ar1 <- tot.trend.seas$fitted.values + residual.ar1$fitted

lin.season.ar1.pred <- tot.trend.seas.pred$mean + residual.ar1.pred$mean
lin.season.ar1.pred

############## plot future predictions

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 300000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data with future predictions") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(tot.fst.2level.train.ar1, col = "blue", lwd = 2, lty = 2)
lines(lin.season.ar1.pred, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")
text(2025, 300000, "Future")
######### accuracy

round(accuracy(tot.trend.seas.pred$fitted + residual.ar1.pred$fitted, exports.ts), 3)
round(accuracy((snaive(exports.ts))$fitted, exports.ts), 3)
round(accuracy((naive(exports.ts))$fitted, exports.ts), 3)

############## holt-winter's model

# Use ets() function with model = "ZZZ", to identify the best HW option
# and optimal alpha, beta, & gamma to fit HW for the training data period.
HW.ZZZ <- ets(train.ts, model = "ZZZ")
HW.ZZZ 

# Use forecast() function to make predictions using this HW model for
# valid into the future.
HW.ZZZ.pred <- forecast(HW.ZZZ, h = nValid , level = 0)
HW.ZZZ.pred

########### plot predictions
plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 300000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data vs predictions for validation data") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(HW.ZZZ$fitted, col = "blue", lwd = 2, lty = 2)
lines(HW.ZZZ.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")


########### entire data

###############holts winter model  zzz for entire dataset
HW.ZZZ.entire <- ets(exports.ts, model = "ZZZ")
HW.ZZZ.entire 

# Use forecast() function to make predictions using this HW model for
# 12 month into the future.
HW.ZZZ.entire.pred <- forecast(HW.ZZZ.entire, h = 12 , level = 0)
HW.ZZZ.entire.pred

############### plot future predictions

plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 300000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data with future predictions") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(HW.ZZZ.entire$fitted, col = "blue", lwd = 2, lty = 2)
lines(HW.ZZZ.entire.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")
text(2025, 300000, "Future")


########### accuracy

round(accuracy((snaive(exports.ts))$fitted, exports.ts), 3)
round(accuracy((naive(exports.ts))$fitted, exports.ts), 3)
round(accuracy(HW.ZZZ.entire.pred$fitted, exports.ts), 3)

######### auto.arima() over training data

train.auto.arima <- auto.arima(train.ts)
summary(train.auto.arima)

# Apply forecast() function to make predictions for ts with 
# auto ARIMA model in validation set.  
train.auto.arima.pred <- forecast(train.auto.arima, h = nValid, level = 0)
train.auto.arima.pred

########### plot predictions
plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 300000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data vs predictoins for validation data") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(train.auto.arima$fitted, col = "blue", lwd = 2, lty = 2)
lines(train.auto.arima.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(1990,26000, legend = c("Exports"), col = c("black"), lty = c(1),
       lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")


##### entire data auto arima

entire.auto.arima <- auto.arima(exports.ts)
summary(entire.auto.arima)

# Apply forecast() function to make predictions for ts with 
# auto ARIMA model in validation set.  
entire.auto.arima.pred <- forecast(entire.auto.arima, h = 12, level = 0)
entire.auto.arima.pred

entire.212.arima <- Arima(exports.ts, order = c(2,1,2)) 
summary(entire.212.arima)

entire.212.arima.pred <- forecast(entire.212.arima, h = 12, level = 0)
entire.212.arima.pred

############ plot future predictions
plot(exports.ts, 
     xlab = "Time", ylab = "Exports", xaxt = "n",
     ylim = c(50000, 300000), bty = "l",
     xlim = c(1990, 2025), main = "Historical data with future predictions") 
axis(1, at = seq(1990, 2025, 1), labels = format(seq(1990, 2025, 1)))
lines(entire.212.arima$fitted, col = "brown", lwd = 2, lty = 2)
lines(entire.212.arima.pred$mean, col = "brown", lwd = 2, lty = 2)
lines(entire.auto.arima$fitted, col = "blue", lwd = 2, lty = 2)
lines(entire.auto.arima.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(1992,250000, legend = c("Exports", 
                               "ARIMA(0,1,2)",
                               "ARIMA(2,1,2)"), 
       col = c("black", "blue", "brown"), 
       lty = c(1, 1, 1), lwd =c(1, 2, 2), bty = "n")
#legend(1990,250000, legend = c("Exports"), col = c("black"), lty = c(1),
#      lwd = c(1), bty = "n")

lines(c(2016, 2016), c(0, 350000))
lines(c(2023, 2023), c(0, 350000))
text(2000, 300000, "Training")
text(2020, 300000, "Validation")
text(2025, 300000, "Future")

########## accuracy measures

round(accuracy(tot.trend.seas.pred$fitted + tot.ma.trail.res.pred$fitted, exports.ts), 3)

round(accuracy(tot.trend.seas.pred$fitted + residual.ar1.pred$fitted, exports.ts), 3)

round(accuracy(HW.ZZZ.entire.pred$fitted, exports.ts), 3)

round(accuracy(entire.auto.arima.pred$fitted, exports.ts), 3)
round(accuracy(entire.212.arima.pred$fitted, exports.ts), 3)

round(accuracy((snaive(exports.ts))$fitted, exports.ts), 3)
round(accuracy((naive(exports.ts))$fitted, exports.ts), 3)

#Forecasting using best model built which is holts winter in our case

forecast.best<-forecast(HW.ZZZ.entire, h = 12 , level = 0)
forecast.best
#forecast in future using auto arima
forecast.autoarima<-forecast(entire.auto.arima, h = 12 , level = 0)
forecast.autoarima
