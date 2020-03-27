library(ggplot2)
library(lubridate)
library(reshape2)
source("plotit.R")

# get the latest data
source_data <- read.csv("https://covidtracking.com/api/us/daily.csv", stringsAsFactors=F)
# trim away some data (keep date, positive, negative)
keepers <- c("date", "positive", "negative")
us <- source_data[,(names(source_data) %in% keepers)]

# prep the data for a stacked barplot
# reshape the data: two rows per date, one for negative, one for positive
us <- melt(us, id.vars="date")
names(us) <- c("date", "result", "count")
us$date <- ymd(us$date)

p2 <- plotit(us, "US results")

png(filename="images/us_test_results.png", width=1264, height=673)
print(p2)
dev.off()
