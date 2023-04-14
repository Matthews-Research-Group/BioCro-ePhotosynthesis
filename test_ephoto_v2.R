library(BioCroEphoto)

year <- '2002' # other options: '2004', '2005', '2006'

## Load weather data for growing season from specified year
weather <- soybean_weather[[year]] 
dates <- data.frame("year" = 2001:2006,"sow" = c(143,152,147,149,148,148), "harvest" = c(291, 288, 289, 280, 270, 270))

sowdate <- dates$sow[which(dates$year == year)] #143 #148 #149 #152
harvestdate <- dates$harvest[which(dates$year == year)] #291 #270 #280 #288
sd.ind <- which(weather$doy == sowdate)[1]
hd.ind <- which(weather$doy == harvestdate)[24]

weather <- weather[sd.ind:hd.ind,]  #growing season

#------------------------
#Currently, NO need to change "restart" since it's automatically addressed below!!
#
restart = FALSE #whether the first day of current period of run is RESTART or NOT 
run_days  = 73#136 
run_hours = run_days * 24
start_day = 215#152 #starting day of year, minimal from the sowdate! 
end_day   = start_day+run_days-1
output_folder = "results_ephoto_v2"
#------------------------

if(start_day>sowdate) restart = TRUE

finished_days = start_day - sowdate #count from the sowdate
if(finished_days<0) stop("incorrect start day!") 
finished_hours = finished_days *24
beg_ind = finished_hours+1
#add an extra hour for the next init state 
#this is because in BioCro, the output of hour x has the label at hour x+1 
end_ind = min(finished_hours + run_hours +1, dim(weather)[1]) 
out_filename  = paste0(output_folder,"/results_ephoto_full_",start_day,"_",end_day)
if(restart){
  last_filename = paste0(output_folder,"/results_ephoto_full_165_264_day50.rds")
}
print(paste("sow,start and end days are",sowdate,start_day,end_day))

#if(end_ind > dim(weather)[1]){
#  weather <- weather[beg_ind:dim(weather)[1],]  #
#}else{
  weather <- weather[beg_ind:end_ind,]  # subset of the weather for the run period ONLY!
#}

# steady_state_modules
steady_state_modules <- soybean$direct_modules

# derivative_modules
derivative_modules <- soybean$differential_modules 

# soybean_initial_state
soybean_initial_state = soybean$initial_values

# soybean_parameters
soybean_parameters = soybean$parameters 

solver_params <- soybean$ode_solver  
solver_params$type = 'homemade_euler'

#last_filename = "results_ephoto_v2/results_ephoto_full_152_251_day1.rds"
#        result_last   = readRDS(last_filename)
#        init_vars = names(soybean_initial_state)
#        x_sub = result_last[,init_vars]
#        last_values = x_sub[dim(x_sub)[1],]
#
##get the last day's record to use as initial
#        soybean_initial_state_last = soybean_initial_state
#        for (ii in 1:length(soybean_initial_state)){
#                soybean_initial_state_last[[ii]] = as.numeric(last_values[ii])
#        }
#print(soybean_initial_state_last)
#stop()

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
   b1 = min(b1,dim(weather)[1])  #make sure index not out of range! 
   weather_dayi = weather[b0:b1,]
#for (j in 1:dim(weather_i)[1]){
#   weather_ij = weather_i[j,]
 print(soybean_initial_state_last)
   result <- run_biocro(soybean_initial_state_last,
                        soybean_parameters, 
                        weather_dayi, 
                        steady_state_modules,
                        derivative_modules
                       )
#   print(c("finished hour",j))
#}
   outfile_i = paste0(out_filename,"_day",i,".rds")
   saveRDS(result,outfile_i)
   print(c("finished day",i))
#read in the results from the last step
   last_filename = outfile_i 
#   result_last   = readRDS(last_filename)
   restart = TRUE  #After the first day: sow date, it must be a Restart!!!!!
}

print("Successfully done!")
