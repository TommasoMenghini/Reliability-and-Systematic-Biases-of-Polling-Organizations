# Filtering

This document shows the process to obtain up to the election day estimates of voters'intentions using the Kalman filter on the polling time series. The analysis closely mirrors the implementation in the R modeling script.

> **Prerequisite**  
> This document presupposes that the reader is familiar with the introductory framework outlined in [intro.md](intro.md).

---

## The Polling Time Series

Recall that conducting a political poll consists in asking a set of questions to a given number of different people. The response provided by each individual can be modelled as an independent Bernoulli trial. Aggregating these responses, a poll measuring voting intentions for a given party can therefore be interpreted as a realization of a Binomial random variable.

For each agency-party combination, the polling time series is divided into three sections, each corresponding to an election. For instance, the first section spans from the 2018 general election to the 2019 European election. Applying the Kalman filter to this segment yields an estimate of voters’ intentions up to election day for each party and polling agency in the 2019 election.

The main reasons of this choice are:

1. Polls released after an election are not informative for evaluating the forecasting error associated with that election;
2. The vote share obtained by a given party–agency combination in the election at the beginning of each section is used as the initial value of the Kalman filter;

## Binomial State-Space Model

It is assumed that, for each day t, there exists a real, yet unobserved, value of the voters'intentions, which evolves smoothly over time. Since polling agencies do not release survey on a daily basis, the resulting polling time series contains substantially more missing values than observed data points.

To address this issue, a binomial state-space model is implemented, in which voters' intentions evolve over time according to a local liner trend, as illustrated in the figure below.

![Binomial state-space model](img/modello_state_space_binomiale.png)

Specifically the logit-transformed voters' intentions of tomorrow are modelled as the logit of today plus a random shock and an additional component that follows a random walk. This dynamic structure is flexible yet regual enough to allow for the imputation of days without polls by exploiting the information contained in the previous days.









