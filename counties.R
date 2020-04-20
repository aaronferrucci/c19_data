library(lubridate)
library(ggplot2)
library(dplyr)

source("plotit.R")
county_plot <- function(counties, countyname, type) {
  county <- counties[counties$county %in% countyname,]
  p <- plotit(county, paste0(countyname, " ", type, " results"))
  return(p)  
}

plot_a_county <- function(counties, countyname, type) {
  p <- county_plot(counties, countyname, type)
  filename <- paste0("images/", gsub(" ", "_", countyname, fixed=T), "_", type, "_test_results.png")
  png(filename=filename, width=1264, height=673)
  print(p)
  dev.off()
  return(p)
}

tweak_data <- function(raw, cumulative=T) {
  counties <- raw
  counties$date <- as.Date(counties$date)
  counties$count <- ifelse(is.na(counties$count), 0, counties$count)
  
  if (cumulative) {
    for (county in levels(counties$county)) {
      for (result in levels(counties$result)) {
        counties[counties$county == county & counties$result == result, "count"] <-
          cumsum(counties[counties$county == county & counties$result == result, "count"])
      }
    }
  }
  return(counties)  
}

# these are the counties with enough data for plotting:
county_names <- c("San Francisco", "San Mateo", "Santa Clara")

raw <- read.csv("covid_test_data.csv")
# order the result factor... this may depend on alpha order, or on the way the data is constructed.
# "positive" should be first in the level order to produce stacked barplots with positive at the bottom.
if (levels(raw$result)[1] == "negative") {
  raw$result <- factor(raw$result, levels(raw$result)[c(2:1)])
}
counties <- tweak_data(raw, cumulative=T)
for (county_name in county_names) {
  p <- plot_a_county(counties, county_name, "cumulative")
}

counties <- tweak_data(raw, cumulative=F)
for (county_name in county_names) {
  p <- plot_a_county(counties, county_name, "daily")
}
