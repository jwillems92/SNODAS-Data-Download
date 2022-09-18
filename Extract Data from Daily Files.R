
## SCRIPT FOR EXTRACTING DATA FROM SNODAS DAILY FILES

library(tidyverse)
library(SNODASR)
library(raster)
library(rgdal)
library(rgeos)
library(sf)

wd <- getwd()

# Extract values from raster files ----------------------------------------

#######################################################################################
### MEAN SNOW VALUES ACROSS ALL OF BEF ###
#######################################################################################

# Get a list of each cropped raster file for snow depth values only
cropRasterFiles <- list.files(path = paste0(wd,"/Cropped Raster Files/Snow Depth"),
                              pattern = "grd",
                              recursive = TRUE,
                              full.names = TRUE)

# Empty vector to hold snow depth values
depthVec <- numeric() 

for(index in cropRasterFiles){
  
  # Convert file to raster, extract all cell values, calculate the mean
  temp <- mean(getValues(raster(index)))
  
  # Add values for each raster to the empty vector
  depthVec <- c(depthVec, temp)
  
}

# Get dates from actual files to make sure everything lines up (rather than combining with dates vector from above)
# Create empty vector to hold dates
datesVec <- character()

for(index in cropRasterFiles){
  # Extract the year, month, & day from each file name
  # Pattern = everything after "NATS", then substr() extracts the individual date elements
  file.year <- substr(str_extract(index,
                                  pattern = "[^NATS]+$"),
                      1,4)
  
  file.month <- substr(str_extract(index,
                                   pattern = "[^NATS]+$"),
                       5,6)
  
  file.day <- substr(str_extract(index,
                                 pattern = "[^NATS]+$"),
                     7,8)
  
  file.Date <- paste(file.year, 
                     file.month, 
                     file.day, 
                     sep = "-")
  
  datesVec <- c(datesVec, file.Date)
  
}

snowDatesDF <- as.data.frame(datesVec)

# Divide vales by 1000 per the SNODAS user's guide
SnowDepth <- as.data.frame(depthVec)/1000

# Bind the dates to the snow depth values to make final df
SnowDepth_df <- cbind(snowDatesDF, SnowDepth)
SnowDepth_df <- SnowDepth_df %>% 
  rename("Date" = "datesVec",
         "Snow_Depth" = "depthVec")




#####################################################################################
### RASTER STACKING ###
#####################################################################################

# Create empty raster stack to fill in the loop below
stackSnowDepth <- stack()

for(index in cropRasterFiles){
  
  # Turn each file into a raster
  tempRast <- raster(index)
  
  # Add each converted file to the raster stack
  stackSnowDepth <- stack(stackSnowDepth, tempRast)
  
}

plot(stackSnowDepth)

nlayers(stackSnowDepth)

names(stackSnowDepth) <- c("D1", "D2", "D3", "D4")

# # Provide dates for all of the layers in the raster stack
# stackDates <- as.data.frame(seq(as.Date("2003-12-30"), as.Date("2004-01-02"), by = "days"))
# 
# # Add dates to each of the raster layers
# stack1 <- setZ(stack1, stackDates[,1], "SampleDate")


# Read in coordinates for sites
BEFpoints <- read_csv("BEF_Comp_Coords.csv")

BEFpoints_only <- BEFpoints %>% dplyr::select(-c(COMP))

# Convert points to same projection system as raster files
BEFpoints_proj <- SpatialPoints(BEFpoints_only,
                                proj4string = crs(raster(cropRasterFiles[1])))

# Extract values from each raster for each point & save as DF
SnowDepthPoints <- extract(stackSnowDepth, BEFpoints_proj) 
as.data.frame(SnowDepthPoints)

# Create DF of COMP names to join with data above
Sites <- as.data.frame(c("36", "41", "42", "45", "45A", "45B", "7_8", "CC", "5_6"))
colnames(Sites)[1] = "Site"

# Combine the site names DF with the extracted data DF
testDF <- cbind(Sites, SnowDepthPoints)

# Rename the columns with the dates from which the raster came from
colnames(testDF)[2:5] = as.character(seq(as.Date("2003-12-30"), as.Date("2004-01-02"), by = "days"))

# Pivot data to better format
testDF %>% 
  pivot_longer(!Site, names_to = "Date", values_to = "Snow Depth")












plot(raster(cropRasterFiles[1]))
points(BEFpoints_proj, pch = 19, cex = 2)

