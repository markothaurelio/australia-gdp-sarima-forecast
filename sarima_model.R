# Set working directory
setwd("")

# Load required packages
library(forecast)
library(tseries)
library(ggplot2)

# SARIMA neighborhood model generator function
generate_sarima_models <- function(ts_data, p, d, q, P, D, Q, s) {
  models <- list()
  for (dp in -1:1) {
    for (dq in -1:1) {
      for (dP in -1:1) {
        for (dQ in -1:1) {
          new_p <- p + dp
          new_q <- q + dq
          new_P <- P + dP
          new_Q <- Q + dQ
          if (new_p >= 0 && new_q >= 0 && new_P >= 0 && new_Q >= 0) {
            key <- sprintf("SARIMA(%d,%d,%d)(%d,%d,%d)[%d]", new_p, d, new_q, new_P, D, new_Q, s)
            models[[key]] <- Arima(ts_data, order = c(new_p, d, new_q), seasonal = c(new_P, D, new_Q))
          }
        }
      }
    }
  }
  return(models)
}

# Load data
gdp_data <- read.csv("gdp_data.csv")

# Convert month names to quarter numbers
month_to_quarter <- c("Mar" = 1, "Jun" = 2, "Sep" = 3, "Dec" = 4)
gdp_data$Quarter <- month_to_quarter[gdp_data$Month]

# Create a quarterly time series object starting from Q1 2000 using GDP values
gdp_ts <- ts(gdp_data$Value, start = c(2000, 1), frequency = 4)

# Plot time series
autoplot(gdp_ts) +
  ggtitle("Quarterly GDP per Capita (Chain Volume, Australia)") +
  xlab("Year") + ylab("GDP per Capita ($, chain volume)") 


# Decompose and plot 
decomp <- decompose(gdp_ts, type = "additive")
autoplot(decomp)

# Perform ADF test
adf.test(gdp_ts)

# Difference the data to remove trend
gdp_diff <- diff(gdp_ts)

# Seasonally difference the data to remove seasonality
gdp_season_diff <- diff(gdp_diff, lag = 4)
autoplot(gdp_season_diff) + ggtitle("Seasonally Differenced GDP per Capita")

# Perform ADF test on differenced data
adf.test(gdp_season_diff)

# Compute ACF & PACF 
acf_res  <- acf(gdp_season_diff, lag.max = 48, plot = FALSE)
pacf_res <- pacf(gdp_season_diff, lag.max = 48, plot = FALSE)

# Plot ACF and PACF side by side
par(mfrow = c(1,2))
acf(as.numeric(gdp_season_diff),
    lag.max = 48,
    main    = "ACF (Seasonally Differenced)",
    xlab    = "Lag")
pacf(as.numeric(gdp_season_diff),
     lag.max = 48,
     main    = "PACF (Seasonally Differenced)",
     xlab    = "Lag")
par(mfrow = c(1,1))

# Generate SARIMA models around the informed initial model 
models <- generate_sarima_models(gdp_ts, p = 0, d = 1, q = 0, P = 0, D = 1, Q = 1, s = 4)

# Evaluate models by AIC and BIC
model_aics <- sapply(models, AIC)
model_bics <- sapply(models, BIC)

# Print sorted AIC and BIC values
cat("Sorted AICs:\n")
print(sort(model_aics))
cat("\nSorted BICs:\n")
print(sort(model_bics))

# Select the best model AIC
best_model_key_AIC <- names(which.min(model_aics))
best_model_AIC <- models[[best_model_key_AIC]]
# Select the best model BIC
best_model_key_BIC <- names(which.min(model_bics))
best_model_BIC <- models[[best_model_key_BIC]]

# Print best models 
cat("\nBest model by AIC:", best_model_key_AIC, "\n")
cat("\nBest model by BIC:", best_model_key_BIC, "\n")

# Residual diagnostics on selected model
checkresiduals(best_model_BIC)
summary(best_model_BIC)

# Forecast for the next 3 years (12 quarters)
forecast_gdp <- forecast(best_model_BIC, h = 12); forecast_gdp

# Plot forecast 
autoplot(forecast_gdp) +
  autolayer(forecast_gdp$mean, series = "Forecast") +
  autolayer(fitted(best_model_BIC), series = "Fitted") +
  xlab("Year") + ylab("GDP per Capita ($, chain volume)") +
  ggtitle(paste("Forecast using", best_model_key_BIC)) +
  guides(colour = guide_legend(title = "Series")) +
  scale_x_continuous(breaks = seq(2000, 2027, by = 2))

