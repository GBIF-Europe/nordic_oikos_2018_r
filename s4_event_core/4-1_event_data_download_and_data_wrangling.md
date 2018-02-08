4-2\_Event data download and data-wrangling
================
Anders Gravbrøt Finstad
February 8, 2018

Discover event data in GBIF
---------------------------

Download dwc-a from IPT
-----------------------

Some essential event-type data terms are currently not searchable through the GBIF API, you can use metadata search through the "datasets" call of rgbif, or search through the GBIF portal and locate the UUID of the dataset. Here, we download the data set as a DwC-A directly from the IPT using the following workflow.

1.  Use the [jsonlite package](https://cran.r-project.org/web/packages/jsonlite/vignettes/json-apis.html) to get the endpoint for the raw dwc-a representation of the dataset at the IPT installation. This takes the raw API call "<http://api.gbif.org/v1/dataset/'dataset> UUID'/endpoint", downloads information as JSON. This is adress is can also be found by scrolling down on the dataset homepage to the [data description section](https://www.gbif.org/dataset/78360224-5493-45fd-a9a0-c336557f09c3#dataDescription)
2.  Then we extract the DWC-A endpoint url, and use the [curl package](https://cran.r-project.org/web/packages/curl/vignettes/intro.html) to download this to a temporary file
3.  Finally we extract the event and occurrence table and join the table with the left\_join command from the [dplyr package](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html). Note that we here remove id field id "%&gt;% select(-id)" from the occurrence and event table respectively to awoid duplicated column names (the id field represent the eventID and occurrenceID respectively)

``` r
library(RJSONIO)
library(curl)
library(dplyr)

dataset <- RJSONIO::fromJSON("http://api.gbif.org/v1/dataset/78360224-5493-45fd-a9a0-c336557f09c3/endpoint")
endpoint_url <- dataset[[1]]$url

# Download from dwc-a from IPT
tmp <- tempfile() # create temporary file for download
curl_download(endpoint_url, tmp)
archive_files <- unzip(tmp, files = "NULL", list = T) 
unzip(tmp, list = F)

# extract occurrence and event tables from dwc-a and join

occurrence <- occurrence_temp <- read.table("occurrence.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% select(-id)
event <- occurrence_temp <- read.table("event.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% select(-id)

df <- left_join(event,occurrence,by="eventID")
head(df)
```

    ##                                                          eventID
    ## 1 http://purl.org/nhmuio/id/95d868d6-1c6b-4686-a45e-7a57da19459d
    ## 2 http://purl.org/nhmuio/id/d7199c68-1985-494e-8ad4-010d3328e779
    ## 3 http://purl.org/nhmuio/id/d2c7ba64-c1e9-41bc-b2da-cda0e584b697
    ## 4 http://purl.org/nhmuio/id/01421a15-d3a3-40f0-8577-d025a01fb8dc
    ## 5 http://purl.org/nhmuio/id/83888ae2-41dd-4656-91fe-bead0c7474f4
    ## 6 http://purl.org/nhmuio/id/5cdfec49-6db8-4b63-9970-469adb7abdf4
    ##       samplingProtocol samplingEffort year month day habitat
    ## 1 sweep net (z-sweeps)    16 z-sweeps 2013     7  25 benthic
    ## 2 sweep net (z-sweeps)    16 z-sweeps 2013     7  25 benthic
    ## 3 sweep net (z-sweeps)    16 z-sweeps 2013     7  25 benthic
    ## 4 sweep net (z-sweeps)    16 z-sweeps 2013     7  25 benthic
    ## 5 sweep net (z-sweeps)    16 z-sweeps 2013     7  25 benthic
    ## 6 sweep net (z-sweeps)     8 z-sweeps 2013     8   6 benthic
    ##                                   fieldNumber
    ## 1 Lepidurus_dam:_1_periode:_2_Date:_2013-7-25
    ## 2 Lepidurus_dam:_2_periode:_2_Date:_2013-7-25
    ## 3 Lepidurus_dam:_3_periode:_2_Date:_2013-7-25
    ## 4 Lepidurus_dam:_4_periode:_2_Date:_2013-7-25
    ## 5 Lepidurus_dam:_5_periode:_2_Date:_2013-7-25
    ## 6  Lepidurus_dam:_6_periode:_4_Date:_2013-8-6
    ##                          eventRemarks                        locationID
    ## 1 eventTaxonomicRange:Notostraca spp. http://sws.geonames.org/10793774/
    ## 2 eventTaxonomicRange:Notostraca spp. http://sws.geonames.org/10793761/
    ## 3 eventTaxonomicRange:Notostraca spp. http://sws.geonames.org/10793755/
    ## 4 eventTaxonomicRange:Notostraca spp. http://sws.geonames.org/10793756/
    ## 5 eventTaxonomicRange:Notostraca spp. http://sws.geonames.org/10793773/
    ## 6 eventTaxonomicRange:Notostraca spp. http://sws.geonames.org/10793757/
    ##       waterBody   country countryCode verbatimElevation decimalLatitude
    ## 1         Dnb 4 Greenland          GL               110        74.32311
    ## 2        Dnb 10 Greenland          GL                46        74.30679
    ## 3         Dnb 8 Greenland          GL                51        74.31044
    ## 4         Dnb 7 Greenland          GL                53        74.31346
    ## 5 Finstaddammen Greenland          GL                50        74.31643
    ## 6         Dnb 6 Greenland          GL                54        74.31886
    ##   decimalLongitude geodeticDatum institutionCode collectionCode
    ## 1        -20.18444     EPSG:4326         NTNU-VM             NA
    ## 2        -20.19921     EPSG:4327         NTNU-VM             NA
    ## 3        -20.09449     EPSG:4328         NTNU-VM             NA
    ## 4        -20.11344     EPSG:4329         NTNU-VM             NA
    ## 5        -20.09724     EPSG:4330         NTNU-VM             NA
    ## 6        -20.10781     EPSG:4331         NTNU-VM             NA
    ##       basisOfRecord
    ## 1  HumanObservation
    ## 2 PreservedSpecimen
    ## 3  HumanObservation
    ## 4  HumanObservation
    ## 5  HumanObservation
    ## 6 PreservedSpecimen
    ##                                                     occurrenceID
    ## 1 http://purl.org/nhmuio/id/1237155f-889c-424f-8a5d-d1c2f34e965f
    ## 2 http://purl.org/nhmuio/id/a6af54b0-c6ba-4114-bce3-0fa24bd68aed
    ## 3 http://purl.org/nhmuio/id/c0c48ef6-b630-41b3-8eb6-b3e4fe8f9805
    ## 4 http://purl.org/nhmuio/id/c7554cb1-0013-4274-b98c-99ea5d8a653f
    ## 5 http://purl.org/nhmuio/id/27dbefc1-d07d-42af-8ce4-82f57489bada
    ## 6 http://purl.org/nhmuio/id/af00e254-fb6a-405e-8535-f0e7b8f88094
    ##   catalogNumber occurrenceRemarks
    ## 1            NA                  
    ## 2            NA                  
    ## 3            NA                  
    ## 4            NA                  
    ## 5            NA                  
    ## 6            NA                  
    ##                                  recordNumber
    ## 1 Lepidurus_dam:_1_periode:_2_Date:_2013-7-25
    ## 2 Lepidurus_dam:_2_periode:_2_Date:_2013-7-25
    ## 3 Lepidurus_dam:_3_periode:_2_Date:_2013-7-25
    ## 4 Lepidurus_dam:_4_periode:_2_Date:_2013-7-25
    ## 5 Lepidurus_dam:_5_periode:_2_Date:_2013-7-25
    ## 6  Lepidurus_dam:_6_periode:_4_Date:_2013-8-6
    ##                                                            recordedBy
    ## 1 Anders Gravbrøt Finstad | Ditte Katrine Hendrichsen | Erlend Nilsen
    ## 2 Anders Gravbrøt Finstad | Ditte Katrine Hendrichsen | Erlend Nilsen
    ## 3 Anders Gravbrøt Finstad | Ditte Katrine Hendrichsen | Erlend Nilsen
    ## 4 Anders Gravbrøt Finstad | Ditte Katrine Hendrichsen | Erlend Nilsen
    ## 5 Anders Gravbrøt Finstad | Ditte Katrine Hendrichsen | Erlend Nilsen
    ## 6 Anders Gravbrøt Finstad | Ditte Katrine Hendrichsen | Erlend Nilsen
    ##   individualCount occurrenceStatus        preparations      identifiedBy
    ## 1               0           absent                                      
    ## 2               2          present whole animal (ETOH) Hanna-Kaisa Lakka
    ## 3               0           absent                                      
    ## 4               0           absent                                      
    ## 5               0           absent                                      
    ## 6               4          present whole animal (ETOH) Hanna-Kaisa Lakka
    ##                                     taxonID     scientificName  kingdom
    ## 1 http://data.artsdatabanken.no/Taxon/78394 Lepidurus arcticus Animalia
    ## 2 http://data.artsdatabanken.no/Taxon/78394 Lepidurus arcticus Animalia
    ## 3 http://data.artsdatabanken.no/Taxon/78394 Lepidurus arcticus Animalia
    ## 4 http://data.artsdatabanken.no/Taxon/78394 Lepidurus arcticus Animalia
    ## 5 http://data.artsdatabanken.no/Taxon/78394 Lepidurus arcticus Animalia
    ## 6 http://data.artsdatabanken.no/Taxon/78394 Lepidurus arcticus Animalia
    ##       phylum        class      order     family     genus
    ## 1 Arthropoda Branchiopoda Notostraca Triopsidae Lepidurus
    ## 2 Arthropoda Branchiopoda Notostraca Triopsidae Lepidurus
    ## 3 Arthropoda Branchiopoda Notostraca Triopsidae Lepidurus
    ## 4 Arthropoda Branchiopoda Notostraca Triopsidae Lepidurus
    ## 5 Arthropoda Branchiopoda Notostraca Triopsidae Lepidurus
    ## 6 Arthropoda Branchiopoda Notostraca Triopsidae Lepidurus
