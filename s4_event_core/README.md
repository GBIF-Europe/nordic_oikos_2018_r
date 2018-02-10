# Nordic Oikos 2018 -- GBIF data with R

Scientific reuse of openly published biodiversity information: Programmatic access to and analysis of primary biodiversity information using R. Nordic Oikos 2018, pre-conference R workshop, 18th and 19th February 2018 in Trondheim, Norway.

## Session 4: Event core / sample-based data from GBIF

This session gives a brief introduction to what "event" data is, why it mathers, and how to access this datatype. 

Content of lesson:

1. [Brief introduction to event-core and sample based data](http://bit.ly/2nKNLu4)
2. Download and data-wrangling 
3. Usage example

Sample based data / Event data is a rather new datatype in GBIF and not all functionality for usage through the API are in place.  The expected learning outcome of this is to understand the consept behind the "event-type" data (a.ka. "sample based data""), how to find these data on GBIF, how to access them and give some basic ideas of de-normalization and data-wrangling needed to get the dataformats usable for analyses. Note: The full specter of information stored in event-core data are currently only retrivable from the data-publisher "end-points" (data publisher [IPT](https://www.gbif.org/ipt)), i.e. not through the GBIF API / portal. We hope that this will change in the near future. Hence, here we will show how to find relevant data, extract datasetIDs and download directly raw data from the IPT.
