# in this example we want a function that can automate
# download of sampling event data given a public dataset key
# from GBIF.org and return the data with metadata and a
# suggested citation, we know we probably need these libs

library(jsonlite)
library(tidyverse)
library(stringr)
library(xml2)
library(rgbif)

# we try to refactor and break up into steps where we can
# use existing packages where possible and then we use functions 
# for the various steps that allows us in the end to create
# a single function that wraps the steps into one
# call like "request <- sampling_event_data(key = 'datasetkeyhere')"

# first use rgbif to get sampling event datasets from Norway
# pick keys for dataset titles containing "Lepidurus"

search <- 
  rgbif::dataset_search(query = "*", type = "SAMPLING_EVENT", 
    publishingCountry = "NO")

key <- 
  search$data %>% 
  filter(grepl("Lepidurus", datasetTitle)) %>%
  .$datasetKey

# we need to download sampling event DwcA files directly from IPTs
# so a fcn is needed to get dataset details incl IPT endpoint urls
# which is available from the GBIF APIs...
# this fcn will here be internal (not exported)
# if it is refactored to follow rgbif function style it could be
# added there provided appropriate tests etc... perhaps a PR?
# right now it provides a way to get doi and license info and the endpoints 
# we need, ie DWC_ARCHIVE and EML urls from IPT 

dataset_details <- function(key) {
  url <- paste0("http://api.gbif.org/v1/dataset/", key)
  hits <- jsonlite::fromJSON(url)
  overview <- as_tibble(hits[c(
    "doi", "title", "description", 
    "language", "license"
  )])
  endpoints <- as_tibble(hits$endpoints)
  return (list(overview = overview, endpoints = endpoints))
}

# from dataset details, we can find the URL for the DWC_ARCHIVE data
url_dwca <- 
  dataset_details(key)$endpoints %>%
  filter(type == "DWC_ARCHIVE") %>%
  .$url

# download and parse sample event data from DwcA-file
dl_dwca <- function(url) {
  
  dwca_file <- tempfile(fileext = ".zip")
  dwca_dir <- dirname(dwca_file)
  download.file(url, destfile = dwca_file, mode = "wb", quiet = TRUE)
  unzip(dwca_file, exdir = dwca_dir)
  
  event_file <- file.path(dwca_dir, "event.txt")
  occ_file <- file.path(dwca_dir, "occurrence.txt")
  mof_file <- file.path(dwca_dir, "measurementorfact.txt")
  
  occurrence_ext <- suppressMessages(readr::read_tsv(occ_file))
  
  event_core <- tibble()
  mof <- tibble()
  
  if (file.exists(event_file)) {
    event_core <- suppressMessages(readr::read_tsv(event_file))
  } else {
    warning("No event_core table found in ", url)
  }
  if (file.exists(mof_file)) {
    mof <- suppressMessages(readr::read_tsv(mof_file))
  } else {
    message("No 'measurement or facts' found in ", url)
  }
      
  res <- list(
    event_core = event_core %>% select(-id), 
    occurrence_ext = occurrence_ext %>% select(-id),
    measurementorfact = mof %>% rename(eventID = id)
  )
  
  return (res)
}

# quickly test with one IPT DWC_ARCHIVE url
dwca <- dl_dwca(url_dwca)

# from dataset details, find the IPT url for EML data
url_eml <- 
  dataset_details(key)$endpoints %>%
  filter(type == "EML") %>%
  .$url

# get EML at IPT and generate suitable citation
dl_eml <- function(url) {
  tmp <- tempfile()
  download.file(url = url, destfile = tmp, quiet = TRUE)
  meta <- read_xml(tmp) %>% as_list() 
  gbif_citation <- meta$additionalMetadata$metadata$gbif$citation[[1]] 
  citation <- gsub("GBIF.org", paste(url), gbif_citation)
  res <- list(
    eml = meta,
    citation = citation
  )
  return (res)
}

dl_eml(url_eml)

# combine and add the above to a function that could be exported
# this function needs proper documentation

#' Sampling Event Data Download from IPT
#' 
#' This function downloads DwC-A directly from the IPT. The GBIF API does not 
#' yet throw back empty events and potential hierarchical
#' structures which may be essential for inferring sampling effort. This is under
#' implementation at GBIF and we hope that this function will soon be redundant.  
#' 
#' @param key character string with sampling event dataset identifier from GBIF
#' @return a list with slots for metadata (`meta`), for the DwcA tables (`dwca`) and all the data from the various sampling event data tables joined into one data frame (`data`)
#' @examples 
#' \dontrun {
#' sed <- sampling_event_data("78360224-5493-45fd-a9a0-c336557f09c3")
#' } 
#' @import tidyverse
#' @export
#' 
sampling_event_data <- function(key) {
  
  url_dwca <- 
    dataset_details(key)$endpoints %>%
    filter(type == "DWC_ARCHIVE") %>%
    .$url
  
  dwca <- dl_dwca(url_dwca)
  
  url_eml <- 
    dataset_details(key)$endpoints %>%
    filter(type == "EML") %>%
    .$url
  
  eml <- dl_eml(url_eml)
  
  mof_wide <- 
    dwca$measurementorfact %>% 
    select(eventID, measurementValue, measurementType) %>%
    spread(key = measurementType, value = measurementValue)
  
  df <- 
    dwca$event_core %>%
    left_join(dwca$occurrence_ext, by = "eventID") %>%
    left_join(mof_wide, by = "eventID")
  
  res <- list(
    meta = eml,
    dwca = dwca,
    data = df
  )
  
  return (res)
}

# create tests for relevant use cases

sed <- sampling_event_data(key)

library(testthat)

expect_equal(
  sampling_event_data("78360224-5493-45fd-a9a0-c336557f09c3")$meta$citation,
  "Finstad A G, Hendrichsen D K, Nilsen E (2015): Lepidurus arcticus survey Northeast Greenland 2013. v1.8. NTNU University Museum. Dataset/Samplingevent. http://gbif.vm.ntnu.no/ipt/resource?r=lepidurus-arcticus-survey_northeast-greenland_2013&v=1.8"
)

expect_equal(
  nrow(sampling_event_data("78360224-5493-45fd-a9a0-c336557f09c3")$data),
  31
)

# use formatR on R code

# install.packages("formatR")
formatR::tidy_app()

# use lintr to prettify R code

# install.packages("lintr")
lintr::lint("s2_r_intro/sampling_event_data.R")
# see results in "Markers" pane
