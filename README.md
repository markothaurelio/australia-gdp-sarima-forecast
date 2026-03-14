## SARIMA Forecasting of Australia’s GDP per Capita (2000–2027)

### Overview
This project applies **Seasonal ARIMA (SARIMA)** modelling to forecast **Australia’s quarterly GDP per capita (chain volume measures)** using data from the **Australian Bureau of Statistics (ABS)**. The analysis follows the **Box–Jenkins time series methodology** to identify, estimate, validate, and forecast an appropriate model.

GDP per capita is a widely used indicator of economic well-being because it reflects **real economic output per person** and is closely linked to living standards. Accurate forecasting of this metric helps support **policy planning, economic analysis, and investment decisions**.

The goal of this project is to produce a **data-driven forecast for 2025–2027** while capturing the **trend and seasonal structure** present in the historical series.

---

# Data

**Source:** Australian Bureau of Statistics (ABS)  
**Series ID:** A2302460K – GDP per capita (chain volume measures)

| Attribute | Value |
|---|---|
| Frequency | Quarterly |
| Time span used | 2000 Q1 – 2024 Q4 |
| Observations | 100 |
| Units | Inflation-adjusted chain volume dollars |
| Data source | ABS National Accounts |

The full ABS series spans **1959–2024**, however the analysis uses **2000 onward** to reflect Australia's modern economic structure.

---

# Technology

- **Language:** R  
- **Environment:** RStudio  

### Key Packages
- `forecast` – SARIMA modelling and forecasting  
- `tseries` – stationarity testing  
- `ggplot2` – visualisation  
- `psych` – descriptive statistics  

---

# Methodology

The modelling process follows the **Box–Jenkins framework**, consisting of four stages:

1. **Model Identification**
2. **Model Estimation**
3. **Diagnostic Checking**
4. **Forecasting**

Preliminary data exploration and stationarity testing are conducted prior to model identification.

---

# Preliminary Analysis

Exploratory analysis used a **time series plot and additive decomposition** to identify trend, seasonality, and irregular variation.

### Figure 1 — Raw GDP per Capita Time Series
![Raw GDP per Capita Time Series](/images/fig1_timeseries.png)

GDP per capita increases from roughly **$17,500 in 2000 to about $24,500 in 2024**.  
A clear **yearly seasonal pattern** appears, repeating every **four quarters**.

### Figure 2 — Trend Component
![Trend Component](/images/fig2_trend.png)

The trend shows a **steady long-term increase**, with short interruptions during economic slowdowns.

### Figure 3 — Seasonal Component
![Seasonal Component](/images/fig3_seasonality.png)

Seasonality is consistent:

- **Highest values:** Q4  
- **Lowest values:** Q1  

This indicates an **additive seasonal structure**.

### Figure 4 — Remainder Component
![Remainder Component](/images/fig4_remainder.png)

Residual fluctuations are small and centered around zero.  
A noticeable shock occurs around **2020**, likely reflecting the **COVID-19 economic disruption**.

---

# Stationarity Testing

Stationarity was assessed using the **Augmented Dickey–Fuller (ADF) test**.

### ADF Test – Raw Series

| Statistic | p-value |
|---|---|
| -3.296 | 0.076 |

The null hypothesis of non-stationarity **cannot be rejected**, indicating the need for differencing.

Two transformations were applied:

- **First differencing (d = 1)** to remove trend  
- **Seasonal differencing (D = 1, lag = 4)** to remove seasonal patterns

### ADF Test – Differenced Series

| Statistic | p-value |
|---|---|
| -5.231 | 0.01 |

The transformed series is **stationary**, satisfying the requirements for SARIMA modelling.

---

# Model Identification

ACF and PACF plots of the differenced series were examined.

### Figure 5 — ACF & PACF of Differenced Series
![ACF and PACF Plots](/images/fig5_acf_pacf.png)

Observations:

- No strong non-seasonal AR or MA spikes
- Significant seasonal pattern at **lag 4**
- PACF tails off gradually

These patterns suggest the model:

**SARIMA(0,1,0)(0,1,1)[4]**

---

# Model Estimation

A neighbourhood search of candidate models was evaluated using **AIC and BIC**.

The best model according to **BIC** was:

**SARIMA(0,1,0)(0,1,1)[4]**

This model was chosen because:

- It has the **lowest BIC**
- It is **parsimonious**
- It aligns with the structure suggested by the ACF/PACF plots

The model can be written as:

\[
y_t = y_{t-1} + y_{t-4} - y_{t-5} + \varepsilon_t - \Theta_1 \varepsilon_{t-4}
\]

---

# Diagnostic Checking

### Figure 6 — Residual Diagnostics
![Residual Diagnostics](/images/fig6_residuals.png)

Diagnostics indicate:

- Residuals fluctuate randomly around zero  
- No major patterns remain in the ACF  
- Distribution is approximately normal

A small spike appears at lag 3 but is not statistically concerning.

### Ljung-Box Test

| Statistic | p-value |
|---|---|
| 12.15 | 0.0957 |

Because **p > 0.05**, the null hypothesis of no autocorrelation cannot be rejected.  
Residuals therefore behave approximately as **white noise**, confirming model adequacy.

---

# Forecasting

The final model was used to forecast **12 quarters ahead (2025–2027)**.

### Forecast Results

| Quarter | Forecast |
|---|---|
| 2025 Q1 | 23,027 |
| 2025 Q2 | 23,975 |
| 2025 Q3 | 23,834 |
| 2025 Q4 | 24,849 |
| 2026 Q1 | 23,140 |
| 2026 Q2 | 24,088 |
| 2026 Q3 | 23,947 |
| 2026 Q4 | 24,962 |
| 2027 Q1 | 23,253 |
| 2027 Q2 | 24,201 |
| 2027 Q3 | 24,060 |
| 2027 Q4 | 25,075 |

The model predicts:

- **Stable seasonal cycles**
- **Moderate overall growth**
- **Increasing uncertainty further into the forecast horizon**

### Figure 7 — Forecast Plot
![GDP Forecast 2025–2027](/images/fig7_forecast.png)

Prediction intervals widen over time, reflecting the increasing uncertainty inherent in long-term forecasting.

---

# Key Findings

- Australia’s GDP per capita shows **consistent seasonal behaviour** with peaks in **Q4**.
- First and seasonal differencing were required to achieve **stationarity**.
- **SARIMA(0,1,0)(0,1,1)[4]** provided the best balance of **accuracy and simplicity**.
- Forecasts indicate **stable but modest growth** through **2027**.

---

# Limitations

SARIMA models rely **solely on historical data**, which means they cannot anticipate **external shocks** such as:

- policy changes
- global economic disruptions
- pandemics

The model therefore assumes **structural continuity** in the economic system.

Future work could explore **ARIMAX or multivariate models** incorporating external economic indicators.

---

