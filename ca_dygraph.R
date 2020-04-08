library(xts)
library(dygraphs)
library(htmlwidgets)

# get the latest data
source_data <- read.csv("https://covidtracking.com/api/states/daily.csv", stringsAsFactors=F)

# trim to CA only
ca_only <- source_data[source_data$state == "CA",]

ca <- data.frame(
  date = as.Date(as.character(ca_only$date), "%Y%m%d"),
  positive = ca_only$positive,
  negative = ca_only$negative,
  deaths = ca_only$death,
  pending = ca_only$pending,
  hospitalized = ca_only$hospitalizedCurrently,
  inicu = ca_only$inIcuCurrently
)

x <- xts(ca[,-1], ca[,1])

p <- dygraph(x, main="foobar") %>%
  dyRangeSelector()