rm(list = ls())

library(dplyr)

KF.sond <- function(data, Sond){
  
  partiti <- unique(data$Partito)
  KF.results <- list()
  
  for (j in seq_along(partiti)){
    
    risultato <- KF.part.sond(data, partito = partiti[j], sondaggista = Sond, confidence = T)
    KF.results[[partiti[j]]] <- risultato
    
  }

  return(KF.results)

}

source("Script Per Github/filter_function.R")
source("Script Per Github/graph_function.R")

# Loading the data ----------------------------------------------------------

data <- read.csv("polls_cleaned.csv", header = T, sep = ",")
data$Data <- as.Date(data$Data, format = "%Y-%m-%d")

summary(data)
unique(data$Istituto)

# Final results --------------------------------------------------------

final.swg <- KF.sond(data, Sond = "swg")

plt <- final.swg$PD$plots[[1]]

ggsave("Script per Github/img/swg_PD_1.png", plt, width  = 12, height = 7, units  = "in", dpi = 300)

