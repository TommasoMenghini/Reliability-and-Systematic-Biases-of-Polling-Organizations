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

The image below shows the conditioned boxplots of the response variable by the independent variable Agency. No clear pattern emerges, suggesting that polling agencies do not differ systematically in terms of relative error.

![Boxplot conditioned to independent variable Agency](img/boxplot_ist2.png)

The image below shows the jointly conditioned boxplots of the response variable by the independent variables Party and Election. In this case, some patterns emerge, suggesting that these two factors may help explain the response variable. Moreover, the response varies differently across Party-Election combinations, suggesting the presence of an interaction between these factors. Therefore, an appropriate model should include an interaction term between Party and Election.

![Boxplot conditioned to independent variables Party and Election](img/boxplot_interaction.png)

Hence, the following linear model is fitted and an ANOVA is performed. The analysis of variance allows for the assessment of the relative importance of the different sources of variation, namely the factors Agency, Party, Election, and their interaction.

The ANOVA results are summarised in the table below. Focusing on the p-value column, the p-value associated with the Agency covariate is greater than the chosen significance threshold. This indicates that the polling agency does not contribute to explaining the variability of the response variable, and its inclusion in the model does not improve the model fit.

In contrast, the p-values associated with Party and with the interaction term are extremely small. Therefore, the null hypothesis can be rejected, suggesting that these sources of variation play a relevant role in explaining the response variable.

In light of these results, it appears reasonable to fit a new linear model that excludes the Agency variable.

```r
m1 <- lm(rel_err2 ~ Istituto + Partito * Elezione, data = dataset)
( tab1 <- anova(m1) )

m2 <- lm(rel_err2 ~ Partito * Elezione, data = dataset)
```

<div align="center">
  
| Term              | Df  | Sum Sq | Mean Sq | F value | Pr(>F)        |
|-------------------|-----|--------|---------|---------|---------------|
| Istituto          | 10  | 0.0418 | 0.00418 | 0.9234  | 0.5137        |
| Partito           | 4   | 0.7314 | 0.18286 | 40.3507 | < 2·10⁻¹⁶     |
| Elezione          | 2   | 0.0211 | 0.01056 | 2.3306  | 0.1010        |
| Partito:Elezione  | 8   | 4.2531 | 0.53163 | 117.3138| < 2·10⁻¹⁶     |
| Residui           | 140 | 0.6344 | 0.00453 | —       | —             |

</div>

However, a visual inspection of the residuals suggests the possible presence of heteroskedasticity.

![Residuals vs Fitted](img/resid_fitted2.png)

This is problematic, as standard inferential procedures — such as those based on ANOVA — may become inappropriate, potentially leading to incorrect inferential conclusions. To address this issue, a Wald test is performed on the two nested models, `m1` and `m2`, using a heteroskedasticity-robust estimator of the variance–covariance matrix. Several types of heteroskedasticity-consistent covariance matrix (HCCM) estimators exist; the one employed here is the following:

![HCCM](img/stimatore_robusto_varianza.png)

The null hypothesis is not rejected: the Agency variable does not significantly improve the model fit. Therefore, this additional test corroborates the results obtained earlier.

```r
waldtest(m2, m1, vcov = vcovHC(m1))
```

The quantities of interest are now the confidence intervals of the fitted values of the response variable for each Party–Election combination. The objective is to assess whether these fitted values are significantly different from zero. Specifically, if the 95% confidence interval for a given combination includes zero, there is no evidence of a systematic bias. In other words, this would suggest that polling firms tend to overestimate or underestimate the electoral outcome only by chance.

Conversely, fitted values that are significantly different from zero would indicate the presence of a systematic bias, implying that for a specific combination of factors there exists a non-zero error in a particular direction.

As in the previous analysis, correct inference requires appropriate adjustments for heteroskedasticity. In this case as well, the same heteroskedasticity-consistent covariance matrix (HCCM) estimator is employed.

However, an additional issue arises: multiplicity. The probability of incorrectly rejecting the null hypothesis increases with the number of tests performed, and in this setting there are 15 tests, one for each Party–Election combination. Therefore, a correction for multiple testing is required. In this study, the Bonferroni correction is adopted, as it represents the simplest and most straightforward approach, although it is known to be conservative. Indeed, the reduction in the probability of Type I errors comes at the cost of an increased probability of Type II errors.


```r
# Forecasting for each party-election agency
newdata <- expand.grid(
  Partito = c("FDI", "FI", "LEGA", "M5S", "PD"),
  Elezione = c("2019 Europee", "2022 Politiche", "2024 Europee")
)

m <- nrow(tab_naive) # Number of test that are made
tab_bonf <- cbind(newdata, Predict(m2, newdata = newdata, level = 1 - alpha / m, interval = "confidence", vcov. = vcovHC(m2)))
```


The figure below reports the estimated fitted values of the relative error and their robust and corrected confidence intervals for each Party–Election combination.

M5S appears to be systematically misestimated across elections: it is overestimated in the 2019 European elections, underestimated in the 2022 general elections, and again overestimated in the 2024 European elections. Lega shows a specular and opposite pattern, being underestimated in 2019, strongly overestimated in 2022, and slightly underestimated in 2024.

In contrast, Forza Italia does not appear to be affected by systematic distortions. In all three electoral rounds considered, the confidence intervals include zero; therefore, there is insufficient evidence to reject the null hypothesis of no systematic bias in the estimation of this party by polling agencies.

For Fratelli d’Italia, a tendency toward systematically biased estimates emerges in all three elections, although in the case of the 2022 general elections the confidence interval is close to zero.

Finally, for the Democratic Party (PD), the confidence interval includes zero in the 2019 European elections, while in the subsequent two electoral rounds a systematic overestimation and underestimation are observed, respectively.

![Residuals vs Fitted](img/pair_range2.png)


Overall, there is evidence of the presence of systematic distortions that are specific to party–election combinations. These patterns do not appear to be attributable to arbitrary choices in the construction of the error measure, but rather reflect structural features of the estimation of voting intentions derived from pre-electoral polling data.

## Cross-agency heterogeneity in polling reliability

Now the focus shifts to the analysis of cross-agency heterogeneity in polling reliability. Previously a distinction was made between overestimation and underestimation; however, this distinction is now redundant and of secondary importance. The objective is instead to evaluate the overall accuracy of the estimates provided by the different agencies. For this reason, the absolute value of the relative error is considered: overestimates and underestimates of the same magnitude are treated equivalently.

The preliminary graphical analysis mirrors that carried out in the section above. The same boxplots are considered, with the only difference that the response variable is now expressed in absolute terms. Despite this transformation, the qualitative conclusions remain unchanged. No systematic differences in overall reliability across polling agencies emerge, while clear systematic patterns associated with Party and Election persist, suggesting the relevance of including both factors and their interaction in the model. For brevity, these plots are not reported.

Thus, two linear models are fitted. The first includes all available independent variables—Agency, Party, Election, and the interaction between the latter two—while the second excludes the Agency variable.

```r
m2 <- lm(abs(rel_err2) ~ Partito * Elezione, data = dataset)
m3 <- lm(abs(rel_err2) ~ Istituto + Partito * Elezione, data = dataset)
```

The null hypothesis that Agency does not contribute to explaining the response variable is tested. As residual diagnostics indicate possible heteroskedasticity, a robust Wald test is employed, as done previously. The null hypothesis cannot be rejected, indicating that Agency is not statistically significant.

```r
library(lmtest)
waldtest(m2, m3, vcov = vcovHC(m3))
```

Once political and electoral context is accounted for through the Party and Election variables and their interaction, no systematic differences in reliability across polling agencies emerge. Estimation errors in voting intention forecasts are not driven by the agency conducting the poll, but by the specific context in which the prediction is made.

The key result is that the polling agencies considered in this analysis are essentially interchangeable in terms of reliability: conditional on the same information set and contextual factors, one agency is as reliable as another.

## Conclusions

To sum up, parties are estimated with a certain degree of error in each election, and this error is not specific to individual polling agencies but rather shared across them. This finding allows for a critique of the Poll of Polls approach. Aggregating polls does not eliminate this shared distortion, which persists even when averaging over a large number of observations. An aggregative model is only as reliable as the polls it is built upon: if all agencies are systematically biased in the same direction, aggregation will yield misleading results. Consequently, the Poll of Polls does not constitute a solution to the structural limitations of pre-election polling.

Similar evidence is also reported in [Shirani-Mehr et al.(2018)](https://www.tandfonline.com/doi/full/10.1080/01621459.2018.1448823), who show that, in the U.S. context, polls referring to the same election tend to share a common systematic bias.

One possible explanation, also discussed in the cited paper, is that polling agencies conducting and publishing electoral surveys face similar challenges and rely on comparable organizational structures and methodological approaches to address them, thereby converging to similar results.
