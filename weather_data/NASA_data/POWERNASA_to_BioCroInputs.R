library(lubridate)
# This function coverts POWERNASA weather data to BioCro's inputs for Soybean.
# NOTE: the NASA's time stamp is NOT in UTC! It's already in the local time.
# So, no need to convert time Zone

POWERNASA_to_BioCroInputs <- function(powernasa,latitude){
  
  solar <- powernasa$ALLSKY_SFC_PAR_TOT*4.25  #conversion from W/m2 to PPFD, See weach function. Note: POWERNASA is PAR and not total
  rh=powernasa$RH2M*0.01
  weatherdate <- as.Date(paste0(powernasa$MO,"/",powernasa$DY,"/",powernasa$YEAR),format=c("%m/%d/%Y"))
  doy <- yday(weatherdate)
   
  #julian days
  jday = julian(weatherdate,origin = as.Date("1900-01-01")) + 2 
  # +2 to match Excel's results that convert dates to numbers 

  #because of daylight saving, we calculate the timezone for each day of year using this method
  date_local = as.POSIXct(paste0(powernasa$YEAR,"-",powernasa$MO,"-",powernasa$DY), tz="America/Chicago")
  date_utc   = as.POSIXct(paste0(powernasa$YEAR,"-",powernasa$MO,"-",powernasa$DY), tz="UTC")
  timezone_shift   = as.numeric(date_utc - date_local)


  BioCroInputs <- data.frame(year=powernasa$YEAR,doy=doy,hour=powernasa$HR,temp=powernasa$T2M,rh=rh,
                             windspeed=powernasa$WS2M,precip=powernasa$PRECTOTCORR,solar=solar,tz=timezone_shift,jday=jday)
  return(BioCroInputs)
}
