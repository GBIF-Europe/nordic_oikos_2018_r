# GBIF data access using R

## Session 4: Event core / sample-based data from GBIF

This session gives a brief introduction to what "event" data is, why it mathers, and how to access this datatype. 


Content of lesson:

1. [Brief introduction to event-core and sample based data](http://bit.ly/2nKNLu4)
2. [Download and data-wrangling](4_2_Event_data_download_and_wrangle.md) >>
[Rmd script](4_2_Event_data_download_and_wrangle.Rmd)
3. Usage example

Sample based data / Event data is a rather new datatype in GBIF and not all functionality for usage through the API are in place.  The expected learning outcome of this is to understand the consept behind the "event-type" data (a.ka. "sample based data""), how to find these data on GBIF, how to access them and give some basic ideas of de-normalization and data-wrangling needed to get the dataformats usable for analyses. Note: The full specter of information stored in event-core data are currently only retrivable from the data-publisher "end-points" (data publisher [IPT](https://www.gbif.org/ipt)), i.e. not through the GBIF API / portal. We hope that this will change in the near future. Hence, here we will show how to find relevant data, extract datasetIDs and download directly raw data from the IPT.

***

## Workshop training materials

* Use case 4_2, [Discover event data in GBIF and download DwC-archive from IPT](4_2_Event_data_download_and_wrangle.md) >> [Rmd script](4_2_Event_data_download_and_wrangle.Rmd)
* Use case 4_3, [Introduction to long-term line transect sampling survey targeting willow ptarmigan (*Lagopus lagopus*)](4_3_Use_case_Ptarmigan_LineTransect.md) >>
[Rmd script](4_3_Use_case_Ptarmigan_LineTransect.rmd)
* Use case 4_3, [Continued, long-term line transect sampling survey targeting willow ptarmigan (*Lagopus lagopus*)](4_3_Ptarmigan_Presentation.md) >> [Rmd script](4_3_Ptarmigan_Presentation.rmd)

***

## Excercises

* We will prepare some use cases with example data for the exercises.
* Students will also find example-data to work with from GBIF.org at:
* [https://www.gbif.org/dataset/search?type=SAMPLING_EVENT](https://www.gbif.org/dataset/search?type=SAMPLING_EVENT)


***

Navigate to [workshop home (Github)](https://github.com/GBIF-Europe/nordic_oikos_2018_r) or the [GitHub.io](https://gbif-europe.github.io/nordic_oikos_2018_r/) pages.

[Session 4 HTML version on GitHub.io here](https://gbif-europe.github.io/nordic_oikos_2018_r/s4_event_core/).

![](../demo_data/gbif-norway-full.png "GBIF-Norway-Banner")
