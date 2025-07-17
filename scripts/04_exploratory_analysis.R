# ─────────────────────────────────────────────────────────────
# 06_exploratory_analysis.R
# Description: Exploratory data analysis of FDI, TFP, and macro variables
# ─────────────────────────────────────────────────────────────

library(ggplot2)
library(dplyr)
library(tidyr)
library(corrplot)

# ─── 1. Summary Statistics ───────────────────────────────────

cat("Summary of FDI Inflows (% of GDP):")
print(summary(India_FDI_long$FDI_inflows_GDP))

cat("\\nSummary of TFP Growth (All Sectors):")
print(summary(as.numeric(sector_TFP_filtered$TFP_growth)))

cat("\\nAvailable Years in FDI Dataset:")
print(range(as.numeric(India_FDI_long$Year)))

# ─── 2. Distribution Plots ───────────────────────────────────

# Boxplot of FDI inflows (% of GDP)

ggplot(India_FDI_long, aes(x = FDI_inflows_GDP )) + 
  stat_boxplot(geom = "errorbar",width = 0.15) + 
  geom_boxplot(fill = "cornflowerblue", height = 0.15)  +
  labs(title = "Distribution of FDI Inflows (% of GDP)", x = "FDI Inflows (% of GDP)") +
  ylim(-1.5, 1.5) + 
  theme_minimal()
# ─── 3. Average TFP Growth by Sector ───────────────

sector_labels <- c("Agriculture", "Mining and Quarrying", "Food and Beverages", "Textiles", "Wood Products",
                   "Paper products", "Petroleum Products and Nuclear fuel", "Chemical Products", "Rubber and Plastic Products",
                   "Other Non-Metallic Mineral Products", "Metal Products", "Machinery", "Electrical Equipment",
                   "Transport Equipment", "Manufacturing", "Electricity, Gas and Water Supply", "Construction", "Trade",
                   "Hotels and Restaurants", "Transport and Storage", "Post and Telecommunication", "Financial Services",
                   "Business Service", "Public Administration and Defense", "Education", "Health and Social Work", "Other services")

summary_stats <- sector_TFP_filtered %>%
  group_by(Sector) %>%
  summarize(
    mean_tfp = mean(as.numeric(TFP_growth), na.rm = TRUE),
    sd_tfp = sd(as.numeric(TFP_growth), na.rm = TRUE)
  ) %>%
  mutate(Sector = sector_labels[1:n()])  # Apply clean labels

summary (summary_stats)
ggplot(summary_stats, aes(x = reorder(Sector, mean_tfp), y = mean_tfp)) +
  geom_col(fill = "steelblue") +
  geom_errorbar(aes(ymin = mean_tfp - sd_tfp, ymax = mean_tfp + sd_tfp), width = 0.3) +
  geom_point(aes(y = mean_tfp), color = "black", size = 2) +
  coord_flip() +
  labs(title = "Average TFP Growth by Sector (1990–2020)",
       x = "Sector", y = "Mean TFP Growth") +
  theme_minimal()


# ─── 3. Sector-Level TFP Growth and FDI Trends ───────────────

selected_sectors <- sector_TFP_filtered_MA %>%
  filter(Sector %in% c("Manufacturing, nec; recycling", "Chemicals and  Chemical Products"))

selected_sectors <- selected_sectors %>%
  group_by(Sector) %>%
  mutate(MA_TFP_growth = rollmean(as.numeric(TFP_growth), 5, fill = NA, align = "right")) %>%
  ungroup()

selected_sectors <- na.omit(selected_sectors)

India_FDI_ma <- India_FDI_long_MA %>%
  mutate(
    MA_FDI_inflows_GDP = rollmean(FDI_inflows_GDP, 5, fill = NA, align = "right"),
    MA_YtoY_inflows_GDP = rollmean(YtoY_FDI, 5, fill = NA, align = "right")
  ) %>%
  drop_na()

ggplot() +
  geom_line(data = selected_sectors, aes(x = as.numeric(Year), y = MA_TFP_growth, color = Sector), size = 1) +
  geom_line(data = India_FDI_ma, aes(x = as.numeric(Year), y = MA_FDI_inflows_GDP * 8, color = "FDI Net Inflows"), size = 1, linetype = "solid") +
  scale_y_continuous(
    name = "TFP Growth",
    limits = c(-10, 20),
    sec.axis = sec_axis(~./8, name = "FDI Net Inflows (% of GDP)")
  ) +
  labs(title = "5-Year Moving Average of TFP Growth and FDI Net Inflows (1990–2020)",
       x = "Year") +
  theme_minimal() +
  theme(legend.title = element_blank(), legend.position = "right") +
  scale_color_manual(values = c("forestgreen", "black", "blue"),
                     labels = c("Chemicals", "FDI Net Inflows", "Manufacturing"))

# ─── 4. Correlation: FDI and Sector-Level TFP Growth ─────────

# Extract TFP growth columns
tfp_columns <- grep("^TFP_growth_", names(India_FDI_long), value = TRUE)

# Define human-readable sector labels
sector_labels <- c("Agriculture", "Mining and Quarrying", "Food and Beverages", "Textiles", "Wood Products",
                   "Paper products", "Petroleum Products and Nuclear fuel", "Chemical Products", "Rubber and Plastic Products",
                   "Other Non-Metallic Mineral Products", "Metal Products", "Machinery", "Electrical Equipment",
                   "Transport Equipment", "Manufacturing", "Electricity, Gas and Water Supply", "Construction", "Trade",
                   "Hotels and Restaurants", "Transport and Storage", "Post and Telecommunication", "Financial Services",
                   "Business Service", "Public Administration and Defense", "Education", "Health and Social Work", "Other services")

# Select and clean relevant data
fdi_tfp_data <- India_FDI_long %>%
  select(FDI_inflows_GDP, all_of(tfp_columns)) %>%
  drop_na() %>%
  mutate(across(everything(), ~ as.numeric(.)))

# Compute correlations
cor_matrix <- cor(fdi_tfp_data)
fdi_cor_values <- cor_matrix["FDI_inflows_GDP", -1]

# Create data frame for plotting
fdi_cor_df <- data.frame(
  Sector = sector_labels[1:length(fdi_cor_values)],
  Correlation = fdi_cor_values
)

# Bar plot
ggplot(fdi_cor_df, aes(x = reorder(Sector, Correlation), y = Correlation)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Correlation Between FDI Inflows and Sector-Level TFP Growth",
       x = "Sector",
       y = "Correlation Coefficient") +
  theme_minimal()

# ─── 5. Correlation Matrix (Regression Variables Only) ───────

# Define only the variables used in regression
regression_vars <- c("FDI_inflows_GDP", "Export_percent_change", "Import_percent_change", 
                     "Gov_spending_percent_change", "Gross_capital_form_percent_change", 
                     "CPI_Growth", "Priv_Credit_Growth", "Crop_prod_growth")

# Filter and drop NAs
cor_data <- India_FDI_long %>%
  select(all_of(regression_vars)) %>%
  drop_na()

# Compute and plot correlation matrix
cor_matrix <- cor(cor_data)
corrplot(cor_matrix, method = "circle", type = "lower", tl.cex = 0.6)
title("Correlation Matrix of Regression Variables", line = 1, cex.main = 1.2)
