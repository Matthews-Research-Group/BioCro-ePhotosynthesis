#ifndef YGGDRASIL_C3EPHOTOSYNTHESIS_LEAF_H
#define YGGDRASIL_C3EPHOTOSYNTHESIS_LEAF_H

#include <stdio.h> // for yggdrasil connection (is this needed?)
#include "../modules.h"
#include "YggInterface.hpp" // for yggdrasil connection
//#include "c3photo.hpp"  // for c3photoC
//#include "BioCro.h"     // for c3EvapoTrans

/**
 *
 * Call yggdrasil (Lang 2019) to connect to a leaf photosynthesis model that uses
 * ePhotosynthesis  (Zhu et al., 2007, Wang et al., XXXX )
 *
 *  References:
 *  Lang, M. M. 2019
 *  Zhu, X et al., 2007
 *  Leaf photosynthis model github link:
 *
 */
class yggdrasil_c3ephotosynthesis_leaf : public SteadyModule
{
   public:
    yggdrasil_c3ephotosynthesis_leaf(
        const std::unordered_map<std::string, double>* input_parameters,
        std::unordered_map<std::string, double>* output_parameters)
        :  // Define basic module properties by passing its name to its parent class
          SteadyModule("yggdrasil_c3ephotosynthesis_leaf"),
          // Get references to input parameters
          par_energy_content(get_input(input_parameters, "par_energy_content")),
          incident_par(get_input(input_parameters, "incident_par")),
          incident_average_par(get_input(input_parameters, "incident_average_par")),
          temp(get_input(input_parameters, "temp")),
          rh(get_input(input_parameters, "rh")),
          windspeed(get_input(input_parameters, "windspeed")),
          Rd(get_input(input_parameters, "Rd")),
          b0(get_input(input_parameters, "b0")),
          b1(get_input(input_parameters, "b1")),
          Catm(get_input(input_parameters, "Catm")),
          O2(get_input(input_parameters, "O2")),
          theta(get_input(input_parameters, "theta")),
          StomataWS(get_input(input_parameters, "StomataWS")),
          atmospheric_pressure(get_input(input_parameters, "atmospheric_pressure")),
          radiation_nir(get_input(input_parameters, "radiation_nir")),
          radiation_longwave(get_input(input_parameters, "radiation_longwave")),
          vmax1(get_input(input_parameters, "vmax1")),
          jmax(get_input(input_parameters, "jmax")),
          photosynthesis_type(get_input(input_parameters,"photosynthesis_type")),
//          water_stress_approach(get_input(input_parameters, "water_stress_approach")),
//          electrons_per_carboxylation(get_input(input_parameters, "electrons_per_carboxylation")),
//          electrons_per_oxygenation(get_input(input_parameters, "electrons_per_oxygenation")),
//          height(get_input(input_parameters, "height")),
          
          // Get pointers to output parameters
          Assim_op(get_op(output_parameters, "Assim")),
          GrossAssim_op(get_op(output_parameters, "GrossAssim")),
          Ci_op(get_op(output_parameters, "Ci")),
          Gs_op(get_op(output_parameters, "Gs")),
          TransR_op(get_op(output_parameters, "TransR")),
          leaf_temperature_op(get_op(output_parameters, "leaf_temperature"))
    {
    }
    static std::vector<std::string> get_inputs();
    static std::vector<std::string> get_outputs();
    static std::string get_description();

   private:
    // Pointers to input parameters
    double const& par_energy_content;
    double const& incident_par;
    double const& incident_average_par;
    double const& temp;
    double const& rh;
    double const& windspeed;
    double const& Rd;
    double const& b0;
    double const& b1;
    double const& Catm;
    double const& O2;
    double const& theta;
    double const& StomataWS;
    double const& atmospheric_pressure;
    double const& radiation_nir;
    double const& radiation_longwave;
    double const& vmax1;
    double const& jmax;
    double const& photosynthesis_type;
//    double const& water_stress_approach;
//    double const& electrons_per_carboxylation;
//    double const& electrons_per_oxygenation;
//    double const& height;
    
    // Pointers to output parameters
    double* Assim_op;
    double* GrossAssim_op;
    double* Ci_op;
    double* Gs_op;
    double* TransR_op;
    double* leaf_temperature_op;
    
    // Main operation
    void do_operation() const;
};

std::vector<std::string> yggdrasil_c3ephotosynthesis_leaf::get_inputs()
{
    return {
        "par_energy_content",           // J / micromol
        "incident_par",                 // J / (m^2 leaf) / s
        "incident_average_par",         // J / (m^2 leaf) / s
        "temp",                         // deg. C
        "rh",                           // dimensionless
        "windspeed",                    // m / s
        "Rd",                           // micromole / m^2 / s
        "b0",                           // mol / m^2 / s
        "b1",                           // dimensionless
        "Catm",                         // micromole / mol
        "O2",                           // mmol / mol
        "theta",                        // dimensionless
        "StomataWS",                    // dimensionless
        "atmospheric_pressure",         // ADD UNITS
        "radiation_nir",                // ADD UNITS
        "radiation_longwave",           // ADD UNITS
        "vmax1",                        // micromole / m^2 / s
        "jmax",                         // micromole / m^2 / s
        "photosynthesis_type"           // a dimensionless switch
//        "water_stress_approach",        // a dimensionless switch
//        "electrons_per_carboxylation",  // electron / carboxylation
//        "electrons_per_oxygenation",    // electron / oxygenation
//        "height"                        // m
        
    };
}

std::vector<std::string> yggdrasil_c3ephotosynthesis_leaf::get_outputs()
{
    return {
        "Assim",            // micromole / m^2 /s
        "GrossAssim",       // micromole / m^2 /s
        "Ci",               // micromole / mol
        "Gs",               // mmol / m^2 / s
        "TransR",           // mmol / m^2 / s
        "leaf_temperature"  // deg. C
    };
}

void yggdrasil_c3ephotosynthesis_leaf::do_operation() const
{
    // Convert light inputs from energy to molecular flux densities
    const double incident_par_micromol = incident_par / par_energy_content; // micromol / m^2 / s
    
    // Set up connections matching yaml
    // RPC client-side connection will be $(server_name)_$(client_name)
    YggRpcClient rpc("server_client", "%s", "%s");
    
    // set up variables to be passed in and out of rpc.call
    generic_t state_input = init_generic_map();
    generic_t state_output = init_generic_map();
    
    double ret = generic_map_set_double(state_input,"incident_par_micromol",incident_par_micromol,"");
    ret = generic_map_set_double(state_input,"temp",temp,"");
    ret = generic_map_set_double(state_input,"rh",rh,"");
    ret = generic_map_set_double(state_input,"Rd",Rd,"");
    ret = generic_map_set_double(state_input,"b0",b0,"");
    ret = generic_map_set_double(state_input,"b1",b1,"");
    ret = generic_map_set_double(state_input,"Catm",Catm,"");
    ret = generic_map_set_double(state_input,"O2",O2,"");
    ret = generic_map_set_double(state_input,"theta",theta,"");
    ret = generic_map_set_double(state_input,"StomataWS",StomataWS,"");
    ret = generic_map_set_double(state_input,"incident_average_par",incident_average_par,"");
    ret = generic_map_set_double(state_input,"windspeed",windspeed,"");
    ret = generic_map_set_double(state_input,"atmospheric_pressure",atmospheric_pressure,"");
    ret = generic_map_set_double(state_input,"radiation_nir",radiation_nir,"");
    ret = generic_map_set_double(state_input,"radiation_longwave",radiation_longwave,"");
    ret = generic_map_set_double(state_input,"Vmax",vmax1,"");
    ret = generic_map_set_double(state_input,"Jmax",jmax,"");
    ret = generic_map_set_double(state_input,"photosynthesis_type",photosynthesis_type,"");
    
    // call server funcition (ephotosynthesis)
    ret = rpc.call(2,state_input, &state_output);
    
    // get output parameters
    double Assim = generic_map_get_double(state_output,"NetAssimilation");
    double GrossAssim = generic_map_get_double(state_output,"GrossAssimilation");
    double Ci = generic_map_get_double(state_output,"Ci");
    double Gs = generic_map_get_double(state_output,"Gs");
    double TransR = generic_map_get_double(state_output,"Transpiration");
    double leaf_temperature = generic_map_get_double(state_output,"LeafTemperature");
    
    
//    // Convert light inputs from energy to molecular flux densities
//    const double incident_par_micromol = incident_par / par_energy_content;                  // micromol / m^2 / s
//    const double incident_average_par_micromol = incident_average_par / par_energy_content;  // micromol / m^2 / s
//
//    // Get an initial estimate of stomatal conductance, assuming the leaf is at air temperature
//    const double initial_stomatal_conductance = c3photoC(
//                                                    incident_par_micromol, temp, rh, vmax1, jmax,
//                                                    Rd, b0, b1, Catm, O2, theta, StomataWS, water_stress_approach,
//                                                    electrons_per_carboxylation, electrons_per_oxygenation)
//                                                    .Gs;  // mmol / m^2 / s
//
//    // Calculate a new value for leaf temperature
//    //
//    const struct ET_Str et = c3EvapoTrans(incident_average_par_micromol, temp, rh, windspeed, height,
//                                          initial_stomatal_conductance);
//
//    const double leaf_temperature = temp + et.Deltat;  // deg. C
//
//    // Calculate final values for assimilation, stomatal conductance, and Ci using the new leaf temperature
//    const struct c3_str photo = c3photoC(
//        incident_par_micromol, leaf_temperature, rh, vmax1, jmax,
//        Rd, b0, b1, Catm, O2, theta, StomataWS, water_stress_approach,
//        electrons_per_carboxylation, electrons_per_oxygenation);

    // Update the outputs
    update(Assim_op, Assim);
    update(GrossAssim_op, GrossAssim);
    update(Ci_op, Ci);
    update(Gs_op, Gs);
    update(TransR_op, TransR);
    update(leaf_temperature_op, leaf_temperature);
}

#endif

