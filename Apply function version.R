
library(tictoc)

tic("for Loop")
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
toc()


### CONVERT FOR LOOP INTO FUNCTION FOR APPLY ###

crop.raster <- function(filename){
  
  # Unzip the file & delete original zipped file
  unzipFile <- gunzip(filename = filename,
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

tic("Apply")
sapply(sdList, crop.raster)
toc()