Platform: Macbook Pro 14-inch, MacOS Monterey 12.5, Apple M1 Pro
(Overall, this was not a smooth solution. If you don't have an Apple Chip or use Linux, you may not encounter so many issues.)

Install xcode first!

conda create -n ephoto #you may change the folder path to avoid permission issue

conda activate ephoto

#in my case, the ephotosynthesis' dylink was compiled in x86_64. I don't know why it does not use arm64. Maybe there's some setting in the cmake file. I tried but it did not work. This means, the biocro also needs to be installed under x86_64. For that, we first need the R base to be in x86_64. T_T
#my default R base was in arm64, so I used conda to just install a new R base, which fortunately was in x86_64.
#Also, we need to do this now before the other installation. Otherwise it would give conflicts T_T

a install -c conda-forge r-base=4.1.2

conda install -c conda-forge boost
conda install -c conda-forge sundials=5.7.0 #unfortunately, the lastest version (6.6.1) is incompatible!
conda install -c anaconda cmake

#now go to ephotosynthesis folder
#what's weird on my Mac is that in a conda environment, the c++ compiler has some issue 
#with the header files. What I did was to remove the conda environment's compiler setting:
unset CPATH
unset CPPFLAGS
unset CXX      #may not be needed
unset CXXFLAGS #may not be needed

mkdir build
cd build
cmake ..
make


