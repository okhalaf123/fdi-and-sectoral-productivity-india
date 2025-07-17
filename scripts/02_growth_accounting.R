# ─────────────────────────────────────────────────────────────
# 02_growth_accounting.R
# Description: Perform growth accounting using log GDP per capita
# ─────────────────────────────────────────────────────────────

# Create a clean copy excluding 1989 for growth accounting
ga_data <- work_data %>%
  filter(year >= 1990)

# Compute GDP per capita and production inputs
ga_data <- ga_data %>%
  mutate(
    l_gdp_cap = log(rgdpna / pop),       # Real GDP per capita (log)
    k_cap     = rkna / pop,              # Capital per capita
    tot_hours = avh * emp / pop          # Hours worked per capita
  )

# Compute capital share (alpha)
alpha <- 1 - mean(ga_data$labsh, na.rm = TRUE)

# Time variable for trend estimation
ga_data <- ga_data %>%
  mutate(t = year - first(year))

# Fit linear trend model to log GDP per capita
trend_model <- lm(l_gdp_cap ~ t, data = ga_data)
ga_data <- ga_data %>%
  mutate(
    trend   = predict(trend_model),          # Fitted trend
    detrend = l_gdp_cap - trend              # Detrended GDP per capita
  )

# Growth accounting: compute labor, capital, and productivity terms
ga_data <- ga_data %>%
  mutate(
    labor_term        = log(tot_hours),
    capital_term      = alpha / (1 - alpha) * log(rkna / rgdpna),
    productivity_term = detrend - capital_term - labor_term
  )

# Normalize each component to 0 in base year (1990)
ga_data <- ga_data %>%
  mutate(
    output_term_norm       = detrend - first(detrend),
    labor_term_norm        = labor_term - first(labor_term),
    capital_term_norm      = capital_term - first(capital_term),
    productivity_term_norm = productivity_term - first(productivity_term)
  )

# ─── Plot: Growth Accounting for India (1990–) ─────────────
ggplot(data = ga_data) +
  geom_line(aes(x = year, y = output_term_norm, color = "Output"), size = 1.5) +
  geom_line(aes(x = year, y = labor_term_norm, color = "Labor"), size = 1) +
  geom_line(aes(x = year, y = capital_term_norm, color = "Capital"), size = 1) +
  geom_line(aes(x = year, y = productivity_term_norm, color = "Productivity"), size = 1) +
  labs(title = "Growth Accounting: India", x = "Year", y = "Initial = 0") +
  scale_color_manual(name = "Terms", values = c("Output" = "cornflowerblue", "Labor" = "darkgreen",
                                                "Capital" = "darkorange", "Productivity" = "red")) +
  theme_minimal()

