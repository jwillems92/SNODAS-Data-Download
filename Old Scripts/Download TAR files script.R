
# Script for downloading & unzipping SNODAS data files

library(tidyverse)
library(snowdl)
library(archive)
library(R.utils)
library(lubridate)


################################################################################################################
#########################################################################################################

# Create vector of dates to download SNODAS data for ----------------------

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

datesVec



testVec <- seq(as.Date("2003-12-30"), as.Date("2004-01-02"), by = "days")

# Loop for downloading data -----------------------------------------------

for(index in testVec){
  # Create new folders for each winter (runs from 10/01 to 5/15)
  mkfldr <- paste0("/TAR Files/",
                   "Winter ",
                   
                   ifelse(
                     # substr pull out 6th and 7th characters for the month, convert to numeric
                     # If month > 6, then put in folder labeled after the year in the file name
                     as.numeric(substr(as.Date(index, origin = "1970-01-01"),6,7)) > 6,
                     substr(as.Date(index, origin = "1970-01-01"),1,4),
                     # Else extract year from file name, subtract one, and place in that years folder
                     as.character(as.numeric(substr(as.Date(index, origin = "1970-01-01"),1,4)) - 1)))
  
  # Download SNODAS files for each date in vector and save in appropriate folder
  download_SNODAS(as.Date(index, origin = "1970-01-01"), 
                  out_dir = paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS", mkfldr),
                  overwrite = FALSE)
}


#########################################################################################################
#########################################################################################################

# Loop through each .tar file and unzip it ------------------------

# Get a list of all .tar files within the given folder
fileList <- list.files(path = "C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/TAR Files",
                       pattern = "*.tar",
                       recursive = TRUE,
                       full.names = F)


# Loop through each daily .tar file and unzip to a new set of folders for each winter
for(i in fileList){
  
  untar(tarfile = paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/TAR Files/",i),
        exdir = paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Unzipped Files/",
                       substr(i, 1, 11)))
  
}


# List all of the unzipped files in all folders
unzippedList <- list.files(path = "C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Unzipped Files",
                           recursive = TRUE,
                           full.names = TRUE)
              
# Filter to only the files for the parameters of interest (1036 = snow depth, 1034 = SWE)
snowDepthList <- grep("1036tS",
                      unzippedList,
                      value = TRUE)

sweList <- grep("1034tS",
                unzippedList,
                value = TRUE)


## SNOW DEPTH ##
for(i in snowDepthList){
  
  # Create new folders (have to do one folder at a time) Ignore warnings, seems to work ok
  dir.create("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files")
  dir.create("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files/Snow Depth")
  dir.create(paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files/Snow Depth/",
                    substr(i, 67, 77)))
  
  # Copy files in index to newly created folder
  file.copy(from = i,
            to = paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files/Snow Depth/",
                        substr(i, 67,77)))
}

 

## SNOW WATER EQUIVALENT ##
for(i in sweList){
  
  dir.create("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files/SWE")
  dir.create(paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files/SWE/",
                    substr(i, 67, 77)))
  
  file.copy(from = i,
            to = paste0("C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files/SWE/",
                        substr(i, 67, 77)))
}
 
 
#########################################################################################################
#########################################################################################################

# List of all individual parameter zipped files
paramsList <- list.files(path = "C:/Users/jswil/Documents/PhD Stuff/R Coding/SNODAS/Parameter Files",
                         full.names = TRUE,
                         recursive = TRUE)

# Loop through each file and unzip, save unzipped files, delete zipped files
for(i in paramsList){
  
  gunzip(filename = i,
         overwrite = TRUE)
  
}

