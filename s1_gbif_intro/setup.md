Workshop intro and some R setup examples/notes
================
Dag Endresen (GBIF.no) <https://orcid.org/0000-0002-2352-5497>
February 3, 2018

Nordic Oikos 2018 - R workshop
==============================

Scientific reuse of openly published biodiversity information: Programmatic access to and analysis of primary biodiversity information using R. Nordic Oikos 2018, pre-conference R workshop. Further information [here](http://www.gbif.no/events/2018/Nordic-Oikos-2018-R-workshop.html).

-   Sunday 18 Feb 2018, 10:00 - 17:00
-   Monday 19 Feb 2018, 09:00 - 16:00

**Venue**: Auditorium [DU2-150](https://use.mazemap.com/#v=1&zlevel=-2&left=10.4044354&right=10.4080592&top=63.4160961&bottom=63.4145612&campusid=1&campuses=ntnu&sharepoitype=identifier&sharepoi=360-DU2-150), NTNU Gloshaugen campus, Norwegian University of Science and Technology, Hogskoleringen 5, NO-7491 Trondheim, Norway (latitude 63.415275, longitude 10.406295).

### Set working directory, here: to the same directory as the RMD-script

``` r
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) ## does not work inside Rmd (?)
# however, at least knitr seems to assume working directory same as the script anyway
getwd() ## will display the working directory
```

    ## [1] "/Users/dag/workspace/gitHub/nordic_oikos_2018_r/R/s1_gbif_intro"

### Create a folder for demo data

``` r
#dir.create(file.path("./demo_data")) ## create a folder for demo files (inside working directory)
#dir.create(file.path("../demo_data")) ## create a folder for demo files (next to working directory)
#dir.create(file.path("..", "demo_data")) # ?? will work accross OS?
```

### Some useful R-packages to install, that we will use during the workshop

``` r
# It is possible to install R-packages from the script

#install.packages("rmarkdown")
#install.packages("rgbif")
#install.packages("maps")
#install.packages("mapproj")
#install.packages(mapdata)
#install.packages("raster")
```

### Load R-packages

``` r
# Use functions library() or require() to load the R-packages you need

#require(rgbif) # r-package for accessing GBIF
#require(maps)
#require(mapproj)
#require(mapdata)
#require(maptools) # mapping tools for spatial objects
#require(rgdal) # provides the Geospatial Data Abstraction Library
#require(raster) # spatial raster data management
```

### Clear workspace (be careful)

``` r
# Large arrays and dataframes can consume huge parts of your working memory,
# and you probably want to remove some of them from memory when they are not needed anymore.

#rm(list = ls()) # Be careful, this line cleans the entire R workspace
#rm(sp) # Probably better to remove large arrays and dataframes individually
```

This script uses [R Markdown](http://rmarkdown.rstudio.com/)
