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

csv_filename <- function(county_name) {
  filename <- paste0("csv/", gsub(" ", "_", county_name), ".csv")
  return(filename)  
}

write_csv <- function(raw, county_name) {
  county <- raw[raw$county == county_name, ]
  # ascending by date
  county <- county[order(county$date),]

  filename <- csv_filename(county_name)
  
  # 3 blank lines at the top
  cat("\n\n\n", file=filename)
  # There's a warning for the append, but it seems to work.
  write.table(county, filename, append=T, sep=",", row.names=F)
}

update_legacy_data <- function(county_names) {
  raw <- read.table("covid_test_data.csv", header=T, sep=",", row.names=1)
  
  for (county_name in county_names) {
    write_csv(raw, county_name)
  }
}

get_data <- function(county_names) {
  raw = NULL
  for (county_name in county_names) {
    county <- read.table(csv_filename(county_name), header=T, sep=",", skip=3)
    
    # only retain the columns we need - just a tidiness step
    keepers <- c("date", "county", "result", "count")
    county <- county[keepers]
    
    if (is.null(raw)) {
      raw <- county
    } else {
      raw <- rbind(raw, county)
    }
  }

  # type conversions, factor ordering
  raw$date <- as.Date(raw$date)
  # order the result factor... this may depend on alpha order, or on the way the data is constructed.
  # "positive" should be first in the level order to produce stacked barplots with positive at the bottom.
  if (levels(raw$result)[1] == "negative") {
    raw$result <- factor(raw$result, levels(raw$result)[c(2:1)])
  }
  return(raw)
}

# Counties with data
county_names <- c("Contra Costa", "San Francisco", "San Mateo", "Santa Clara", "Santa Cruz")
# counties to plot
plot_county_names <- c("Contra Costa", "San Francisco", "San Mateo", "Santa Clara")

# update_legacy_data(county_names)

# reconstruct the "raw" data from per-county csv files
raw <- get_data(county_names)

# save the raw data as an intermediate checkpoint
write.table(raw, "csv/raw.csv", sep=",", row.names=F)

counties <- tweak_data(raw, cumulative=T)
for (county_name in plot_county_names) {
  p <- plot_a_county(counties, county_name, "cumulative")
}

counties <- tweak_data(raw, cumulative=F)
for (county_name in plot_county_names) {
  p <- plot_a_county(counties, county_name, "daily")
}
