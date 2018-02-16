![](../demo_data/NSO_2018_GBIF_NO.png "NSO 2018")


# Session 5: Linking environment layers to GBIF data
Access to and the linking of GBIF data to environmental raster and vector data is a frequently asked question from users of GBIF mediated species occurrence data.

* [WorldClim](http://worldclim.org/version2) global climate layers ([Fick and Hijmans, 2017](https://doi.org/10.1002/joc.5086)), ([Hijmans *et al.* 2005](https://doi.org/10.1002/joc.1276)).
* Bioclimatic variables ([Bioclim](http://www.worldclim.org/bioclim)) (Nix 1986; Busby 1991; [Booth 2014](http://doi.org/10.1111/ddi.12144)).
* R Spatial: [Guide to environmental data](http://www.rspatial.org/sdm/rst/4_sdm_envdata.html).


**Learning target**: Understanding basic spatial data manipulation and the basic properties of spatial data, including both raster data (gridded spatial data) and vector data (species occurrence point data, polygon data such as country borders, etc). Learning how to extract information from either raster data (eg. environment layers) and vector data for a list of species occurrences point data.



## Workshop training materials

* [Worldclim demonstration](worldclim.Rmd)


## Excercises

* Select a stydy area and a species (or species group).
* Download species occurrences from GBIF and environment layers from WorldClim using R.
* Extract climate data for the locations of your species occurrences.
* Plot selected environment layers and species occurrences together on a map.
* **BONUS**: Transform (and re-project) your spatial data (species occurrences and environment layers) to another coordinate reference system (eg. UTM zone 32N WGS84; [EPSG:32632](https://epsg.io/32632) and make a new map (in R).
* **EXTRA**: Perform a basic species distribution modelling study - [sdm guideline here](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf).


***

[Back to GitHub project home](https://github.com/GBIF-Europe/nordic_oikos_2018_r).
