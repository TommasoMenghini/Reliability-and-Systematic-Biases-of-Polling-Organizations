## Filter Function
# Arguments: Data; Partito; Istituto
# Values: State-Space Model; ML estimates of error variances;
#         Model log-likelihood; Filtered estimates variance; Filtered estimates; 
#         95% CI; output graph;

# Useful libraries

library(KFAS)
library(dplyr)

KF.part.sond <- function(data, partito, sondaggista, confidence = F){
  
  polls <- data %>% filter(Istituto %in% c(sondaggista, "elezioni"))
  polls <- polls %>% filter(Partito == partito)
  
  # The series is converted to a daily frequency
  
  dates <- tibble(Data = seq(data$Data[1], data$Data[nrow(data)], by = "day"))
  polls <- left_join(dates, polls, by = "Data")
  
  # Sample / Number of Bernoulli trials
  
  u <- polls$N
  u[which(is.na(u))] <- median(polls$N, na.rm = T)
  
  # People that voted party x / Successes 
  
  Y <- round(polls$Percentuale/100 * u)
  
  # Now I divide the time series.
  # I consider three sections, each one corresponding to an interval between two elections

  indici_elez <- which(polls$Istituto == "elezioni")
  
  # First Interval: 2018 Politics - 2019 Europeans
  # Second Interval: 2019 Europeans - 2022 Politics
  # Third Interval: 2022 Politics - 2024 Europeans

  cut.polls <- list()
  cut.Y <- list()
  cut.u <- list()
  
  for (i in 1:3){
    
    cut.polls[[i]] <- polls[(indici_elez[i]):indici_elez[i+1], ]
    cut.Y[[i]] <- Y[(indici_elez[i]+1):indici_elez[i+1]]
    cut.Y[[i]][length(cut.Y[[i]])] <- NA       # the last observation, that is the election outcome is put as a NA 
    cut.u[[i]] <- u[(indici_elez[i]+1):indici_elez[i+1]]
    
  }
  
  
  
  # LLT ---------------------------------------------------------------------
  # binomial response based on LLT
  
  ## The model:
  ## y_t follows p(y_t | theta_t) = Bin(n_t, pi_t)
  ## theta_t = log[pi_t / (1-pi_t)]  
  ## theta_{t+1} = theta_t + nu_t + eta_t   eta_t follows a Normal(0, sigma_eta^2)
  ## nu_{t+1} = nu_t + xi_t     xi_t follows a Normal(0, sigma_xi^2) 
  
  # Link function
  inv_logit <- function(x) {
    exp(x)/(1+exp(x))
  }
  
  # what we want:
  models <- list()     # description of state-space model
  sigmas <- list()     # ML estimate of error variances of unobserved components (Trend and Slope)
  loglik <- list()     # state-space model log-likelihood 
  P_var <- list()      # filtered estimates variance
  dt <- list()         # data frame where are saved Data, Percentuale, Trend Filtrato, Conf. Intervals
  plots <- list()      # list to save graphs for each party-agency-election combination
  
  for(i in 1:3){
    
    modello <- SSModel(cut.Y[[i]] ~ SSMtrend(2, Q = list(NA, NA)), distribution = "binomial", u = cut.u[[i]])
    
    initValue.theta <- log(Y[indici_elez[i]]/u[indici_elez[i]] / (1 - Y[indici_elez[i]]/u[indici_elez[i]]))
    initValue.slope <- 0
    
    modello$a1[1,1] <- initValue.theta    # initial value for the Trend mean: election outcome at the start of the interval
    modello$a1[2, 1] <- initValue.slope   # initial value for the Slope mean: equal to zero
    
    modello$P1[1, 1] <- var(cut.Y[[i]]/cut.u[[i]], na.rm = T)   # initial value for the Trend variance
    
    modello$P1inf[1, 1] <- 0            # non diffuse initialization for the Trend component
    modello$P1inf                       # diffuse initialization for the Slope component
    
    # Update function of the parameters (error variances of the unobserved components)
    updt <- function(pars, model) {
      model$Q[1, 1, 1] <- exp(pars[1])
      model$Q[2, 2, 1] <- exp(pars[2])
      model
    }
    
    # ML estimates of the error variance of the unobserved components)
    fit <- fitSSM(modello, log(c(var(modello$y, na.rm = T), 0.1)), updt)
    
    # if convergence is not verified, then a warning pops out
    if (fit$optim.out$convergence != 0) {
      warning(paste("No convergenza al blocco", i, "del partito", partito))
    }
    
    
    models[[i]] <- fit$model
    sigmas[[i]] <- c(exp(fit$optim.out$par))
    loglik[[i]] <- logLik(fit$model)
    
    # Computing the filter
    filtr1 <- KFS(fit$model, filter = c("state", "signal"))
    
    # Trend filtered estimates
    a <- drop(filtr1$a[, 1])
    P <- filtr1$P[1, 1, ]
    
    P_var[[i]] <- P
    
    # link function to go back in the original scale
    logit_p <- drop(filtr1$a[, 1])      
    p_filtered <- inv_logit(logit_p) * 100
    
    # Coerence Check 
    if (length(p_filtered) - dim(cut.polls[[i]])[1] != 0) {
      stop(paste("Il blocco", i, "ha lunghezze di filtro e polls diverse"))
    }
    
    # 95% IC
    my_lwr <- inv_logit(a - qnorm(0.975)*sqrt(P))*100
    my_upp <- inv_logit(a + qnorm(0.975)*sqrt(P))*100
    
    # Data frame with Data, Stime filtrate e Conf. Intervals
    trend <- tibble(Data = cut.polls[[i]]$Data, 
                    Trend = p_filtered, lwr = my_lwr,
                    upp = my_upp)
    
    
    dt[[i]] <- tibble(cut.polls[[i]]$Data, cut.polls[[i]]$Percentuale, p_filtered, my_lwr, my_upp)
    colnames(dt[[i]]) <- c("Data", "Percentuale", "Filtro", "Lwr", "Upr")
    
    blocco <- i
    
    if(blocco %in% c(1, 3)){
      a <- "Politiche"
      b <- "Europee"
    } else {
      a <- "Europee"
      b <- "Politiche"
    }
    
    # if I want the IC are show in the plot
    conf = confidence
    
    plots[[i]] <- filter.plot2(ts = polls, blocco, trend, a = a, b = b, Part = partito, Sond = sondaggista, confidence = conf)
    
  }
  
  out <- list()
  
  out$models <- models
  out$sigmas <- sigmas
  out$loglik <- loglik
  out$P <- P_var 
  out$dt <- dt
  out$plots <- plots
  
  return(out)
}
