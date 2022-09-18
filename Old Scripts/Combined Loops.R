






# Vector of all snow depth zipped files
sdList <- list.files(path = paste0(wd, "/Individual Parameter Files/Snow Depth"),
                     pattern = ".dat.gz",
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









