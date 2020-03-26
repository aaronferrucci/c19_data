library(ggplot2)
library(lubridate)
library(reshape2)

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

# separate dataframe for test rate, for graph text
pos <- us[us$result == "positive", "count"]
neg <- us[us$result == "negative", "count"]

rate <- data.frame(date=us[us$result=="positive",]$date, rate=pos / (pos + neg), total = pos + neg)

p1 <- ggplot() +
  ggtitle(sprintf("US results, %s to %s", min(us$date), max(us$date))) +
  ylab("total tested") +
  geom_bar(data=us, mapping=aes(x=date, y=count, fill=result), position="stack", stat="identity") +
  theme(axis.text.x=element_text(angle=90, vjust=0.5)) +
  scale_x_date(date_breaks="1 days", date_labels="%b %d") +
  theme(legend.position=c(.15, .85))

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
png(filename="images/us_test_results.png", width=1264, height=673)
print(p2)
dev.off()
print(p2)
