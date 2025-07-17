# FDI and Productivity in India’s Manufacturing Sector (1990–2020)

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Objective](#objective)
- [Tools & Technology](#tools--technology)
- [Methodology](#methodology)
- [Key Visualizations](#key-visualizations)
- [Results Summary](#results-summary)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [Repository Contents](#repository-contents)
- [Author](#author)

## Project Overview

This project investigates how foreign direct investment (FDI) affects total factor productivity (TFP) in India’s manufacturing sector from 1990 to 2020. The study was motivated by the formation of India’s National Manufacturing Competitiveness Council (NMCC) in 2004, a policy aimed at attracting FDI and boosting industrial performance. Using macroeconomic indicators and sector-level productivity data, the project examines whether FDI inflows are linked to productivity improvements and how these effects vary across industries.

---

## Objective

- Assess whether post-2004 FDI-promotion policies improved TFP in manufacturing.
- Compare FDI-TFP relationships across 27 sectors.
- Benchmark manufacturing outcomes against a placebo sector (chemicals).
- Provide insights for industrial and investment policy design.

---

## Tools & Technology

- **Language:** R
- **Packages:** `dplyr`, `tidyr`, `ggplot2`, `car`, `readxl`, `zoo`
- **Structure:** Modular scripts for data prep, modeling, visualization, diagnostics.

---

## Methodology

- **Data Sources:**
  - Penn World Table (PWT 10.0): Capital, labor, and GDP
  - World Development Indicators: FDI and macro controls
  - India KLEMS: TFP growth by sector

- **Process:**
  1. Growth accounting to estimate TFP
  2. Regression dataset creation with macro controls
  3. Exploratory data analysis to identify patterns
  4. OLS regression modeling based on prior literature
  5. Sector-specific interpretation of FDI-TFP dynamics

---

## Key Visualizations

- Output growth decomposition by factor (Growth Accounting)
- TFP and FDI trends over time
- Distribution of FDI inflows (% GDP)
- Sector-wise average TFP growth and variability
- Sector-level correlation between FDI and TFP
- Regression coefficients and confidence intervals by sector

---

## Results Summary

- **Positive, Significant FDI-TFP Links:** Wood Products, Textiles  
- **Negative, Significant FDI-TFP Links:** Hotels & Restaurants, Construction, Electricity/Gas/Water, Chemicals  
- **No Significant Link in Manufacturing** despite moderate correlation and high average growth  
- **Placebo Sector (Chemicals):** High productivity growth not driven by FDI  
- **Multicollinearity:** Present among some macro controls (exports, imports, credit)

---

## Recommendations

See [full report](Full_Report.pdf) for tailored policy recommendations directed at:
- Ministry of Commerce & Industry
- Ministry of Finance
- Ministry of Chemicals & Fertilizers
- NITI Aayog

---

## Limitations

- National FDI data used as sector proxy due to lack of disaggregated data.
- Cannot isolate NMCC policy effects from other reforms.
- Linear regression models underperformed in certain sectors.
- Some controls showed multicollinearity.

---

## Repository Contents

- `scripts/`: All R scripts by function (cleaning, modeling, plotting)
- `data/`: Cleaned datasets (not included if confidential)
- `visualizations/`: Exported graphs used in report
- `Full_Report.pdf`: Complete final report
- `README.md`: Project overview

---

## Author

Omar Khalaf  
Emerging Markets Project (2024)  
Carnegie Mellon University in Qatar

