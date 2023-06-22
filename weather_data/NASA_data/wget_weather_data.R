#obs = read.csv('../switchgrass_observation_averaged_plantyear.csv')
#latlon=obs[,c("lat","lon")]
#latlon = latlon[!is.na(latlon$lat),]
#latlon_unique = unique(latlon)
#latlon_unique = data.frame(latlon_unique,id=1:dim(latlon_unique)[1])
#obs$siteID = NA
#for (i in 1:length(obs$siteID)){
#  if(is.na(obs$lat[i])) next
#  id=latlon_unique$id[which(latlon_unique$lat==obs$lat[i] & latlon_unique$lon==obs$lon[i])]
#  obs$siteID[i] = id
#}
## write.csv(file = "switchgrass_aboveground_withID.csv",obs)
#write.csv(file = "unique_latlon_and_id.csv",latlon_unique,row.names = FALSE)

latlon_unique <- data.frame(id=1,lat=40.05192,lon=-88.37309) #Bondville, IL

for (i in 1:dim(latlon_unique)[1]){
  lat = latlon_unique$lat[i]
  lon = latlon_unique$lon[i]
  url=paste0("https://power.larc.nasa.gov/api/temporal/hourly/point?Time=LST&parameters=ALLSKY_SFC_PAR_TOT,T2M,RH2M,PRECTOTCORR,WS2M&community=AG&longitude=",lon,"&latitude=",lat,"&start=20100101&end=20221231&format=CSV")
  outfile_name = paste0("NASA_powerdata_2010_2022_site_",latlon_unique$id[i],".csv")
  download.file(url, destfile = outfile_name, method="wget")
}

#x=read.csv('NASA_powerdata_2001_2015_site_1.csv',skip = 13)
