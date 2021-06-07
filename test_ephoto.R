library(BioCro)
#library(reshape2)
#library(ggplot2)

year <- '2002' # other options: '2004', '2005', '2006'

filepath <- "./models/biocro-dev/data/Soybean/"

## Load weather data for growing season from specified year
weather <- read.csv(file = paste0(filepath,'weather/', year, '_Bondville_IL_daylength.csv'))
dates <- data.frame("year" = 2001:2006,"sow" = c(143,152,147,149,148,148), "harvest" = c(291, 288, 289, 280, 270, 270))

sowdate <- dates$sow[which(dates$year == year)] #143 #148 #149 #152
harvestdate <- dates$harvest[which(dates$year == year)] #291 #270 #280 #288
sd.ind <- which(weather$doy == sowdate)[1] + 9
hd.ind <- which(weather$doy == harvestdate)[24]

weather <- weather[sd.ind:hd.ind,]  #growing season
weather <- weather[1:24,]  #first day
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


result <- Gro_solver(soybean_initial_state, soybean_parameters, weather, steady_state_modules, derivative_modules,solver = solver_params)

saveRDS(result,"results.rds")

print("Successfully done!")
