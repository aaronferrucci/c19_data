library(lubridate)
library(ggplot2)
library(dplyr)

source("plotit.R")
source("googledocs_utils.R")
county_plot <- function(counties, county_name, type, posneg) {
  county <- counties[counties$county %in% county_name,]
  title <- paste0(county_name, " ", type, " results")
  if (posneg) {
    p <- plotit(county, title)
  } else {
    p <- plot_p(county, title)
  }
  return(p)  
}

plot_a_county <- function(counties, county_name, type, posneg=T) {
  p <- county_plot(counties, county_name, type, posneg)
  filename <- paste0("images/", gsub(" ", "_", county_name, fixed=T), "_", type, "_test_results.png")
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

space_to_underscore <- function(str) {
  underscored <- gsub(" ", "_", str)
  return(underscored)
}


csv_filename <- function(county_name) {
  filename <- paste0("csv/", space_to_underscore(county_name), ".csv")
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

# "santa cruz smooth" is in a non-stacked format - that made interpolation easier, but it's non-standard.
# read and convert it here.
read_smooth <- function(county_name, csv=F) {
  library(reshape2)
  if (csv) {
    county <- read.table(csv_filename(county_name), header=T, sep=",", skip=3)
  } else {
    county <- read_googledocs_county(county_name)
    # county is a "tibble", convert to data.frame
    county <- as.data.frame(county)
    county$county <- as.factor(county$county)
  }

  keepers <- c("date", "county", "positive", "negative")
  county <- county[keepers]
  county$date <- as.Date(county$date)
  county <- melt(county, id.vars=c("date", "county"))
  names(county) <- c("date", "county", "result", "count")
  if (levels(county$result)[1] == "negative") {
    county$result <- factor(county$result, levels(county$result)[c(2:1)])
  }
  return(county)
}

read_p_county <- function(county_name, csv=F) {
  county <- read_county(county_name, csv)
  county <- county[county$result == "positive",]
  return(county)
}

read_county <- function(county_name, csv=T) {
  if (csv) {
    county <- read.table(csv_filename(county_name), header=T, sep=",", skip=3)
  } else {
    county <- read_googledocs_county(county_name)
    # county is a "tibble", convert to data.frame
    county <- as.data.frame(county)
    county$county <- as.factor(county$county)
    county$result <- as.factor(county$result)
  }

  # some county csvs have additional columns (say, cumulative counts)
  # only retain the columns we need, to allow merging
  keepers <- c("date", "county", "result", "count")
  county <- county[keepers]

  county$date <- as.Date(county$date)

  # Sometimes the data comes with NA in the max dates. Trim that off.
  # Seems arbitrary to just trim up to exactly twice, but let's try it for now.
  for (i in 1:2) {
    if (all(is.na(county[county$date == max(county$date), "count"]))) {
      county <- county[county$date < max(county$date),]
    }
  }

  # order the result factor... this may depend on alpha order, or on the way the data is constructed.
  # "positive" should be first in the level order to produce stacked barplots with positive at the bottom.
  if (levels(county$result)[1] == "negative") {
    county$result <- factor(county$result, levels(county$result)[c(2:1)])
  }
  return(county)
}

get_data <- function(county_names) {
  raw = NULL
  for (county_name in county_names) {
    county <- read_county(county_name, F)
    
    # only retain the columns we need - just a tidiness step
    keepers <- c("date", "county", "result", "count")
    county <- county[keepers]
    
    if (is.null(raw)) {
      raw <- county
    } else {
      raw <- rbind(raw, county)
    }
  }

  return(raw)
}

# Counties with data
county_names <- c("Contra Costa", "San Francisco", "San Mateo", "Santa Clara", "Santa Cruz")
# counties to plot
plot_county_names <- c("Contra Costa", "San Francisco", "San Mateo", "Santa Clara", "Santa Cruz")

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

# special case: "smoothed" santa cruz datacounty
county_name <- "Santa Cruz Smooth"
sc <- read_smooth(county_name)
smooth <- tweak_data(sc, cumulative=T)
plot_a_county(smooth, county_name, "cumulative")

smooth <- tweak_data(sc, cumulative=F)
plot_a_county(smooth, county_name, "daily")

# positive-only data - maybe interesting?
if (F) {
  raw <- read_p_county("Solano")
  counties <- tweak_data(raw, cumulative=T)
  p <- plot_a_county(counties, "Solano", "cumulative", F)
  counties <- tweak_data(raw, cumulative=F)
  p <- plot_a_county(counties, "Solano", "daily", F)
}