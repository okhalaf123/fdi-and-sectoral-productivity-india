# ─────────────────────────────────────────────────────────────
# 01_load_and_clean_data.R
# Description: Load libraries and macroeconomic data (WDI, PWT)
# ─────────────────────────────────────────────────────────────
# Load required libraries
library(tidyverse)
library(pwt10)
library(readxl)
library(zoo)
library(car)

# Load PWT 10.0 data and filter for India (2004 onward)
data("pwt10.0")
work_data <- pwt10.0 %>%
  filter(isocode == "IND" & year >= 1989) %>%
  arrange(year)

# Load WDI Excel dataset
WDI <- read_excel("WDIEXCEL.xlsx")
WDI <- WDI[WDI$country_name == "India", ]

# Load KLEMS TFP sector data
sector_TFP <- read_excel("INDIAKLEMS09012024.xlsx", sheet = "TFPG_va")
colnames(sector_TFP) <- c("SL_No", "IndustryCode", "Sector", paste0(1981:2022))
sector_TFP <- sector_TFP[-1, ]
