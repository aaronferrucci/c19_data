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

get_data <- function(raw, county_names, cumulative=T) {
  
  # some issues with the input data:
  # column names are R-unfriendly, e.g. "Santa Clara +Tests", "Santa Clara -Tests"
  # data is columnar, but I want row-wise
  # plan: get the santa clara data into a usable format for plotting, then think about generalizing
  # messy: relying on the mangled column names, e.g.
  # "Santa Clara +Tests" became "Santa.Clara..Tests"
  # "Santa Clara -Tests" became "Santa.Clara..Tests.1"
  counties <- data.frame(
    date=as.Date(character()),
    county=character(),
    result=character(),
    count=integer(),
    stringsAsFactors=F
  )
  for (county in county_names) {
    colprefix <- gsub(" ", ".", county, fixed=T)
    
    # process positive test column
    poscol <- paste0(colprefix, "..Tests")
    
    date <- as.Date(raw[,1])
    count <- pull(raw, poscol)
    count <- ifelse(is.na(count), 0, count)
    
    pos <- data.frame(
      date=date,
      county=county,
      result="positive",
      count=count
    )
    if (cumulative) {
      pos$count <- cumsum(pos$count)
    }
  
    counties <- rbind(counties, pos)
    
    # process negative  test column
    negcol <- paste0(colprefix, "..Tests.1")
    count <- pull(raw, negcol)
    count <- ifelse(is.na(count), 0, count)
    
    neg <- data.frame(
      date=date,
      county=county,
      result="negative",
      count=count
    )
    if (cumulative) {
      neg$count <- cumsum(neg$count)
    }

    counties <- rbind(counties, neg)
  }
  return(counties)  
}

# these are the counties with enough data for plotting:
county_names <- c("San Francisco", "San Mateo", "Santa Clara")

raw <- read.csv("covid_test_data.csv")
counties <- get_data(raw, county_names, cumulative=T)
for (county_name in county_names) {
  p <- plot_a_county(counties, county_name, "cumulative")
}

counties <- get_data(raw, county_names, cumulative=F)
for (county_name in county_names) {
  p <- plot_a_county(counties, county_name, "daily")
}
