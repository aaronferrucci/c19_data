
library(ggplot2)
library(lubridate)
library(reshape2)
library(gridExtra)
library(grid)
library(lattice)
source("plotit.R")

state_plot <- function(states, statename) {
  state <- states[states$state %in% statename,]
  p <- plotit(state, paste0(statename, " results"))
  return(p)  
}

plot_a_state <- function(states, statename) {
  p <- state_plot(states, statename)

  png(filename=paste0("images/", statename, "_test_results.png"), width=1264, height=673)
  print(p)
  dev.off()
  return(p)
}

# print_for_readme(states_info$state)
print_for_readme <- function(statenames) {
  dir <- "https://github.com/aaronferrucci/c19_data/blob/master/images/"
  for (statename in statenames) {
    print(noquote(paste0('![alt text](', dir, statename, '_test_results.png "', statename, ' test results")')))
  }
}

# get the latest data
source_data <- read.csv("https://covidtracking.com/api/states/daily.csv", stringsAsFactors=F)
# trim away some data (keep date, positive, negative)
keepers <- c("date", "state", "positive", "negative")
states <- source_data[,(names(source_data) %in% keepers)]

states <- melt(states, id.vars=c("date", "state"))
names(states) <- c("date", "state", "result", "count")
states$date <- ymd(states$date)

state_names <- unique(states$state)
states_info <- data.frame(
  state=state_names,
  total=(states[states$date == today() & states$result == "positive", "count"] +
           states[states$date == today() & states$result == "negative", "count"])
)

# drop any state with total=NA
states_info <- states_info[!is.na(states_info$total),]
# sort by total
states_info <- states_info[order(-states_info$total),]

for (statename in states_info$state) {
  plot_a_state(states, statename)
}
