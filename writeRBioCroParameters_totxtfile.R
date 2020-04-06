
parameter_as_txt_files <- function(parameters, out.file){

  if (typeof(parameters)=="character") { # steady-state and derivative module names
    write.table(parameters, file=out.file, sep = "\n", col.names = FALSE, row.names = FALSE, quote = FALSE)
  }
  
  if (typeof(parameters)=="list") { # initial_state, parameters, varying_parameters
    write.table(parameters, file=out.file, row.names = FALSE, quote = FALSE, sep = "\t")
  }
  
}

#Examples:
# Set working directory to folder where thid file is located
filepath <- rstudioapi::getActiveDocumentContext()$path
filename <- sub(".*/","",filepath)
work.dir <- gsub(pattern = filename, replacement = "", x = filepath)
setwd(work.dir)

# soybean steady state modules
soybean_ss_modules <- c('soil_type_selector', 'stomata_water_stress_linear', 
                        'leaf_water_stress_exponential', 'parameter_calculator', 
                        'c3_canopy', 'soybean_development_rate_calculator', 
                        'partitioning_coefficient_logistic', 
                        'no_leaf_resp_partitioning_growth_calculator',
                        'senescence_coefficient_logistic')

parameter_as_txt_files(soybean_ss_modules, "example_soybean_ss_modules.txt")

# soybean parameters
source("./biocro-dev/data/Soybean/soybean_parameters.R")
parameter_as_txt_files(soybean_parameters, "example_soybean_parameters.txt")

# sorghum initial state
parameter_as_txt_files(sorghum_initial_state, "example_sorghum_initial_state.txt")


