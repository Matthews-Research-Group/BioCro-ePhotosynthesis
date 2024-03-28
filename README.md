# BioCro-ePhotosynthesis
Coupled BioCro (with the new skeleton module library) and ePhotosynthesis (C++) through linking dynamic libraries. 

Tested on `MacOS 11.3.1` with `x86_64-apple-darwin13.4.0-clang` and `linux` on biocluster with `GCC/.8.2.0`

On Biocluster, my personal conda environment is called `ephoto`.

### Prerequisites: 
- miniconda/anaconda - (Required now since some library paths rely on conda environment variables)
- R
- cmake

### Clone this repository
```
git clone https://github.com/Matthews-Research-Group/BioCro-ePhotosynthesis.git --recursive
```
If you forgot the --recursive the flag, you can do this to get all submodules,
```
git submodule update --init --recursive
```

### Building
- First of all, create a conda environment called `ephoto`
  Unfortunately, the fixed naming here is required. Usually, I can use $CONDA_PREFIX to get the conda path. However, on clusters, the conda's main path is usually differernt from the user's customized path. Having a fixed environment name makes sure the program can always locate the conda path where we install the specific packages for this project.
- build the ePhotosynthesis C++ version in a conda environment
  ```
  #go to models/ePhotosynthesis_C
  mkdir build
  cmake ..
  make
  ```
  The ePhotosynthesis C++ uses CMAKE to manage the compilation. Please see more details from the README on its [Github page](https://github.com/cropsinsilico/ePhotosynthesis_C) to install the package. I suggest to use Conda to do this, which should be much easier. In conda, you can easily install boost, sundials, and cmake, which are required for installing the ePhotosynthesis C++.

  If successful, You should see a file named **libePhotosynthesis.dylib** or **libePhotosynthesis.so** in the **build** folder. This file is needed for the BioCro (ePhotosynthesis) build in the next step.
- build the BioCro and the BioCro (ePhotosynthesis) module library

  We are now using the new skeleton module library framework. This means the BioCro version that couples the ePhotosynthesis is on a separate repository. I personally like it a lot since there are much less files in the folder now.

  To do this, we need to first install the public version of the [BioCro](https://github.com/biocro/biocro). To be consistent with the version that we used in the in silico Plants paper, you may want to check out at [c98a8281](https://github.com/biocro/biocro/commit/c98a8281d11955bb2d2966503b7c927ded18f800). You can use `git checkout c98a8281` after you cloned the BioCro repository.
  ```
   #now go to models/BML-ePhotosynthesis, and run
   R CMD INSTALL .
  ```
  If successful, you should see two R pakcages named **BioCro** and **BMLePhoto**.
### Running
Go back to the parent folder **BioCro-ePhotosynthesis**,
```
Rscript run_biocro_ephoto.R
```
This is just an example R script to run scenarios with different climate inputs. You should modify it or have your R script to run your own scenarios.
