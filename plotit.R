# common routine for plotting test results and positive test rate.
# dependent libraries aren't loaded - the expectation is that this
# file is sourced by client code, after library imports.
plotit <- function(data, title) {
  # separate dataframe for test rate, for graph text
  pos <- data[data$result == "positive", "count"]
  neg <- data[data$result == "negative", "count"]
  # if the earliest day is NA, set it to 0 (cleans it up for the loop below)
  neg[length(neg)] <- ifelse(is.na(neg[length(neg)]), 0, neg[length(neg)])

  # NY 3/11, 3/12 has NA for negative count. What to do? Use the previous day's value
  for (i in (length(neg)-1):1) {
    if (is.na(neg[i]))
      neg[i] <- neg[i + 1]
  }
  # assign the "fixed" data back
  data[data$result == "negative", "count"] <- neg
  
  rate <- data.frame(date=data[data$result=="positive",]$date, rate=pos / (pos + neg), total = pos + neg)
  # yeah, might be some 0/0 here, clean it up
  rate$rate <- ifelse(is.na(rate$rate), 0, rate$rate)

  p1 <- ggplot() +
    ggtitle(sprintf("%s, %s to %s", title, min(data$date), max(data$date))) +
    ylab("total tested") +
    geom_bar(data=data, mapping=aes(x=date, y=count, fill=result), position="stack", stat="identity") +
    theme(axis.text.x=element_text(angle=90, vjust=0.5)) +
    scale_x_date(date_breaks="1 days", date_labels="%b %d") +
    theme(legend.position=c(.15, .75))
  
  # against all good sense, use a 2nd y axis for positive test rate
  # calculate a scale factor for the 2nd y axis
  yscale <- max(rate$total)
  
  p2 <- p1 +
    geom_line(data=rate, mapping=aes(x=date, y=rate*yscale, group=1, color="test-positive rate (%)")) +
    geom_point(data=rate, mapping=aes(x=date, y=rate*yscale, group=1, color="test-positive rate (%)")) +
    scale_y_continuous(sec.axis=sec_axis(~./(yscale/100), name="test-positive rate (%)")) +
    scale_color_manual(NULL, values="black") +
    theme(
      legend.spacing=unit(-7, "lines"),
      legend.background=element_rect(fill="transparent"),
      legend.box.background=element_rect(fill="transparent", color=NA),
      legend.key=element_rect(fill="transparent"))

  return(p2)
}


