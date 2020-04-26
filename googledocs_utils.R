library(googlesheets4)
library(googledrive)

googledocs_sheetname <- function(county_name) {
  sheetname <- gsub(" ", "_", county_name)
  return(sheetname)
}

# The base url for the 'CA County Data' sheet
googledocs_url <- "https://docs.google.com/spreadsheets/d/1knJJ79Kga4csIVbI00aPT57mM4SxJVX4zG3lcs947LQ/edit?ts=5e9f73e0#gid=0"

read_googledocs_county <- function(county_name) {
  county <- read_sheet(googledocs_url, skip=3, sheet=googledocs_sheetname(county_name))
  return(county)
}

