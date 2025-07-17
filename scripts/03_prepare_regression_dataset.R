# ─────────────────────────────────────────────────────────────
# 03_prepare_regression_dataset.R
# Description: Prepare dataset by merging FDI, TFP, CPI, credit, and production data
# ─────────────────────────────────────────────────────────────

# Reshape TFP sector data to long format
sector_TFP_long <- sector_TFP %>%
  pivot_longer(cols = `1981`:`2022`, names_to = "Year", values_to = "TFP_growth") %>%
  mutate(Year = as.character(Year))

# Filter sector TFP for years 1989 to 2020
sector_TFP_filtered <- sector_TFP_long %>%
  filter(as.numeric(Year) >= 1989 & as.numeric(Year) <= 2020)

sector_TFP_filtered_MA <- sector_TFP_long %>%
  filter(as.numeric(Year) >= 1986 & as.numeric(Year) <= 2020)

# FDI (% of GDP) - WDI
India_FDI <- WDI[WDI$indicator_code == "BX.KLT.DINV.WD.GD.ZS", ]
India_FDI_long <- India_FDI %>%
  pivot_longer(cols = starts_with("year_"), names_to = "Year", values_to = "FDI_inflows_GDP") %>%
  mutate(Year = as.character(substr(Year, nchar(Year) - 3, nchar(Year))))

# Year-over-year FDI change
India_FDI_long <- India_FDI_long %>%
  mutate(YtoY_FDI = (FDI_inflows_GDP - lag(FDI_inflows_GDP)) / lag(FDI_inflows_GDP) * 100)

India_FDI_long_MA <- India_FDI_long
# Merge TFP sectors into FDI dataset
sectors <- unique(sector_TFP_filtered$Sector)

for (sector in sectors) {
  sector_data <- filter(sector_TFP_filtered, Sector == sector) %>%
    select(Year, TFP_growth)
  col_name <- paste("TFP_growth_", gsub("\\W", "_", sector), sep = "")
  names(sector_data)[2] <- col_name
  India_FDI_long <- left_join(India_FDI_long, sector_data, by = "Year")
}

# Merge TFP sectors into FDI dataset for moving average visualization
sectors_MA <- unique(sector_TFP_filtered_MA$Sector)
for (i in sectors_MA) {
  sector_data_MA <- filter(sector_TFP_filtered_MA, Sector == i) %>%
    select(Year, TFP_growth)
  col_name <- paste("TFP_growth_", gsub("\\W", "_", i), sep = "")
  names(sector_data_MA)[2] <- col_name
  India_FDI_long_MA <- left_join(India_FDI_long_MA, sector_data_MA, by = "Year")
}


# Add macroeconomic controls from PWT (exports, imports, gov spending, etc.)
selected_work_data <- work_data %>%
  select(year, csh_x, csh_m, csh_g, csh_i) %>%
  rename(Year = year) %>%
  mutate(Year = as.character(Year))
India_FDI_long <- left_join(India_FDI_long, selected_work_data, by = "Year") %>%
  rename(Export = csh_x, Import = csh_m, Gov_spending = csh_g, Gross_capital_form = csh_i)

# Calculate percentage change for macro controls
India_FDI_long <- India_FDI_long %>%
  mutate(
    Export_percent_change = (Export - lag(Export)) / lag(Export) * 100,
    Import_percent_change = (Import - lag(Import)) / lag(Import) * 100,
    Gov_spending_percent_change = (Gov_spending - lag(Gov_spending)) / lag(Gov_spending) * 100,
    Gross_capital_form_percent_change = (Gross_capital_form - lag(Gross_capital_form)) / lag(Gross_capital_form) * 100
  )

# Add CPI
India_CPI <- WDI[WDI$indicator_code == "FP.CPI.TOTL", ]
India_CPI_long <- India_CPI %>%
  pivot_longer(cols = starts_with("year_"), names_to = "Year", values_to = "CPI") %>%
  mutate(Year = as.character(substr(Year, nchar(Year) - 3, nchar(Year))))
India_FDI_long <- left_join(India_FDI_long, India_CPI_long[, c("Year", "CPI")], by = "Year") %>%
  mutate(CPI_Growth = (CPI - lag(CPI)) / lag(CPI) * 100)

# Add Private Credit
India_Credit <- WDI[WDI$indicator_code == "FD.AST.PRVT.GD.ZS", ]
India_Credit_long <- India_Credit %>%
  pivot_longer(cols = starts_with("year_"), names_to = "Year", values_to = "Priv_Credit") %>%
  mutate(Year = as.character(substr(Year, nchar(Year) - 3, nchar(Year))))
India_FDI_long <- left_join(India_FDI_long, India_Credit_long[, c("Year", "Priv_Credit")], by = "Year") %>%
  mutate(Priv_Credit_Growth = (Priv_Credit - lag(Priv_Credit)) / lag(Priv_Credit) * 100)

# Add Crop Production Index
India_Crop <- WDI[WDI$indicator_code == "AG.PRD.CROP.XD", ]
India_Crop_long <- India_Crop %>%
  pivot_longer(cols = starts_with("year_"), names_to = "Year", values_to = "Crop_prod_index") %>%
  mutate(Year = as.character(substr(Year, nchar(Year) - 3, nchar(Year))))
India_FDI_long <- left_join(India_FDI_long, India_Crop_long[, c("Year", "Crop_prod_index")], by = "Year") %>%
  mutate(Crop_prod_growth = (Crop_prod_index - lag(Crop_prod_index)) / lag(Crop_prod_index) * 100)

# Remove rows with missing values
India_FDI_long <- na.omit(India_FDI_long)
India_FDI_long_MA <- na.omit(India_FDI_long_MA)

