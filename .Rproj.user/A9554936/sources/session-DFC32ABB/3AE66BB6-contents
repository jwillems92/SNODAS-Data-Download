
# SCRIPT FOR DOWNLOADING, UNZIPPING, AND EXTRACTING DATA FROM SNODAS FILES

library(tidyverse)
library(snowdl)
library(archive)
library(R.utils)
library(lubridate)
library(SNODASR)
library(raster)
library(rgdal)
library(rgeos)
library(sf)

wd <- getwd()

### Create vector of dates to download SNODAS data for ### ----------------------

# Vector of all years for which to download data
yearsVec <- c(2003:2021)

# Create empty vector to hold the dates
datesVec <- character()
# Convert empty vector to class "Date" so the formatting is correct
class(datesVec) <- "Date"

# Loop through each year of interest & create dates from 10/01 to 05/15
for(index in yearsVec){
  
  tempVec <-  seq(as.Date(paste(index, "10", "01", sep = "-")),
                  as.Date(paste((index+1), "05", "15", sep = "-")),
                  by = "days")
  
  datesVec <- c(datesVec,tempVec)
}

testVec <- seq(as.Date("2003-12-30"), as.Date("2004-01-02"), by = "days")



### Downloading the raw SNODAS data ### -----------------------------------------

for(index in testVec){

  # Download SNODAS files for each date in vector 
  download_SNODAS(as.Date(index, origin = "1970-01-01"), 
                  out_dir = paste0(wd, "/TAR Files"),
                  overwrite = FALSE)
}



### Unzip each TAR file ### -----------------------------------------------------

# Get a list of all .tar files within the given folder
tarList <- list.files(path = paste0(wd, "/TAR Files"),
                      pattern = "*.tar",
                      recursive = TRUE,
                      full.names = F)

# Loop through each daily .tar file and unzip to a new folder
for(i in tarList){
  
  untar(tarfile = paste0(wd, "/TAR Files/", i),
        exdir = paste0(paste0(wd, "/Unzipped TAR Files/")))
  
}




### Separate variables of interest ### ------------------------------------------

# List all of the unzipped files 
unzippedList <- list.files(path = paste0(wd, "/Unzipped TAR Files"),
                           recursive = TRUE,
                           full.names = TRUE)

# Filter to only the files for the parameters of interest (1036 = snow depth, 1034 = SWE)
snowDepthList <- grep("1036tS",
                      unzippedList,
                      value = TRUE)

sweList <- grep("1034tS",
                unzippedList,
                value = TRUE)

# Create new individual folders for variables of interest (only run once)
 dir.create(paste0(wd, "/Individual Parameter Files"))
 dir.create(paste0(wd, "/Individual Parameter Files/Snow Depth"))
 dir.create(paste0(wd, "/Individual Parameter Files/SWE"))


# Move snow depth files to new folder
for(i in snowDepthList){

  # Copy files in index to newly created folder
  file.copy(from = i,
            to = paste0(wd, "/Individual Parameter Files/Snow Depth"))
}

# Move SWE files to new folder
for(i in sweList){
  
  file.copy(from = i,
            to = paste0(wd, "/Individual Parameter Files/SWE"))
}




### Unzip DAT files, convert to raster, crop raster ### -------------------------

# Vector of all parameter zipped files
sdList <- list.files(path = paste0(wd, "/Individual Parameter Files/Snow Depth"),
                     full.names = TRUE,
                     recursive = TRUE)
 
sweList <- list.files(path = paste0(wd, "/Individual Parameter Files/SWE"),
                      full.names = TRUE,
                      recursive = TRUE)

# Define boundary coords of BEF for cropping raster files
BEFextent <- matrix(c(-71.32784,44.02301,-71.24346,44.07679),
                    nrow=2)

# Create new folders to save cropped files in (only run once)
dir.create("Cropped Raster Files")
dir.create("Cropped Raster Files/Snow Depth")
dir.create("Cropped Raster Files/SWE")
 
# Loop through each file and unzip file, convert to raster, crop raster, & delete unwanted files
for(i in sdList){
  
  # Unzip the file & delete original zipped file
  unzipFile <- gunzip(filename = i,
                      overwrite = TRUE)
  
  # Convert DAT files to raster files
  read.SNODAS.masked(str_extract(unzipFile, pattern = "[^/]+$"),
                     # Pattern = everything before ?= string
                     str_extract(unzipFile, 
                                 pattern = ".+?(?=us_ssmv)"),
                     # Create new file
                     write_file = TRUE,
                     # Put file into correct folder
                     write_path = paste0(str_extract(unzipFile, 
                                                     pattern = ".+?(?=us_ssmv)"), "Raster Files/"),
                     # Save as raster (can change formats)
                     write_extension = "raster")
  
  # Crop full raster files to BEF extent
  crop(raster(paste0(gsub(".{7}$", "", 
                          paste0(str_extract(unzipFile, 
                                             pattern = ".+?(?=us_ssmv)"), 
                                 "Raster Files/",
                                 # Pattern = everything after last /
                                 str_extract(unzipFile, 
                                             pattern = "[^/]+$"))),
                     "001raster.grd")),
       BEFextent,
       filename = paste0("Cropped Raster Files/",
                         "Snow Depth/",
                         gsub(".{7}$", "", str_extract(unzipFile, 
                                                       pattern = "[^/]+$")),
                         "001.grd"))
  
  # Deletes all files in the full rasters folder
  file.remove(list.files(paste0(str_extract(unzipFile, 
                                            pattern = ".+?(?=us_ssmv)"), "Raster Files/"),
                         recursive = TRUE,
                         full.names = TRUE))
  
  # Delete unzipped DAT file
  file.remove(unzipFile)
  
}













