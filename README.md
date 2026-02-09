# Reliability and Systematic Biases of Polling Organizations

This repository contains the code and materials for an empirical analysis of the **reliability of pre‑election polls** and the presence of **systematic biases shared across polling organizations**.
The project investigates whether aggregating polls (e.g. *Poll of Polls*) effectively removes bias, or whether common structural distortions persist even after aggregation.

The work is developed in the context of my master's dissertation and combines **statistical modeling**, **time‑series analysis**, and **comparative evaluation of polling agencies** across multiple elections.

---

## Project Overview

Pre‑election polls are widely used to forecast electoral outcomes, yet they often exhibit systematic errors. These errors may not be independent across polling organizations, as agencies frequently rely on similar methodologies, assumptions, and data‑collection constraints.

This project addresses the following research questions:
The analysis focuses on Italian elections (European and Political) and multiple major polling agencies.

---

## Methodology

The empirical strategy is structured around two complementary approaches:

1. **Dynamic modeling of polling time series**

   * Polls are treated as noisy observations of an underlying latent voting intention process.
   * A **state‑space model** estimated via **Kalman filtering** is used to smooth polling trajectories and interpolate periods without observations.

2. **Cross‑sectional analysis of polling errors**

   * For each election, agency, and party, the final poll prior to election day is compared with the actual electoral outcome.
   * Distortions are measured as **relative errors**, ensuring comparability across parties with different vote shares.

This framework allows the identification of persistent directional errors and common patterns across agencies.

---

## Repository Structure

```
Reliability-and-Systematic-Biases-of-Polling-
│
├── data/              # Raw and cleaned polling and election data
├── R/                 # R scripts (data cleaning, models, estimation)
├── img/               # Figures and plots used in the analysis
├── output/            # Tables, model outputs, and results
├── README.md          # Project documentation
```

---

## Data

The dataset is composed of polling observations collected from multiple agencies, matched with official election results.

Key characteristics:

* **Response variable**: relative error between the final pre‑election poll and the electoral outcome
* **Explanatory variables**:

  * Polling agency
  * Political party
  * Election (year and type)

In total, the dataset includes **one observation for each agency–party–election combination**.

---

## Main Findings

* Several parties display **persistent over‑ or under‑estimation** across different elections.
* These errors are **not agency‑specific**, but largely **shared across polling organizations**.
* As a consequence, simple aggregation strategies such as the *Poll of Polls* **do not eliminate systematic bias**.
* Aggregated estimates remain vulnerable when all agencies are distorted in the same direction.

These findings are consistent with existing evidence in the literature, notably Shirani‑Mehr et al. (2018), highlighting common structural biases in polling.

---

## Requirements

The project is written in **R**. Required packages include:

* `tidyverse`
* `ggplot2`
* `KFAS`
* `lubridate`

---

## References

* Shirani‑Mehr, H., Rothschild, D., Goel, S., & Gelman, A. (2018). *Disentangling bias and variance in election polls*. Journal of the American Statistical Association.

---

## Author

**Tommaso Menghini**

If you have questions or suggestions, feel free to open an issue or contact me.
