# Polling Error Analysis

In this document the polling error analysis is carried out. Specifically, the first objective is to investigate the presence of systematic biases in the forecasts of voters' intentions provided by polling agencies for each selected party and election. The second objective is to assess the precision of the agencies' forecasts, with a particular focus on whether some agencies are more reliable than others. The analysis closely mirrors the implementation in the R script [error_analysis.R](R/error_analysis.R).

> **Prerequisite**  
> This document assumes that the reader is familiar with the introductory framework outlined in [intro.md](intro.md) and in [filter.md](filter.md).

---

## Preliminary remarks

The results are shown only for the definition of the response variable that relies on the interpolation of the polls up to the election day, but they are also valid for the alternative definition, the one that uses the last poll prior to the election.

The code chunk below initializes the working environment and loads some useful packages. It then imports the dataset polling_error2.csv.

The dataset is organized as a cross-sectional structure in which each observation corresponds to a specific combination of polling agency, political party, and election. The explanatory variables are categorical and identify these three dimensions, while the response variable measures the forecasting error relative to the actual electoral outcome, according to the definition introduced in [intro.md](intro.md) and in [filter.md](filter.md). This structure allows for the assessment of both systematic biases and differences in predictive accuracy across agencies.

```r
rm(list = ls())

library(ggplot2)
library(ggthemes)
library(broom)
library(knitr)    # aesthetically pleasing tables
library(car)      # forecasting with arbitrary vcov matrix
library(sandwich) # robust estimates of standard errors
library(lmtest)

dataset <- read.csv("polling_error2.csv", header = TRUE, stringsAsFactors = TRUE)
```

## Presence of Systematic Biases

The image below shows the conditioned boxplot of the response variable by the independent variable Agency. No clear pattern emerges, suggesting that polling agencies do not differ systematically in terms of relative error.

![Boxplot conditioned to independent variable Agency](img/boxplot_ist2.png)


