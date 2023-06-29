# BioCro-ePhotosynthesis
Coupled BioCro and ePhotosynthesis (C++) through linking dynamic libraries.

Tested on `MacOS 11.3.1` with `x86_64-apple-darwin13.4.0-clang` and `linux` on biocluster with `GCC/.8.2.0`
### Prerequisites: 
- miniconda/anaconda - (optional but recommended)
- R
- BioCro
- ePhotosynthesis(C++)
- cmake

### Clone this repository
```
git clone https://github.com/Matthews-Research-Group/BioCro-ePhotosynthesis.git --recursive
```
If you forgot the --recursive the flag, you can do this to get the submodules,
```
git submodule update --init
```

### Building
- build the ePhotosynthesis C++ version. (Make sure to build the version on the branch **SoybeanParameterization**)
  ```
  cd models/ePhotosynthesis_C
  ```
  The ePhotosynthesis C++ uses CMAKE to manage the compilation. Please follow the README on its Github page to install the package. I suggest to use Conda to do this, which should be much easier. If successful, You should see a file named **libePhotosynthesis.dylib** or **libePhotosynthesis.so** in the **build** folder. This file is needed for the BioCro build in the next step.
- build the BioCro
  ```
  cd models/biocro-dev
  ```
   Now, edit the following variables in the src/Makevars file, 
   
   - **boost_path** (where you installed the boost)
   - **sundial_path** (where you installed the sundial)
   - **ephoto_path** (the ephotosynthesis source code folder)

   ```
   #go back to models/biocro-dev
   R CMD INSTALL .
   ```
   If successful, you should see an R pakcage named **BioCroEphoto**.
### Running
Go back to the parent folder **BioCro-ePhotosynthesis**,
```
Rscript run_biocro_ephoto.R
```
This is just an example R script to run scenarios with different climate inputs. You should modify it or have your R script to run your own scenarios.
