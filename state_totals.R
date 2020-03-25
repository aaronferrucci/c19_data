
library(ggplot2)
library(lubridate)
library(reshape2)
library(gridExtra)
library(grid)
library(lattice)

plotit <- function(us, title) {
  # separate dataframe for test rate, for graph text
  pos <- us[us$result == "positive", "count"]
  neg <- us[us$result == "negative", "count"]
  # if the earliest day is NA, set it to 0 (cleans it up for the loop below)
  neg[length(neg)] <- ifelse(is.na(neg[length(neg)]), 0, neg[length(neg)])

  # NY 3/11, 3/12 has NA for negative count. What to do? Use the previous day's value
  for (i in (length(neg)-1):1) {
    if (is.na(neg[i]))
      neg[i] <- neg[i + 1]
  }
  # assign the "fixed" data back
  us[us$result == "negative", "count"] <- neg
  
  rate <- data.frame(date=us[us$result=="positive",]$date, rate=pos / (pos + neg), total = pos + neg)
  # yeah, might be some 0/0 here, clean it up
  rate$rate <- ifelse(is.na(rate$rate), 0, rate$rate)

  p1 <- ggplot() +
    ggtitle(sprintf("%s, %s to %s", title, min(us$date), max(us$date))) +
    ylab("total tested") +
    geom_bar(data=us, mapping=aes(x=date, y=count, fill=result), position="stack", stat="identity") +
    theme(axis.text.x=element_text(angle=90, vjust=0.5)) +
    scale_x_date(date_breaks="1 days", date_labels="%b %d") +
    theme(legend.position=c(.15, .75))
  
  # against all good sense, use a 2nd y axis for positive test rate
  # calculate a scale factor for the 2nd y axis
  yscale <- max(rate$total) / max(rate$rate) / 2
  
  p2 <- p1 +
    geom_line(data=rate, mapping=aes(x=date, y=rate*yscale, group=1, color="test-positive rate")) +
    geom_point(data=rate, mapping=aes(x=date, y=rate*yscale, group=1, color="test-positive rate")) +
    scale_y_continuous(sec.axis=sec_axis(~./yscale, name="test-positive rate")) +
    scale_color_manual(NULL, values="black") +
    theme(
      legend.spacing=unit(-7, "lines"),
      legend.background=element_rect(fill="transparent"),
      legend.box.background=element_rect(fill="transparent", color=NA),
      legend.key=element_rect(fill="transparent"))

  return(p2)
}

state_plot <- function(states, statename) {
  state <- states[states$state %in% statename,]
  p <- plotit(state, paste0(statename, " results"))
  return(p)  
}

plot_a_state <- function(states, statename) {
  p <- state_plot(states, statename)
  print(p)

  png(filename=paste0(statename, "_test_results.png"), width=1264, height=673)
  print(p)
  dev.off()
  return(p)
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
# ps <- list()
# for (i in 1:4) {
#   ps[[i]] <- state_plot(states, states_info$state[i])
# }
# grid.arrange(ps[[1]], ps[[2]], ps[[3]], ps[[4]], ncol=1)
