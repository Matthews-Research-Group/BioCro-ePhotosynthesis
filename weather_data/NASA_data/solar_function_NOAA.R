# This is based on https://gml.noaa.gov/grad/solcalc/calcdetails.html 
# It has an excel sheet for the algorithm below
# I simply followed the excel sheet and took their euqations here
daylength_NOAA<-function(lat,jday,local_time,timezone){
  julian_day     = jday + 2415018.5 + local_time/24.0 - timezone/24.0
  julian_century = (julian_day - 2451545)/36525
  Geom_Mean_Long_Sun = (280.46646+julian_century*(36000.76983 + julian_century*0.0003032)) %% 360
  Geom_Mean_Anom_Sun = 357.52911 +julian_century*(35999.05029 - 0.0001537*julian_century)
  Eccent_Earth_Orbit = 0.016708634-julian_century*(0.000042037+0.0000001267*julian_century)
  Sun_Eq_of_Ctr      = sin(deg2rad(Geom_Mean_Anom_Sun))*(1.914602-julian_century*(0.004817+0.000014*julian_century))+
                       sin(deg2rad(2*Geom_Mean_Anom_Sun))*(0.019993-0.000101*julian_century)+
                       sin(deg2rad(3*Geom_Mean_Anom_Sun))*0.000289
  Sun_True_Long = Geom_Mean_Long_Sun + Sun_Eq_of_Ctr #(deg)
  Sun_True_Anom = Geom_Mean_Anom_Sun + Sun_Eq_of_Ctr #(deg)
  Sun_Rad_Vector = (1.000001018*(1-Eccent_Earth_Orbit*Eccent_Earth_Orbit))/
                   (1+Eccent_Earth_Orbit*cos(deg2rad(Sun_True_Anom))) #(AUs)
  Sun_App_Long = Sun_True_Long-0.00569-0.00478*sin(deg2rad(125.04-1934.136*julian_century))#(deg)
  Mean_Obliq_Ecliptic = 23+(26+((21.448-julian_century*(46.815+julian_century*(0.00059-julian_century*0.001813))))/60)/60 #(deg)
  Obliq_Corr = Mean_Obliq_Ecliptic+0.00256*cos(deg2rad(125.04-1934.136*julian_century)) #(deg)
  Sun_Rt_Ascen = rad2deg(atan2(cos(deg2rad(Obliq_Corr))*sin(deg2rad(Sun_App_Long)),cos(deg2rad(Sun_App_Long))))#(deg)
  Sun_Declin   = rad2deg(asin(sin(deg2rad(Obliq_Corr))*sin(deg2rad(Sun_App_Long)))) #(deg)
  var_y = tan(deg2rad(Obliq_Corr/2))*tan(deg2rad(Obliq_Corr/2))
  Eq_of_Time = 4*rad2deg(var_y*sin(2*deg2rad(Geom_Mean_Long_Sun))-2*Eccent_Earth_Orbit*sin(deg2rad(Geom_Mean_Anom_Sun))+
                           4*Eccent_Earth_Orbit*var_y*sin(deg2rad(Geom_Mean_Anom_Sun))*cos(2*deg2rad(Geom_Mean_Long_Sun))-
                           0.5*var_y*var_y*sin(4*deg2rad(Geom_Mean_Long_Sun))-
                           1.25*Eccent_Earth_Orbit*Eccent_Earth_Orbit*sin(2*deg2rad(Geom_Mean_Anom_Sun))) #minutes
  HA_Sunrise = rad2deg(acos(cos(deg2rad(90.833))/(cos(deg2rad(lat))*cos(deg2rad(Sun_Declin)))-
                              tan(deg2rad(lat))*tan(deg2rad(Sun_Declin))))#(deg)
  Sunlight_Duration = 8 * HA_Sunrise #minutes
  return(Sunlight_Duration)
}
deg2rad <- function(deg) {(deg * pi) / (180)}
rad2deg <- function(rad) {(rad * 180) / (pi)}
