# ─────────────────────────────────────────────────────────────
# 05_plot_results.R
# Description: Plot regression results
# ─────────────────────────────────────────────────────────────

library(ggplot2)
library(zoo)
library(dplyr)


# Plot: Confidence Intervals for FDI Coefficients
results$sector <- gsub("TFP_growth_", "", results$sector)
results$sector <- gsub("_", " ", results$sector)

ggplot(results, aes(y = sector, x = estimate, xmin = conf.low, xmax = conf.high)) +
  geom_point() +
  geom_errorbarh(height = 0.2) +
  geom_vline(xintercept = 0, linetype = "dotted", color = "red", size = 1) +
  labs(title = "FDI Impact on Sector-Level TFP: 95% Confidence Intervals",
       y = "Sector", x = "FDI Coefficient Estimate") +
  theme_minimal() +
  theme(axis.text.y = element_text(face = "bold"))
