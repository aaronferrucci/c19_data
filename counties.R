library(lubridate)
library(ggplot2)

source("plotit.R")
county_plot <- function(counties, countyname) {
  county <- counties[counties$county %in% countyname,]
  p <- plotit(county, paste0(countyname, " results"))
  return(p)  
}

plot_a_county <- function(counties, countyname) {
  p <- county_plot(counties, countyname)
  
  png(filename=paste0("images/", countyname, "_test_results.png"), width=1264, height=673)
  print(p)
  dev.off()
  return(p)
}

raw <- read.csv("covid_test_data.csv")

raw$Santa.Clara..Tests <- ifelse(is.na(raw$Santa.Clara..Tests), 0, raw$Santa.Clara..Tests)
raw$Santa.Clara..Tests.1 <- ifelse(is.na(raw$Santa.Clara..Tests.1), 0, raw$Santa.Clara..Tests.1)

# some issues with the input data:
# column names are R-unfriendly, e.g. "Santa Clara +Tests", "Santa Clara -Tests"
# data is columnar, but I want row-wise
# plan: get the santa clara data into a usable format for plotting, then think about generalizing
# messy: relying on the mangled column names, e.g.
# "Santa Clara +Tests" became "Santa.Clara..Tests"
# "Santa Clara -Tests" became "Santa.Clara..Tests.1"
santa_clara_pos <- data.frame(
  date=as.Date(raw[,1]),
  county="Santa Clara",
  result="positive",
  count=raw$Santa.Clara..Tests
)
santa_clara_pos$count <- cumsum(santa_clara_pos$count)

santa_clara_neg <- data.frame(
  date=as.Date(raw[,1]),
  county="Santa Clara",
  result="negative",
  count=raw$Santa.Clara..Tests.1
)
santa_clara_neg$count <- cumsum(santa_clara_neg$count)

counties <- rbind(santa_clara_pos, santa_clara_neg)

p <- plot_a_county(counties, "Santa Clara")
