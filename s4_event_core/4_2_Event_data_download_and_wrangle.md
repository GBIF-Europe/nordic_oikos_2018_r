# Event data download and data-wrangling
Anders Gravbrøt Finstad, https://orcid.org/0000-0003-4529-6266  
February 8, 2018  

***

## Discover event data in GBIF
Event data are a new datatype for GBIF, and still not truly discover able through GBIF API searches and hence not in the rgbif package. Typical uses includes searching for specific sampling protocols in given areas. However, you can use the GBIF portal, or the API and rgbif function  metadata search through the "datasets" call of rgbif, or search through the GBIF portal and locate the UUID of the dataset. Event with only this rudimentary functionality in place, GBIF still provides some advantages over unstructured repositories for event type data. 

* Facilities for metadata search and discover ability 
* Data are available standardized formats reducing the need for tedious data-reshaping and cleaning in workflows
* You can automatize the whole procedure in a reproducible script

The most convenient way of discovering data is probably by searching through the [dataset search pages](https://www.gbif.org/dataset/search?q=) at the gbif.org portal.These pages are however built on top of the API, so you can reproduce that search in your script if you want. Quick example below.  


```r
# Quick and dirty example on free text search in metadata from the GBIF API
search_string <- "'sweep'"
dataset_search <- RJSONIO::fromJSON(paste0("http://api.gbif.org/v1/dataset?q=",
                                           search_string))
dataset_search$count
dataset_search$results[[1]]
```

***

## Download dwc-a from IPT

Some essential event-type data terms are currently not available through the GBIF API. For example, the GBIF API (and also the gbif portal, which in reality is built on top of this) does not yet throw back empty events and potential hierarchical structures which may be essential for inferring sampling effort. Here, we download the data set as a DwC-A directly from the IPT using the following workflow.This is however under implementation and we hope that the workaround described below in a short while will be redundant. 

### 1. Get endpoint URL (IPT version of the DwC-A)
Use the [jsonlite package](https://cran.r-project.org/web/packages/jsonlite/vignettes/json-apis.html) to get the endpoint for the raw DwC-a representation of the dataset at the IPT installation. This takes the raw API call "http://api.gbif.org/v1/dataset/'dataset UUID'/endpoint", downloads information as JSON. This is address is can also be found by scrolling down on the dataset homepage to the [data description section](https://www.gbif.org/dataset/78360224-5493-45fd-a9a0-c336557f09c3#dataDescription)


```r
library(RJSONIO)
# Resolve endpoint URL from datasetID using the GBIF API
datasetID <- "78360224-5493-45fd-a9a0-c336557f09c3"
dataset <- RJSONIO::fromJSON(paste0("http://api.gbif.org/v1/dataset/",datasetID,"/endpoint"))
endpoint_url <- dataset[[1]]$url # extracting URL from API call result
```

The endpoint URL will look like

* http://gbif.vm.ntnu.no/ipt/archive.do?r=lepidurus-arcticus-survey_northeast-greenland_2013

### 2. Download

We then extract the DWC-A endpoint URL  and download the DwC-A to a temporary file 


```r
# Download from dwc-a from IPT
tmp <- tempfile() # create temporary file for download
download.file(endpoint_url, tmp)
archive_files <- unzip(tmp, files = "NULL", list = T) 
unzip(tmp, list = F)
```

The DwC-A contains the following files where dataset metadata are in .xml format and the .txt files contains data. 

```r
paste(archive_files[,1])
```

```
## [1] "event.txt"             "measurementorfact.txt" "meta.xml"             
## [4] "eml.xml"               "occurrence.txt"
```

### 3. Extract and join event and occurrence

We extract the event and occurrence table and join the table with the left_join command from the [dplyr package](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html). Note that we here remove id field id "%>% select(-id)" from the occurrence and event table respectively to avoid duplicated column names (the id field represent the eventID and occurrenceID respectively)


```r
# Extract occurrence, event and measurmentandfacts tables from dwc-a and join
library(dplyr)
occurrence <- read.table("occurrence.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% select(-id) # id field duplicates occurrenceID
event <- read.table("event.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% select(-id) # id field duplicates eventID


# Joint occurrences to events
df <- left_join(event,occurrence,by="eventID")
```

# MeasurmentsOrFacts
We may have a [measurmentORFact](http://rs.tdwg.org/dwc/terms/#MeasurementOrFact) (MOF) table attached. This is a generic way of attaching no-dwc terms like measurements, traits etc. to the data ([description](https://tools.gbif.org/dwca-validator/extension.do?id=dwc:MeasurementOrFact)). This is inn a [long dataformat](https://sejdemyr.github.io/r-tutorials/basics/wide-and-long/). When attached to an event-core DwC-A this always has an ID corresponding to the eventID (core file). Likewise, when attached to an occurrence-core DwC-A the ID field corresponds to the occurrence core-table of the DWC-A. There are also a new type in use a type called extendedMeasurmentsOrFact (eMOF) which is able to hold measures linked to both event and occurrence tables ([description](http://www.iobis.org/manual/dataformat/)). Usage is otherwise more or less similar. 



```r
library(knitr)
measurementorfact <- read.table("measurementorfact.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% rename(eventID=id) # NOTE! id field in a measurmentandfact table linked to the event core is an eventID
```

The MOF (or eMOF) table have to be converted to a wide format before joined to the occurrence and event data. 


```r
# Create wide format from measurmentsandfacts
library(tidyr)
mof_wide <- measurementorfact %>% 
  select(eventID,measurementValue,measurementType) %>% 
  spread(key=measurementType, value=measurementValue)
```

Then join to event and occurrence data

```r
df <- left_join(df,mof_wide)
```


### Citation
Suggestive hack of default citation from dwc-a metadata to get the dataset DOI in the citation string.  


```r
library(xml2)
# 5. Suggested citation: Take the citation as from downloaded from GBIF website, replace "via GBIF.org" by endpoint url. 
datasetID <- "78360224-5493-45fd-a9a0-c336557f09c3"
tmp <- tempfile()
download.file(paste0("http://api.gbif.org/v1/dataset/",datasetID,"/document"),tmp) # get medatadata from gbif api
meta <- read_xml(tmp) %>% as_list() # create list from xml schema
gbif_citation <- meta$additionalMetadata$metadata$gbif$citation[[1]] # extract citation
citation <- gsub("GBIF.org", paste(endpoint_url), gbif_citation) # replace "gbif.org" with endpoint url
```

The citation string will then be

* Finstad A G, Hendrichsen D K, Nilsen E (2016). Lepidurus arcticus survey Northeast Greenland 2013. Version 1.7. NTNU University Museum. Sampling_event Dataset https://doi.org/10.15468/ancuku accessed via http://gbif.vm.ntnu.no/ipt/archive.do?r=lepidurus-arcticus-survey_northeast-greenland_2013 on 2018-02-16.

