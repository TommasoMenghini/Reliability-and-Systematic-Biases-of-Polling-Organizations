# Reliability and Systematic Biases of Polling Organizations

This repository contains the code and materials for an empirical analysis of the **reliability of pre‑election polls** and the presence of **systematic biases shared across polling organizations**.
The project investigates whether aggregating polls (e.g. *Poll of Polls*) effectively removes bias, or whether common structural distortions persist even after aggregation.

The work is developed in the context of my master's dissertation and combines **statistical modeling**, **time‑series analysis**, and **comparative evaluation of polling agencies** across multiple elections.

---

## Repository structure

The repository is organized as follows:

### R scripts

- **`R/filter.R`**  
  Implements the state-space model and Kalman filter used to estimate latent voting intentions from polling data.

- **`R/polling_error.R`**  
  Computes polling distortions by comparing final pre-election polls with electoral outcomes and constructs the relative error measure.

- **`R/graph.R`**  
  Collection of auxiliary functions used across the analysis.

### Documentation

- **`intro.md`**  
  Introduces the research question, motivation, and empirical setting of the analysis.

- **`filter.md`**  
  Provides a detailed description of the state-space model and the Kalman filtering approach.

- **`polling_error.md`**  
  Describes the construction of the polling error measure and the cross-sectional analysis of distortions.

Each `.md` file alternates **theoretical explanations**, **methodological choices**, and selected **R code snippets**, following a tutorial-style layout.


## Project Overview

Pre‑election polls are widely used to forecast electoral outcomes, yet they often exhibit systematic errors. These errors may not be independent across polling organizations, as agencies frequently rely on similar methodologies, assumptions, and data‑collection constraints.

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

The project is written in **R** (4.3.3 Version). Required packages include:

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
