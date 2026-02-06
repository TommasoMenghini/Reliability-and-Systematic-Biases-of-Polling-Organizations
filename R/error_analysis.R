rm(list = ls())

library(ggplot2)
library(ggthemes)
library(broom)
library(knitr)    # aesthetically pleasing tables
library(car)      # forecasting with arbitrary vcov matrix
library(sandwich) # robust estimates of standard errors
library(lmtest)

dataset <- read.csv("polling_error2.csv", header = TRUE, stringsAsFactors = TRUE)

# First Analysis: Presence of Systematic Biases ------------------------------------------------------------

boxplot_ist2 <- ggplot(data = dataset, aes(x = Istituto, y = rel_err2, fill = Istituto)) + 
  geom_boxplot() +
  scale_fill_tableau(palette = "Tableau 20") +
  xlab(NULL) + 
  ylab("Errore Relativo %") +
  scale_y_continuous(labels = scales::percent, limits = c(-0.5, 0.5)) +
  theme_light() +
  theme(
    text = element_text(size = 22),
    axis.text = element_text(size = 16),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    legend.position = "top",
    legend.text  = element_text(size = 20),
    legend.title = element_text(size = 30)) 
  

boxplot_interaction2 <- ggplot(data = dataset, aes(x = Partito, y = rel_err2, fill = Partito)) + 
  geom_boxplot() +
  geom_hline(yintercept = 0, linetype = "dotted") +
  xlab(NULL) +
  ylab("Errore Relativo %") +
  scale_fill_manual(values = c("PD" = "red", "LEGA" = "green", "FDI" = "blue", "FI" = "#80FFFF", "M5S" = "#FFE800")) +
  facet_wrap(~ Elezione) +
  scale_y_continuous(labels = scales::percent, limits = c(-0.5, 0.5))  +
  theme_light() +
  theme(
    text = element_text(size = 22),
    axis.text = element_text(size = 16),
    legend.position = "top",
    strip.background = element_rect(fill = "navy", color = "grey20"),
    axis.text.x = element_text(angle = 45, hjust = 1))


# Model with interaction and agency
m1 <- lm(rel_err2 ~ Istituto + Partito * Elezione, data = dataset)
( tab1 <- anova(m1) )

( sq_res1 <- sum((dataset$rel_err2 - m1$fitted.values)^2) ) 

m.ist <- lm(rel_err2 ~ Istituto, data = dataset)
( sq_reg_Ist <- sum((m.ist$fitted.values - mean(dataset$rel_err2))^2) )

# In a balanced dataset the sums of squares in the table add up to the total sum of squares of the data

TSS1 <- sum(tab1$`Sum Sq`)

m.null <- lm(rel_err2 ~ 1, data = dataset)
tss1 <- sum((dataset$rel_err2 - m.null$fitted.values)^2)


# Model with interaction only 
m2 <- lm(rel_err2 ~ Partito * Elezione, data = dataset)
( tab2 <- anova(m2) )

anova(m2, m1)
( f.stat <- ((tab2$`Sum Sq`[4] - tab1$`Sum Sq`[5]) / 10) / (tab1$`Sum Sq`[5] / 140) )
( p_val <- 1 - pf(f.stat, df1 = 10, df2 = 140) )

augmented_m1 <- augment(m1)
resid_fitted2 <- ggplot(data = augmented_m1, aes(x = .fitted, y = .resid)) +
  geom_point(size = 3) +
  geom_hline(aes(yintercept = 0), linetype = "dotted") +
  theme_light() +
  theme(text = element_text(size = 22), axis.text = element_text(size = 16)) +
  xlab("Valori Stimati") +
  ylab("Residui")

waldtest(m2, m1, vcov = vcovHC(m1)) # same result


# Forecasting for each party-election agency
newdata <- expand.grid(
  Partito = c("FDI", "FI", "LEGA", "M5S", "PD"),
  Elezione = c("2019 Europee", "2022 Politiche", "2024 Europee")
)

# Naïve CI, without molteplicity correction, corrected for robust standard errors.
#
# Note: the Predict (with capital P) function is used, from the car package, that allows to correct for robust standard errors
alpha <- 0.01
tab_naive <- cbind(newdata, Predict(m2, newdata = newdata, level = 1 - alpha, interval = "confidence", vcov. = vcovHC(m2)))
kable(tab_naive, digits = 3)

# CI: Bonferroni correction + robust standard errors.
# These intervals are wider than the naïve ones
m <- nrow(tab_naive) # Number of test that are made
tab_bonf <- cbind(newdata, Predict(m2, newdata = newdata, level = 1 - alpha / m, interval = "confidence", vcov. = vcovHC(m2)))
kable(tab_bonf, digits = 3)

pair_range <- ggplot(data = tab_bonf, aes(x = Partito, y = fit, ymin = lwr, ymax = upr, col = Partito)) + 
  geom_pointrange(linewidth = 1, size = 1) +
  theme_light() +
  facet_wrap(~ Elezione) +
  scale_color_manual(values = c("PD" = "red", "LEGA" = "green", "FDI" = "blue", "FI" = "#80FFFF", "M5S" = "#FFE800")) +
  theme(legend.position = "top") +
  geom_hline(yintercept = 0, linetype = "dotted") +
  ylab("Errore relativo %") +
  xlab("Partito") +
  scale_y_continuous(labels = scales::percent, limits = c(-0.5, 0.5)) +
  theme(text = element_text(size = 22), axis.text = element_text(size = 16), legend.position = "top", strip.background = element_rect(fill = "navy", color = "grey20"))

  
# Second Analysis: Statistic Reliability ------------------------------------------------------------

boxplot_ist_abs <- ggplot(data = dataset, aes(x = Istituto, y = abs(rel_err2), fill = Istituto)) + 
  geom_boxplot() +
  scale_fill_tableau(palette = "Tableau 20") +
  xlab(NULL) + 
  ylab("Errore Relativo % (valore assoluto)") +
  scale_y_continuous(labels = scales::percent) +
  theme_light() +
  theme(
    text = element_text(size = 22),
    axis.text = element_text(size = 16),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    legend.position = "top",
    legend.text  = element_text(size = 20),
    legend.title = element_text(size = 30)) 

boxplot_interaction_abs <- ggplot(data = dataset, aes(x = Partito, y = abs(rel_err2), fill = Partito)) + 
  geom_boxplot() +
  xlab("Partito") +
  ylab("Errore Relativo % (valore assoluto)") +
  scale_fill_manual(values = c("PD" = "red", "LEGA" = "green", "FDI" = "blue", "FI" = "#80FFFF", "M5S" = "#FFE800")) +
  facet_wrap(~ Elezione) +
  scale_y_continuous(labels = scales::percent)  +
  theme_light() +
  theme(
    text = element_text(size = 22),
    axis.text = element_text(size = 16),
    legend.position = "top",
    strip.background = element_rect(fill = "navy", color = "grey20"),
    axis.text.x = element_text(angle = 45, hjust = 1))

m2 <- lm(abs(rel_err2) ~ Partito * Elezione, data = dataset)
m3 <- lm(abs(rel_err2) ~ Istituto + Partito * Elezione, data = dataset)

# With this test you verify if there exist some differences in terms of precision among agencies.
anova(m2, m3) # No, they do not exist

augmented_m3 <- augment(m3)
resid_fitted_abs <- ggplot(data = augmented_m3, aes(x = .fitted, y = .resid)) +
  geom_point(size = 3) +
  geom_hline(aes(yintercept = 0), linetype = "dotted") +
  theme_light() +
  theme(text = element_text(size = 22), axis.text = element_text(size = 16)) +
  xlab("Valori Stimati") +
  ylab("Residui")

# If we are worried about the heterosckedasticity:
library(lmtest)
waldtest(m2, m3, vcov = vcovHC(m3)) # Same result

# APPENDIX I: log error vs relative error -----------------------------------

# The two indexes are very similar, or at least not that different to change the conclusions in a substantial way
plot(dataset$rel_err2, dataset$log_err2, pch = 16, xlab = "Errore relativo", ylab = "Errore logaritmico")
abline(c(0, 1))

# APPENDIX II:

par(mfrow = c(2, 2))
plot(m1)
par(mfrow = c(1, 1))

# There's heterosckedasticity.

# APPENDIX III:

par(mfrow = c(2, 2))
plot(m3)
par(mfrow = c(1, 1))

# There's heterosckedasticity.
