# Study of Statistical Reliability and Systematic Biases of Polling Organizations in the Italian political context

This document outlines the underlying motivations and theoretical foundations of my thesis and then proceeds to quickly describe the main results obtained. The analysis shown here refers to the R script error_analysis.

## Motivations

The study was developed along two parallel lines. The first one aimed to assess whether systematic biases in the voters' intentions based on pre-electoral polls exist. The second sought to identify potential structural differences in reliability among the polling agencies in Italy, exploring the possibility that some of them may be structurally more accurate in forecasting electoral outcomes.

## What Is a Pre-Electoral Poll?

Electoral polls are one of the most common demonstrations of the use of statistics in everyday life. However, over the last ten years, their reliability has been heavily criticized, especially in light of several incorrect predictions of high-profile political events, such as the 2016 U.S. presidential election.

Conducting an opinion poll involves reaching a certain number of individuals and asking them a series of questions. Among these, respondents are typically asked which candidate or party they intend to vote for in the upcoming election. There are several reasons why this process may lead to inaccurate results.

The key issue is that pre-electoral polls are affected by a wide variety of errors, including both sampling and non-sampling errors. These are collectively referred to as total survey error. While sampling error can be reduced by increasing the sample size or conducting more polls, non-sampling error cannot be mitigated in the same way.

Pollsters minimize the error adjusting their data for known differences between the raw sample and the target population. They use post-stratification techniques, such as weighting. Each individual of the sample is assigned with a numerical weight, defined so that the weighted distributions of demographic variables in the raw sample match the marginal distributions referring the target population. If pollsters fail to correct for this known differences, then there is a risk of obtaining heavily biased estimates.

## The Data and the Idea

The data were made available by YouTrend and consist of pre-election polls conducted in Italy between 2018 and 2024. For each poll, the dataset includes the polling agency that conducted it, the date, the sample size, and the estimates of voters’ intentions for a set of political parties.

Furthermore, during this period four elections were held in Italy: the 2018 general election, the 2019 European Parliament election, the 2022 general election, and the 2024 European Parliament election. The aim of this study is to assess the reliability of each polling agency by evaluating the discrepancy between their predictions and the actual election outcomes.

The main references were [Gelman (2021)](https://www.tandfonline.com/doi/full/10.1080/2330443X.2021.1971126) and [Shirani-Mehr et al.(2018)](https://www.tandfonline.com/doi/full/10.1080/01621459.2018.1448823).

## Data Cleansing

It is well known that the italian political context is highly fragmented. This volatility makes it difficult to mantain a homogeneous set of political subjects over the entire period of analysis. For this reason, I decided to focus on a restricted, yet stable, set of political actors: Fratelli d'Italia, Forza Italia, Lega, Movimento 5 Stelle and Partito Democratico. These represented the main political parties in Italy throughout the period under analysis.

It was also necessary to select a subset of polling agencies, as not all of them provided a regular and sufficiently long time series. Keep in mind that the analysis requires to build a balanced setting in which there are the same number of election-party combination for each agency. Therefore I decided to restrict to only those agencies with at least one observation prior to the 2019 and 2024 Europeans and the 2022 Politics, and that guaranteed a number of published polls sufficiently large.

## Intuition: voters' intention and electoral results

![Testo alternativo](percorso/immagine.png)


