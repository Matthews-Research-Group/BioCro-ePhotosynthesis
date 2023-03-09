# BioCro-ePhotosynthesis
Coupled BioCro and ePhotosynthesis(C++) through linking the dynamic library.

Tested on `MacOS 11.3.1` with `x86_64-apple-darwin13.4.0-clang` and `linux` on biocluster with `GCC/.8.2.0`
### Prerequisites: 
- miniconda/anaconda - (optional but recommended)
- R
- ccache - (optional)
- cmake
- [BioCro](https://github.com/cropsinsilico/BioCro-ePhotosynthesis/tree/biocro-ephoto-YH)
- yggdrasil - (optional. This is needed for compilation only if some BioCro modules require it)
- [ePhotosynthesis(C++)](https://github.com/cropsinsilico/ePhotosynthesis_C/tree/C3-leaf-model_ori) 
### Building
- build the ePhotosynthesis C++ version. (Make sure to build the version on the branch **SoybeanParameterization**)
  
  If successful, You should see a file named **libePhotosynthesis.dylib** or **libePhotosynthesis.so** in the **build** folder.
- build the BioCro. (Make sure to build the version on the branch **biocro-ephoto-YH**)
  ```
  git clone --recurse-submodules https://github.com/cropsinsilico/BioCro-ePhotosynthesis.git
  git checkout biocro-ephoto-YH
  git submodule update --recursive
  cd models/biocro-dev
  ```
   Now, edit the following variables in the src/Makevars file, 
   
   **conda_path** (where you installed the boost, sundial, etc), **ephoto_path** (the ephoto folder)
   
   **C_compiler, CPP_compiler**
   ```
   #go back to models/biocro-dev
   R CMD INSTALL .
   ```
### Running
Go back to the parent folder **BioCro-ePhotosynthesis**,
```
Rscript test_ephoto.R
```
