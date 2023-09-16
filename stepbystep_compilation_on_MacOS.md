## Platform: Macbook Pro 14-inch, MacOS Monterey 12.5, Apple M1 Pro
(Overall, this was not a smooth solution. If you don't have an Apple Chip or use Linux, you may not encounter so many issues.)

**Install xcode first!**
Below is like a code recording of what I did on my machine.

```
#you may need to change the folder path to avoid permission issue if on a cluster 
conda create -n ephoto
conda activate ephoto

#in my case, the ephotosynthesis' dylink was compiled in x86_64. I don't know why it does not use arm64.
#Maybe there's some setting in the cmake file. I tried but it did not work.
#This means, the biocro also needs to be installed under x86_64. For that, we first need the R base to be in x86_64. T_T
#my default R base was in arm64, so I used conda to just install a new R base, which fortunately was in x86_64.
#Also, we need to do this now before the other installation. Otherwise it would give conflicts T_T
conda install -c conda-forge r-base=4.1.2

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
```
Now, we can install the BioCro-ePhotosynthesis by compiling the BioCro R package.

Go to **biocro-dev**.

Now, edit the following variables in the src/Makevars file, 
   - **boost_path** (where you installed the boost)
   - **sundial_path** (where you installed the sundial)
   - **ephoto_path** (the ephotosynthesis source code folder)

Also, link your ePhotosynthesis' library to your conda environment. I did the following:
```
cd /Users/yufeng/miniconda3/envs/ephoto/lib/  #this is where my conda lib files are
ln -sf /Users/yufeng/Desktop/UIUC/Research/Github/BioCro-ePhotosynthesis/models//ePhotosynthesis_C/build/libEPhotosynthesis.dylib .
```
Now, go to **biocro-dev**.
```
R CMD INSTALL .
```
You should see an R pakcage named **BioCroEphoto**. This means you can use it in R now!
