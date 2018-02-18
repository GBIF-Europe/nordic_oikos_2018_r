

## FOR WINDOWS USERS -TRY THIS; 

#tmp <- tempfile() # create temporary file for download
download.file(url=paste("http://api.gbif.org/v1/occurrence/download/request/",
                        download_key[1], sep=""),
              destfile="tmp.zip",
              quiet=TRUE, mode="wb")

##  SHOULD WORK - AND HELP YOU DOWNLOAD THE ZIP-FILE



### THISSHOULD HELP YOU UNZIP THE FILE; 

# Get a list of the files within the archive by using "list=TRUE" in the unzip function.
archive_files <- unzip("tmp.zip", files = "NULL", list = T) 

# Get the occurrence.txt file in as a dataframe (using import from rio)
occurrence <- import(unzip("tmp.zip",
                           files="occurrence.txt"),header=T,sep="\t")