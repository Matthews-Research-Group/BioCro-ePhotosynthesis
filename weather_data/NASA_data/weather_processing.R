source('POWERNASA_to_BioCroInputs.R')
source('solar_function_NOAA.R') #for daylength calculation

latlon_unique <- data.frame(id=1,lat=40.05192,lon=-88.37309) #Bondville, IL

for (i in 1:nrow(latlon_unique)) {
  lat      = latlon_unique$lat[i]
  lon      = latlon_unique$lon[i]
  site.id  = latlon_unique$id[i]
  
  NASA.weather <- read.csv(paste0("NASA_powerdata_2010_2022_site_",site.id,'.csv'),skip = 13 )

  biocroinput <- POWERNASA_to_BioCroInputs(powernasa = NASA.weather, latitude = lat)

  daylength      = 1:nrow(biocroinput)* NA  
  for (j in 1:nrow(biocroinput)){
    jday = biocroinput$jday[j]
    local_time = biocroinput$hour[j]
    timezone  = biocroinput$tz[j]
    daylength[j]  = daylength_NOAA(lat,jday,local_time,timezone) # this is in minutes 
    daylength[j]  = daylength[j]/60  #min to hour 
  } 
  
  biocroinput = cbind(biocroinput,daylength)

  write.csv(biocroinput,file = paste0("BioCroInputs/site_", site.id ,'_2010_2022.csv'), row.names = FALSE)
   
}
