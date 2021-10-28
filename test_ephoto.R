library(BioCro)
#library(reshape2)
#library(ggplot2)
restart = TRUE 
run_days = 30
run_hours = run_days * 24
start_day = 242 #starting day of year, minimal from the sowdate! 
end_day   = start_day+run_days-1

year <- '2002' # other options: '2004', '2005', '2006'

filepath <- "./models/biocro-dev/data/Soybean/"

## Load weather data for growing season from specified year
weather <- read.csv(file = paste0(filepath,'weather/', year, '_Bondville_IL_daylength.csv'))
dates <- data.frame("year" = 2001:2006,"sow" = c(143,152,147,149,148,148), "harvest" = c(291, 288, 289, 280, 270, 270))

sowdate <- dates$sow[which(dates$year == year)] #143 #148 #149 #152
harvestdate <- dates$harvest[which(dates$year == year)] #291 #270 #280 #288
sd.ind <- which(weather$doy == sowdate)[1]
hd.ind <- which(weather$doy == harvestdate)[24]

finished_days = start_day - sowdate #count from the sowdate
if(finished_days<0) stop("incorrect start day!") 
finished_hours = finished_days *24
beg_ind = finished_hours+1
end_ind = finished_hours + run_hours 
out_filename = paste0("daily_outputs_run2/results_ephoto_",start_day,"_",end_day)
last_filename = paste0("daily_outputs_run2/results_ephoto_",start_day-30,"_",start_day-1,"_day30.rds")

print(paste("sow,start and end days are",sowdate,start_day,end_day))

weather <- weather[sd.ind:hd.ind,]  #growing season
if(end_ind > dim(weather)[1]){
weather <- weather[beg_ind:dim(weather)[1],]  #
}else{
weather <- weather[beg_ind:end_ind,]  # subset of the weather for the run period ONLY!
}
#weather = read.table("parameter_files/soybean_weather_2002doy202hrs0800_0900.txt",header=TRUE) #two hours

## Experimentally collected biomassees
ExpBiomass<-read.csv(file=paste0(filepath,'biomasses/',year,'_ambient_biomass.csv'))
ExpBiomass.std<-read.csv(file=paste0(filepath,'biomasses/',year,'_ambient_biomass_std.csv'))
colnames(ExpBiomass)<-c("DOY","Leaf","Stem","Grain","Seed","Litter","CumLitter")
colnames(ExpBiomass.std)<-c("DOY","Leaf","Stem","Grain","Seed","Litter","CumLitter")


# steady_state_modules
steady_state_modules <- c('soil_type_selector', 'stomata_water_stress_linear', 
                          'leaf_water_stress_exponential', 'parameter_calculator', 
			  'soybean_development_rate_calculator',
			  'partitioning_coefficient_logistic',
			  'soil_evaporation',
			  'solar_zenith_angle',
			  'shortwave_atmospheric_scattering',
			  'incident_shortwave_from_ground_par',
			  'ten_layer_canopy_properties',
#			  'ten_layer_c3ephotosynthesis_canopy_yh_parallel',
#			  'ten_layer_c3ephotosynthesis_canopy_yh',
			  'ten_layer_c3_canopy',
#			  'ten_layer_c3_canopy_parallel',
			  'ten_layer_canopy_integrator',
                          'no_leaf_resp_partitioning_growth_calculator',
                          'senescence_coefficient_logistic')

# derivative_modules
derivative_modules <- c('thermal_time_senescence_logistic', 'partitioning_growth', 
                        'two_layer_soil_profile', 'development_index','thermal_time_linear')

# soybean_initial_state
source(paste0(filepath,'soybean_initial_state.R'))

# soybean_parameters
#source(paste0(filepath,'soybean_parameters.R'))
#soybean_parameters$rateSeneRoot <- 0
#soybean_parameters$rateSeneRhizome <- 0
#soybean_parameters$alphaSeneRoot <- 10
#soybean_parameters$alphaSeneRhizome <- 10
#soybean_parameters$betaSeneRoot <- -10
#soybean_parameters$betaSeneRhizome <- -10
soybean_parameters = read.table("parameter_files/soybean_parameters_farquhar.txt",header=TRUE)


solver_params <- list(
  type = 'Gro_euler',
  output_step_size = 1.0,
  adaptive_rel_error_tol = 1e-4,
  adaptive_abs_error_tol = 1e-4,
  adaptive_max_steps = 200)

for (i in 1:run_days){
   if(restart){
	result_last   = readRDS(last_filename)
   	init_vars = names(soybean_initial_state)
   	x_sub = result_last[,init_vars]
   	last_values = x_sub[dim(x_sub)[1],] 
   	
   	soybean_initial_state_last = soybean_initial_state
   	for (ii in 1:length(soybean_initial_state)){
   	        soybean_initial_state_last[[ii]] = last_values[ii]
   	}
   }else{
   	soybean_initial_state_last = soybean_initial_state
   }
   b0 = (i-1)*24+1
   b1 = i*24
   if(b1 > dim(weather)[1]) break  #make sure index not out of range! 
   weather_i = weather[b0:b1,]
#for (j in 1:dim(weather_i)[1]){
#   weather_ij = weather_i[j,]
   result <- Gro_solver(soybean_initial_state_last, soybean_parameters, weather_i, steady_state_modules, derivative_modules,solver = solver_params)
#   print(c("finished hour",j))
#}
   outfile_i = paste0(out_filename,"_day",i,".rds")
   saveRDS(result,outfile_i)
   print(c("finished day",i))
#read in the results from the last step
   last_filename = outfile_i 
   result_last   = readRDS(last_filename)
}

print("Successfully done!")
