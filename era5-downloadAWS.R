rm(list = ls())

library("aws.s3")
library("raster")

era.download <- function(era.name = era.name){
  save_object(
    object = paste0(era.name),
    bucket = "s3://era5-pds/",
    region = "us-east-1",
    file = substring(era.name, 14),
    overwrite = TRUE)
}


longnames <- c("Air Temperature 1998-2021",
               "Air Temperature 1h Max 1998-2021",
               "Air Temperature 1h Min 1998-2021",
               "Precipitation 1h 1998-2021")

varunits <- c("K", "K", "K", "mm")

# Modificar por años de 1998 a 2021
for (year in 1998:1998)
  {
   for (month in 1:1) # modificar por mes de 1 a 12
     {
      
      era.names <- get_bucket_df(
        bucket = "s3://era5-pds/",
        prefix = paste0(year, "/", sprintf("%02d", month), "/data"),
        max = Inf,
        region = "us-east-1")
     
      variables <- c(era.names$Key[2], era.names$Key[3], era.names$Key[4], era.names$Key[12])
      
      lapply(variables, FUN = era.download)
      
      list.nc <- Sys.glob("./*.nc")
      aux.nc <- lapply(list.nc, FUN = stack)
      aux.nc <- lapply(aux.nc, FUN = crop, extent(290, 320, -45, -10))
      
      # re escribe las bajadas de ERA
      for (k in 1:length(variables)){
        writeRaster(aux.nc[[k]], substring(variables[k], 14),
                    overwrite = TRUE,
                    format = "CDF",
                    varunit = varunits[k], 
                    longname = longnames[k],
                    xname = "Longitude", yname = "Latitude", zname = "Time (Day)")}
      
     }
     
  }






