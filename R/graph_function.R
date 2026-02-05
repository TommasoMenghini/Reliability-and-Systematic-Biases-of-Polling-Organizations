## Filter Graph Function
# Arguments: Data; Section; Data frame with Data, filtered estimates and
#            Conf. Intervals; start election, final election, party, institute,
#            IC

# Values: Plot KF with ts and IC;

# Useful libraries

library(dplyr)
library(ggplot2)
library(lubridate)

filter.plot2 <- function(ts, blocco, trend, a, b, Part, Sond, confidence = TRUE){
  
  ts <- ts %>%
    mutate(Percentuale = Percentuale/100)
  
  trend <- trend %>%
    mutate(Trend = Trend/100, lwr = lwr/100, upp = upp/100)
  
  i <- blocco
  indici_elez <- which(ts$Istituto == "elezioni")
  
  first_point <- ts[indici_elez[i], ]
  last_point  <- ts[indici_elez[i+1], ]
  
  min.perc <- min(ts$Percentuale[indici_elez[i]:indici_elez[i+1]], na.rm = TRUE)
  max.perc <- max(ts$Percentuale[indici_elez[i]:indici_elez[i+1]], na.rm = TRUE)
  
  min.conf <- min(trend$lwr, na.rm = TRUE)
  max.conf <- max(trend$upp, na.rm = TRUE)
  
  # graph limits
  min.fin <- min(min.perc, min.conf)
  max.fin <- max(max.perc, max.conf)
  
  # some scale adjustements
  pad_y  <- 3.5/100
  step_y <- 2.5/100
  eps    <- 1e-8/100
  
  ymin_plot <- (min.fin - pad_y) - eps
  ymax_plot <- (max.fin + pad_y) + eps
  y_breaks  <- seq(min.fin - pad_y, max.fin + pad_y, by = step_y)
  
  # horizontal grid
  grid_lines <- tibble(intercept = y_breaks)
  
  start_date <- as.Date(ts$Data[indici_elez[i]])
  end_date   <- as.Date(ts$Data[indici_elez[i+1]])
  
  # palette for each party
  cols <- switch(Part,
                 "PD"   = list(pt = "red",      line = "red4",       fill = "red4"),
                 "LEGA" = list(pt = "green",    line = "forestgreen",fill = "forestgreen"),
                 "M5S"  = list(pt = "#FFE800",  line = "gold",       fill = "gold"),
                 "FDI"  = list(pt = "blue",     line = "mediumblue", fill = "mediumblue"),
                 list(pt = "#80FFFF", line = "#00C3FF",    fill = "#00C3FF"))
  
  offset_days <- 10
 
  text_annotation1 <- tibble(
    Data = start_date + days(offset_days),
    Percentuale =  rep(Inf, 4),
    label = paste("Elezioni", a))
  
  text_annotation2 <- tibble(
    Data = end_date - days(offset_days),
    Percentuale =  rep(Inf, 4),
    label = paste("Elezioni", b))
  
  range_years <- as.numeric(difftime(end_date, start_date, units = "days")) / 365
  
  step <- as.character(dplyr::case_when(
    range_years <= 2 ~ "3 months",
    range_years <= 4 ~ "6 months",
    TRUE             ~ "1 year"))
  
  x_breaks <- seq(from = start_date, to = end_date, by = step)
  x_breaks <- x_breaks[x_breaks >= start_date & x_breaks <= end_date]
  
  
  p <- ts[(indici_elez[i]+1):(indici_elez[i+1]-1), ] %>%
    ggplot(aes(x = Data, y = Percentuale)) +
    geom_hline(data = grid_lines, aes(yintercept = intercept), linewidth = 0.25, color = "gray") +
    geom_point(data = first_point, aes(x = Data, y = Percentuale), color = "navy", size = 4) +
    geom_point(data = last_point,  aes(x = Data, y = Percentuale), color = "navy", size = 4) +
    geom_vline(xintercept = as.numeric(first_point$Data), color = "navy", linewidth = 0.5) +
    geom_vline(xintercept = as.numeric(last_point$Data),  color = "navy", linewidth = 0.5) +
    geom_point(color = cols$pt, alpha = 0.5, size = 3) +
    geom_text(data = text_annotation1, mapping = aes(x = Data, y = Percentuale, label = label), color = "navy", hjust = 0, vjust = 3, size = 4.7, fontface = "bold", inherit.aes = FALSE) +
    geom_text(data = text_annotation2, mapping = aes(x = Data, y = Percentuale, label = label), color = "navy", hjust = 1, vjust = 3, size = 4.7, fontface = "bold", inherit.aes = FALSE) +
    xlab("Data") +
    ylab("Intenzioni di Voto %") +
    scale_y_continuous(labels = scales::percent, breaks = y_breaks, expand = c(0, 0)) +
    scale_x_date(breaks = x_breaks, date_labels = "%b %Y", expand = c(0, 0)) +
    coord_cartesian(ylim = c(ymin_plot, ymax_plot), xlim = c(start_date %m-% months(1), end_date %m+% months(1)), clip = "off") +
    theme_light() +
    theme(plot.margin = margin(10, 40, 3, 3),
          text = element_text(size = 22),
          axis.text = element_text(size = 16),
          axis.line = element_line(linewidth = 0.25),
          axis.line.y.right = element_line(linewidth = 0.25, color = "gray"),
          axis.ticks.x = element_line(linewidth = 0.25),
          axis.ticks.y = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_rect(color = "gray", linewidth = 0.25, fill = NA))
  
  if (isTRUE(confidence)) {
    p <- p +
      geom_ribbon(data = trend, aes(x = Data, ymin = lwr, ymax = upp), fill = cols$fill, alpha = 0.15, inherit.aes = FALSE) +
      geom_line(data = trend, aes(x = Data, y = Trend), col = cols$line, linewidth = 2, lineend = "round")
  } else {
    p <- p +
      geom_line(data = trend, aes(x = Data, y = Trend), col = cols$line, linewidth = 2, lineend = "round")
  }
  
  return(p)
}
