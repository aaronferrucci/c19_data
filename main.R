library(ggplot2)
library(lubridate)

# get the latest data
states <- read.csv("https://covidtracking.com/api/states.csv", stringsAsFactors=F)
states[is.na(states$negative),]$negative <- 0
states$total <- states$positive + states$negative
states$date <- as.Date(states$checkTimeEt, tz="EST", format="%m/%d")
states$rate <- states$positive / states$total
# if the rate is NA, it came from 0/0, uh... drop that data (formerly I tried to
# color the x-axis label in red for such data, but this is probably just chart noise)
states <- states[!is.na(states$rate),]

p <- ggplot(states, aes(x=state, y=rate)) +
  ggtitle(sprintf("testing rate [p/(n+p)], ~%s", states$date[1])) +
  xlab("state/territory") + 
  geom_bar(stat="identity") +
  theme(axis.text.x=element_text(angle=90, vjust=0.5))
png(filename="images/rate.png", width=1264, height=673)
print(p)
dev.off()

# order matters: it sets the ordering of the 'result' factor, which in turn affects the plot coloring.
# positive first, so it ends up reddish.
states_posneg <- rbind(
  data.frame(state=states$state, result="positive", value=states$positive),
  data.frame(state=states$state, result="negative", value=states$negative)
)
states_posneg <- states_posneg[order(states_posneg$state),]

# stacked barplot of positive, negative counts
p2 <- ggplot(states_posneg, aes(x=state, y=value, fill=result)) +
  ggtitle(sprintf("results by state, ~%s", states$date[1])) +
  xlab("state/territory") +
  ylab("total tested") +
  geom_bar(position="stack", stat="identity") +
  theme(axis.text.x=element_text(angle=90, vjust=0.5))
png(filename="images/plot2.png", width=1264, height=673)
print(p2)
dev.off()

# percentage stacked barplot
p3 <- ggplot(states_posneg, aes(x=state, y=value, fill=result)) +
  ggtitle(sprintf("%% results by state, ~%s", states$date[1])) +
  xlab("state/territory") + 
  ylab("total tested") +
  geom_bar(position="fill", stat="identity") +
  theme(axis.text.x=element_text(angle=90, vjust=0.5))
png(filename="images/plot3.png", width=1264, height=673)
print(p3)
dev.off()
