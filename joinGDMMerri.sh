#!/bin/bash

#PBS -l procs=1
#PBS -l walltime=0:10:3:00
#PBS -N ygdmJoin

module load R-gcc/2.15.0
module load imagemagick/6.6.5-10

#
# Take GDM frames and join into one big image
#  - repeats horizontal
#  - frames vertical
#

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM3

for level in 0.00 0.04_0 0.04_180 0.08_0 0.08_180 0.12_0 0.12_180 0.16_0 0.16_180 0.20_0 0.20_180 0.24_0 0.24_180 0.28_0 0.28_180 0.50_0 0.50_180 0.80_0 0.80_180
do
   echo $level
   #touch $rootDir/$level.png
   for fr in 1 2 3 4 5 6 7 8
   do
      convert $rootDir/$level/*/frame"_"$fr".png" +append $rootDir/temp$fr.png
   done
   convert $rootDir/temp*.png -append $rootDir/$level.png
   \rm $rootDir/temp*.png 
done
