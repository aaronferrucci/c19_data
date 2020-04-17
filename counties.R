library(lubridate)
library(ggplot2)
library(dplyr)

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

# raw$Santa.Clara..Tests <- ifelse(is.na(raw$Santa.Clara..Tests), 0, raw$Santa.Clara..Tests)
# raw$Santa.Clara..Tests.1 <- ifelse(is.na(raw$Santa.Clara..Tests.1), 0, raw$Santa.Clara..Tests.1)

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

county <- "Santa Clara"
colprefix <- gsub(" ", ".", county, fixed=T)
poscol <- paste0(colprefix, "..Tests")
negcol <- paste0(colprefix, "..Tests.1")

date <- as.Date(raw[,1])
count <- pull(raw, poscol)
count <- ifelse(is.na(count), 0, count)

pos <- data.frame(
  date=date,
  county=county,
  result="positive",
  count=count
)
pos$count <- cumsum(pos$count)

count <- pull(raw, negcol)
count <- ifelse(is.na(count), 0, count)

neg <- data.frame(
  date=date,
  county=county,
  result="negative",
  count=count
)
neg$count <- cumsum(neg$count)

counties <- rbind(pos, neg)

p <- plot_a_county(counties, county)
