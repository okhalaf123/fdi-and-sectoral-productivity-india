# ─────────────────────────────────────────────────────────────
# 04_run_regressions.R
# Description: Run OLS regressions on sector-level TFP using FDI and controls
# ─────────────────────────────────────────────────────────────

# Define independent variables
independent_vars <- c("FDI_inflows_GDP", "Export_percent_change", "Import_percent_change", 
                      "Gov_spending_percent_change", "Gross_capital_form_percent_change", 
                      "CPI_Growth", "Priv_Credit_Growth", "Crop_prod_growth")

# Get sector TFP column names
tfp_growth_columns <- grep("^TFP_growth_", names(India_FDI_long), value = TRUE)

# Initialize results storage
results <- data.frame(sector = character(), estimate = numeric(), conf.low = numeric(), conf.high = numeric())

# Run regressions for each sector
for (col in tfp_growth_columns) {
  formula <- as.formula(paste(col, "~", paste(independent_vars, collapse = "+")))
  model <- lm(formula, data = India_FDI_long)
  ci <- confint(model, "FDI_inflows_GDP", level = 0.95)
  coef_val <- coef(summary(model))["FDI_inflows_GDP", "Estimate"]
  results <- rbind(results, data.frame(sector = col, estimate = coef_val, conf.low = ci[1], conf.high = ci[2]))
}

write.csv(India_FDI_long, "cleaned_output.csv")

