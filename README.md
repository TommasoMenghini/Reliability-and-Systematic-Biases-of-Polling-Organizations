# Reliability and Systematic Biases of Polling Organizations

This repository contains the code and materials for an empirical analysis of the **reliability of pre‑election polls** and the presence of **systematic biases shared across polling organizations**.
The project investigates whether aggregating polls (e.g. *Poll of Polls*) effectively removes bias, or whether common structural distortions persist even after aggregation.

The work is developed in the context of my master's dissertation and combines **statistical modeling**, **time‑series analysis**, and **comparative evaluation of polling agencies** across multiple elections.

---

## Repository structure

The repository is organized as follows:

### R scripts

- **`R/filter_function.R`**  
  Wrapper around the `KFS()` function used to estimate the latent voting intention process.

- **`R/graph_function.R`**  
  Function to visualize filtered estimates of voting intentions over time.

- **`R/filter_results.R`**  
  Implements the state-space model and Kalman filter used to estimate latent voting intentions from polling data.

- **`R/error_analysis.R`**  
  Analyzes the reliability and systematic biases of polling organizations using polling error measures.

### Documentation

- **`intro.md`**  
  Introduces the research question, motivation, and empirical setting of the analysis.

- **`filter.md`**  
  Provides a detailed description of the state-space model and the Kalman filtering approach.

- **`polling_error.md`**  
  Describes the construction of the polling error measure and the cross-sectional analysis of distortions.

Each `.md` file alternates **theoretical explanations**, **methodological choices**, and selected **R code snippets**, following a tutorial-style layout.

## Project Overview

The study was developed along two parallel lines. The first one aimed to assess whether systematic biases in the voters' intentions based on pre-electoral polls exist. The second sought to identify potential structural differences in reliability among the polling agencies in Italy, exploring the possibility that some of them may be structurally more accurate in forecasting electoral outcomes.

---

## Methodology

The empirical strategy is structured around two complementary approaches:

1. **Dynamic modeling of polling time series**

   * Polls are treated as noisy observations of an underlying latent voting intention process.
   * A **state‑space model** estimated via **Kalman filtering** is used to smooth polling trajectories and interpolate periods without observations.

2. **Cross‑sectional analysis of polling errors**

   * For each election, agency, and party, the final poll prior to election day is compared with the actual electoral outcome.
   * For each election, agency and party, the 
   * Distortions are measured as **relative errors**, ensuring comparability across parties with different vote shares.

This framework allows the identification of persistent directional errors and common patterns across agencies.

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

* Some parties display **persistent over‑ or under‑estimation** across different elections.
* These errors are **not agency‑specific**, but largely **shared across polling organizations**.
* As a consequence, simple aggregation strategies such as the *Poll of Polls* **do not eliminate systematic bias**.
  
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
