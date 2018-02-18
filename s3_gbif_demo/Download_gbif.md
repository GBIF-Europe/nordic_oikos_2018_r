---
title: "Asyncronous download demo"
author: "Anders Gravbrøt Finstad"
date: "2018-02-08"
output:
  html_document:
    keep_md: true
    toc: true
    toc_depth: 3
---
## Introduction
GBIF provides two ways to get occurrence data: through the [/occurrence/search route or via the /occurrence/download route](https://www.gbif.org/developer/occurrence) of the GBIF API. The former is wrapped in the rgbif::occ_search() / rgbif::occ_data() functions, the latter in the rgbif::occ_download*() functions. The use of the /occurrence/download route and the occ_download() has several advantages. The most prominent are: 

* You are not restricted to a hard limit of 200 000 records
* You get a citation of your downloaded data that can/must be used when citing your data usage in e.g. a scientific publication or thesis. 
* It enables GBIF to track and publish data usage (number of downloads and publications - the link between your user account and data downloads are private). Needless to say, motivating and supporting data publishers should be a strong priority and long-term advantage for you as a data user. 

Due to the latter, **you should always use asyncronous downloads when fetching data for use in publications**, at least when your analyses are based upon data from parts of multiple datasets. See the [rgbif citation guide](https://www.gbif.org/tool/81747/rgbif) for info on how to cite results from the rgbif occ_search function, this will become very awkward if your data are collated from a large number of datasets.  Your specific download-request will be assigned a DOI which will resolve to the exact same representation of the data as used creating a citable, reproducible workflow for your analyses. GBIF will keep the data for this DOI for a prolonged time, "forever" if this DOI appears in a publication. By using the assigned DOIs included with your citations, you also vastly improve GBIF’s ability to [track the use of data](https://www.gbif.org/literature-tracking). It also provides the mechanism for connecting published uses of the data back to each source record of data. In addition to acknowledging data publishers, the practice of using DOI citations rewards them by reinforcing the value of sharing open data to the publisher’s stakeholders and .

In the following we go through the procedure of asynchronous download using the rgbif package step by step: 

1. load required packages
2. Register your GBIF user information (username, email and password) to your R session
3. Perform a simple search for getting example data, including find species of interest, construct query and finally request a download key from GBIF
4) Download data
5) Unzip and create a data.frame 

**[See also the rgbif download vignett](https://github.com/ropensci/rgbif/blob/master/vignettes/downloads.Rmd)**

## Load packages


```r
library(rgbif)
library(dplyr) # for data-wrangling
library(wicket) # check WKT strings
```

## Set user_name, e-mail, and pswd as global options first
It is necessary to register as a GIBF user to create a download request (see https://www.gbif.org/developer/occurrence#download). You can create your user for free at the [GBIF website](https://www.gbif.org). 

* Register your own account at gbif.org. While you can use third party authentication through e.g. your github or facebook account when loggin into the GBIF website, this don't seem to work with the API/rgbif. 

You have three options for passing your user credentials (user, pwd, and email parameters) for autentication along with and occurrence download request, see [occ_download documentation](https://www.rdocumentation.org/packages/rgbif/versions/0.9.9/topics/occ_download):
 

1. Set them in your .Rprofile file with the names gbif_user, gbif_pwd, and gbif_email
2. Simply pass strings to each of the parameters in the function call 
3. Set them in your .Renviron/.bash_profile (or similar) file with the names GBIF_USER, GBIF_PWD, and GBIF_EMAIL

Here, we for convenience put it in global options of your R session. Try to awoid hard-code passwords into scripts (always a bad idea). You only need to do this once per R session. The below chunk requires that you run your script through R-studio and will create an pop-up window for you to enter credentials into. 


```r
options(gbif_user=rstudioapi::askForPassword("my gbif username"))
options(gbif_email=rstudioapi::askForPassword("my registred gbif e-mail"))
options(gbif_pwd=rstudioapi::askForPassword("my gbif password"))
```



## Search, and request download key
Here we request a download key by sending an API call to GBIF using the occ_download function in rgbif. The download key will later be used to download the data

first find a species key using the name_suggest function and create a polygon for spatial filtering (for convenience, we do this step outside the request for download key). Secondly, we create the query and request the download key.

Note that there may be some time-delay before GBIF are able to handle your request depending on the size of your data. Remember that GBIF will only handle a maximum of 3 download request per user simultaneously. You will receive a e-mail with confirmation when your download request is processed or find an overview of all your requested and finalized downloads at https://www.gbif.org/user/download. 


```r
# Find a taxonkey - get list of gbif keys to filter download
key <- name_suggest(q='Esox lucius', rank='species')$key[1] 

# Crate spatial filter 
my_wkt <- "POLYGON((10.32989501953125 63.26787016946243, 10.32989501953125 63.455051146616825, 10.8819580078125 63.455051146616825, 10.8819580078125 63.26787016946243, 10.32989501953125 63.26787016946243))" 
#wicket::validate_wkt(my_wkt)
geom_param <- paste("geometry", "within", my_wkt)


# Send download request
 
 download_key <- occ_download(
    'taxonKey = 2346633',
    'hasCoordinate = TRUE',
    geom_param,
    type = "and"
  ) %>% 
   occ_download_meta
```

The download request will among other things give you link to the data download and a a [citable DOI for the download](https://www.gbif.org/citation-guidelines)

* http://api.gbif.org/v1/occurrence/download/request/0007083-180131172636756.zip
* 10.15468/dl.pfrirl

## Download data 
There will take some time before you download link is ready (seconds, minutes, hours depending on the size of your download request) you can either wait for you confirmation e-mail, or just try by simply pasting the download key into an URL string. If you want to rather just run your scrips and have a cup of coffee before your workflow finalizes you may need something slightly more sophisticated. This also holds if you want to set up a workflow that runs automatically e.g. as a nightly cron-job or use it in a rmarkdown document (like this one). Below we therefore give a short but inelegant demo for how to put the download into a time-delay function. 

The current script is set up to store the downloaded .zip to a temporary file. If you work with large datasets you probably want to store this version of the data on disk for re-use in later sessions.  

### 1. Direct download 


```r
download.file(url=paste("http://api.gbif.org/v1/occurrence/download/request/",
                        download_key[1],sep=""),
              destfile="tmp.zip",
              quiet=TRUE, mode="wb")
```


### 2. Coffebreak version
Here, we use a home-brewed "quick-and-dirty" function that tries, with given time intervall, to download data generated by the download key as objec given by "occ_download" function of the "rgbif" library. The input is the download_key, n_try (number of times the function should keep trying before giving up, Sys.sleep_duration (Time interval between each try) and the destfile_name (name and path to the destination file of the download). NB! Windows users may need to modify this chunck also (see above).


```r
# define function
download_GBIF_API <- function(download_key,n_try,Sys.sleep_duration,destfile_name){
  start_time <- Sys.time()
  n_try_count <- 1
  
  download_url <- paste("http://api.gbif.org/v1/occurrence/download/request/",
                        download_key[1],sep="")
  
  try_download <- try(download.file(url=download_url,destfile=destfile_name,
                                    quiet=TRUE, mode="wb"),silent = TRUE)
  
  while (inherits(try_download, "try-error") & n_try_count < n_try) {   
    Sys.sleep(Sys.sleep_duration)
    n_try_count <- n_try_count+1
    try_download <- try(download.file(url=download_url,destfile=destfile_name,
                      quiet=TRUE),silent = TRUE)
    print(paste("trying... Download link not ready. Time elapsed (min):",
                round(as.numeric(paste(difftime(Sys.time(),start_time, units = "mins"))),2)))
  }
}


# call function
download_GBIF_API(download_key=download_key,destfile_name="tmp.zip",n_try=5,Sys.sleep_duration=30)
```

```
## [1] "trying... Download link not ready. Time elapsed (min): 0.51"
## [1] "trying... Download link not ready. Time elapsed (min): 1.01"
```


## Open the data and extract into data.frame 
The download gives us back a package with data and metadata bundled together in a .zip file ([a Darwin Core Archive](https://en.wikipedia.org/wiki/Darwin_Core_Archive)). This includes citations of the original datasets that the occurrence download is a composite of (citations.txt), the licenses (rights.txt), the metadata file in .xlm format describing the structure of the .zip package (if you are specially interested), the metadata of the individual datasets from which the downloaded data originates (dataset/{datasetUUID}.xlm) as well as the data in both gbif interpreted form (occurrence.txt) and the raw data as provided by the user (verbatim.txt). The below chunck of code unzips and prints the files in the downloaded zipfile. 


```r
# Get a list of the files within the archive by using "list=TRUE" in the unzip function.
archive_files <- unzip("tmp.zip", files = "NULL", list = T) 
archive_files$Name
```

```
##  [1] "occurrence.txt"                                  
##  [2] "verbatim.txt"                                    
##  [3] "multimedia.txt"                                  
##  [4] "citations.txt"                                   
##  [5] "dataset/819b724f-d32a-48ac-a62a-9a3425b9b0a0.xml"
##  [6] "dataset/492d63a8-4978-4bc7-acd8-7d0e3ac0e744.xml"
##  [7] "dataset/a639542a-654a-427b-9cf1-bde1953bbb52.xml"
##  [8] "dataset/b124e1e0-4755-430f-9eab-894f25a9b59c.xml"
##  [9] "rights.txt"                                      
## [10] "metadata.xml"                                    
## [11] "meta.xml"
```

It is usually the interpreted data you want to use (found in the file occurrence.txt). 


```r
occurrence <- read.table(unzip("tmp.zip",files="occurrence.txt"),header=T,sep="\t")
```

## Cite your data! 
Finally but not at least, remember to cite your data properly:


```r
paste0("GBIF Occurrence Download https://doi.org/", download_key[2], " accessed via GBIF.org on", Sys.Date())
```

```
## [1] "GBIF Occurrence Download https://doi.org/10.15468/dl.pfrirl accessed via GBIF.org on2018-02-18"
```

## Exersize 
Try to expand the download_key to something more interesting and try to putting in more complex predicatives (i.e. search parameters). See [occ_download function documentation](https://www.rdocumentation.org/packages/rgbif/versions/0.9.9/topics/occ_download) for example and the [GBIF API description](https://www.gbif.org/developer/occurrence#predicates) for description of download predicatives (query expression to retrieve occurrence record downloads).


