# ─────────────────────────────────────────────────────────────
# 07_diagnostics.R
# Description: Regression diagnostics including VIF and normality checks
# ─────────────────────────────────────────────────────────────

library(car)
library(ggplot2)

# ─── 1. VIF and Summary for Each Regression ──────────────────

for (tfp_col in tfp_growth_columns) {
  # Create regression formula
  formula <- as.formula(paste(tfp_col, "~", paste(independent_vars, collapse = " + ")))
  
  # Run linear model
  regression <- lm(formula, data = India_FDI_long)
  
  # Print summary
  cat("Regression Summary for", tfp_col, "as dependent variable:\\n")
  print(summary(regression))
  
  # Print VIF values
  cat("\\nVIF Values:\\n")
  print(vif(regression))
  
  # ─── 2. Normality Check: Q-Q Plot ──────────────────────────
  
  qq_plot <- ggplot(data = data.frame(resid = residuals(regression)), aes(sample = resid)) +
    stat_qq() +
    stat_qq_line(color = "red") +
    labs(title = paste("Q-Q Plot for Residuals of", tfp_col),
         x = "Theoretical Quantiles", y = "Sample Quantiles") +
    theme_minimal()
  
  print(qq_plot)
  
  cat("\\n--------------------------------------------------\\n\\n")
}
