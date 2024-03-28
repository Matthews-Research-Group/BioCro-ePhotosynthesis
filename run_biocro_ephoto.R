library(BioCro)
library(BMLePhoto)
#there is a parameter called sensitivity_sf in c3photo.cpp
#it controls the scaling factor of certain enzymes.
#double check what value it is for your run

# turn this on to have increased Temperature and CO2
test_T_and_CO2 = FALSE 
test_T = FALSE 

year <- '2006' # 
enzyme_sf = 1
output_folder = paste0("results_r1_V2V13_sf",enzyme_sf,"_",year)  #the folder to save daily outputs
dir.create(output_folder)

weather_path = "weather_data/NASA_data/BioCroInputs/site_1_2010_2022.csv"

## Load weather data for growing season from specified year
weather_all = read.csv(weather_path)
colnames(weather_all)[colnames(weather_all)=="daylength"] = "day_length"
weather = weather_all[weather_all$year==as.numeric(year),]
#these dates were provided in MLM's paper
#For other years, I simply used same dates took from this paper:https://doi.org/10.1093/jxb/erw435
dates <- data.frame("year" = 2001:2006,
                    "sow"     = c(143, 152, 147, 149, 148, 148), 
                    "harvest" = c(291, 288, 289, 289, 270, 270))
if(year<=2006){
  weather_path_old = paste0("weather_data/",year,"_Bondville_IL_daylength.csv")
  weather <- read.csv(weather_path_old)
  sowdate <- dates$sow[which(dates$year == year)] #
  harvestdate <- dates$harvest[which(dates$year == year)] #
  sd.ind <- which(weather$doy == sowdate)[1]
  hd.ind <- which(weather$doy == harvestdate)[24]
}else{
  sowdate = 158 
  harvestdate = 275
  sd.ind <- which(weather$doy == sowdate)[1]
  hd.ind <- which(weather$doy == harvestdate)[24]
}

weather <- weather[sd.ind:hd.ind,]  #growing season
#needed by module BioCro:solar_position_michalsky
if(!"time_zone_offset" %in% colnames(weather))
{
  print('no time zone offset exists in weather data. Adding one...')
  weather$time_zone_offset = -6
}

if(test_T_and_CO2 | test_T) weather$temp = weather$temp + 3

#------------------------
#Currently, NO need to change "restart" since it's automatically addressed below!!
#
restart = FALSE # Whether the first day of current period of run is RESTART or NOT 
run_days  = harvestdate - sowdate  # Total number of days to run 
run_hours = run_days * 24 #Total hours
start_day = sowdate #152 #starting day of year, minimal from the sowdate! 
end_day   = start_day+run_days-1
#------------------------

if(start_day>sowdate) restart = TRUE
#count from the sowdate; 
#we need to know how many days finished to index the weather data correctly
finished_days = start_day - sowdate 
if(finished_days<0) stop("incorrect start day!") 
finished_hours = finished_days *24
beg_ind = finished_hours+1  #begin of index for weather
#add an extra hour for the next init state 
#this is because in BioCro, the output of hour x has the label at hour x+1! 
end_ind = min(finished_hours + run_hours +1, dim(weather)[1]) #end of index for weather 

out_filename_prefix  = paste0(output_folder,"/results_ephoto_")
if(restart){
  #if it's restart, then we start with the DOY one day before the start_day
  last_filename = paste0(output_folder,"/results_ephoto_full_doy",start_day-1,".rds")
}
print(paste("sow,start and end days are",sowdate,start_day,end_day))

# subset of the weather for the run period ONLY!
weather_sub <- weather[beg_ind:end_ind,]  
#

# steady_state_modules
steady_state_modules <- soybean$direct_modules
# now use BML's modules
steady_state_modules[[10]] = "BMLePhoto:ten_layer_canopy_properties"
steady_state_modules[[11]] = "BMLePhoto:ten_layer_c3_canopy"
steady_state_modules[[12]] = "BMLePhoto:ten_layer_canopy_integrator"

# derivative_modules
derivative_modules <- soybean$differential_modules 

# soybean_initial_state
soybean_initial_state = soybean$initial_values

# soybean_parameters
soybean_parameters = soybean$parameters 
soybean_parameters$enzyme_sf = enzyme_sf 
#latest version of BioCro no longer uses this, but we need it here cuz I'm using an older version
soybean_parameters$water_stress_approach = 1 
if(test_T_and_CO2){
 soybean_parameters$Catm = 600 
}else{
 soybean_parameters$Catm = 400 
}

solver_params <- soybean$ode_solver  
solver_params$type = 'homemade_euler'

#loop through the number of run days
for (i in 1:run_days){
   if(restart){
	result_last   = readRDS(last_filename)
   	init_vars = names(soybean_initial_state)
   	x_sub = result_last[,init_vars]
   	last_values = x_sub[dim(x_sub)[1],] 
   	
#get the last day's record to use as initial
   	soybean_initial_state_last = soybean_initial_state
   	for (ii in 1:length(soybean_initial_state)){
   	        soybean_initial_state_last[[ii]] = as.numeric(last_values[ii])
   	}
   }else{
   	soybean_initial_state_last = soybean_initial_state
   }
   b0 = (i-1)*24+1
   b1 = i*24 + 1  #add an extra hour for this day, which will be the init state for the next day
   b1 = min(b1,dim(weather_sub)[1])  #make sure index not out of range! 
   weather_dayi = weather_sub[b0:b1,]

   print(soybean_initial_state_last)
   result <- run_biocro(soybean_initial_state_last,
                        soybean_parameters, 
                        weather_dayi, 
                        steady_state_modules,
                        derivative_modules,
			solver_params
                       )
   outfile_i = paste0(out_filename_prefix,"doy",weather_dayi$doy[1],".rds")
   saveRDS(result,outfile_i)
   print(c("finished day",i))
   last_filename = outfile_i #change the last_filename to the doy just finsihed 
   restart = TRUE  #After the first day, it must be a Restart!!!!!
}

print("Successfully done!")
