library(yggdrasil)
source("/Users/mlmatth2/Research/BioCro/BioCro-ePhotosynthesis/Gro_wrapper.R")

flag <- TRUE
first_iter <- TRUE
initial_state_input_channel <- YggInterface("YggPandasInput", "Soybean-BioCro2:initial_state")
parameters_input_channel <- YggInterface("YggPandasInput", "Soybean-BioCro2:parameters")
varying_parameters_input_channel <- YggInterface("YggPandasInput", "Soybean-BioCro2:varying_parameters")
steady_state_module_names_input_channel <- YggInterface("YggAsciiTableInput", "Soybean-BioCro2:steady_state_module_names")
derivative_module_names_input_channel <- YggInterface("YggAsciiTableInput", "Soybean-BioCro2:derivative_module_names")
result_output_channel <- YggInterface("YggOutput", "Soybean-BioCro2:result")
while (flag) {
  c(flag, initial_state) %<-% initial_state_input_channel$recv()
  if (! (flag)) {
    if (first_iter) {
      stop("No input from initial_state.")
    } else {
      print("End of input from initial_state.")
      break
    }
  }
  if ((is(initial_state, "list")) && (length(initial_state) == 1)) {
    initial_state <- initial_state[[1]]
  }
  c(flag, parameters) %<-% parameters_input_channel$recv()
  if (! (flag)) {
    if (first_iter) {
      stop("No input from parameters.")
    } else {
      print("End of input from parameters.")
      break
    }
  }
  if ((is(parameters, "list")) && (length(parameters) == 1)) {
    parameters <- parameters[[1]]
  }
  c(flag, varying_parameters) %<-% varying_parameters_input_channel$recv()
  if (! (flag)) {
    if (first_iter) {
      stop("No input from varying_parameters.")
    } else {
      print("End of input from varying_parameters.")
      break
    }
  }
  if ((is(varying_parameters, "list")) && (length(varying_parameters) == 1)) {
    varying_parameters <- varying_parameters[[1]]
  }
  c(flag, steady_state_module_names) %<-% steady_state_module_names_input_channel$recv()
  if (! (flag)) {
    if (first_iter) {
      stop("No input from steady_state_module_names.")
    } else {
      print("End of input from steady_state_module_names.")
      break
    }
  }
  if ((is(steady_state_module_names, "list")) && (length(steady_state_module_names) == 1)) {
    steady_state_module_names <- steady_state_module_names[[1]]
  }
  c(flag, derivative_module_names) %<-% derivative_module_names_input_channel$recv()
  if (! (flag)) {
    if (first_iter) {
      stop("No input from derivative_module_names.")
    } else {
      print("End of input from derivative_module_names.")
      break
    }
  }
  if ((is(derivative_module_names, "list")) && (length(derivative_module_names) == 1)) {
    derivative_module_names <- derivative_module_names[[1]]
  }
  result <- Gro_wrapper(initial_state, parameters, varying_parameters, steady_state_module_names, derivative_module_names)
  flag <- result_output_channel$send(result)
  if (! (flag)) {
    stop("Could not send result.")
  }
  first_iter <- FALSE
}
