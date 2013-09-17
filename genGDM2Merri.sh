#!/bin/bash

#
# Modified Wed Jan 23 2013: Just 0 and 180
# Modified Mon Sep 16 2013: new folder naming scheme
#

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM4
#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM3
#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM3
#levels="0.00 0.04 0.08 0.12 0.16 0.20 0.24 0.28" # 0 == noise
#levels="0.50" #  0.80" # practce
#levels="0 50 100" #  0.80" # practce
levels=`echo {0..100..2}`

echo "Levels $levels"
n=8  # number of each level / 4 (reps for 0,90,180,270 degrees)

##################################
# mkdir $root
##################################
\rm -rf $rootDir
mkdir $rootDir

########################
# create and submit pbs script
#   $1 == script file name
#   $2 == job name
#   $3 == level
#   $4 == orinetation
#   $5 == dirname for output
########################
function createScript() {

    echo "#!/bin/bash"                             >  $1
    echo "#SBATCH --time=6:00"                     >> $1
    echo "#SBATCH --job-name=\"$2\""               >> $1
    echo "#SBATCH --account=\"VR0280\""            >> $1
    echo "#SBATCH --ntasks=1"                      >> $1
    echo "module load R-intel/2.15.3"              >> $1
    echo "module load imagemagick-intel/6.8.6-9"   >> $1
    echo "R --slave --args $3 $4 $5 1 < GDM.r"     >> $1
    #echo "mogrify -format png $5/*.pbm"            >> $1
    sbatch $1
}

########################
# make signal patches
########################
for f in $levels
do
    dirName="$rootDir/$f"
    mkdir $dirName
    echo "Doing $f"
    for o in 0 180  # for o in 0 90 180 270
    do
        seq=`awk 'BEGIN{for(i=0;i<'"$n"';i++) printf"%3d ",i; exit}'`
        for i in $seq
        do
            if [ $o = 0 ]
            then
               dirName="$rootDir/$f/1_"$i
            else
               dirName="$rootDir/$f/2_"$i
            fi
            mkdir $dirName
            echo -n " $dirName"
        
            createScript xgdm2.sh xgdm2$f"_"$o"_"$n `echo $f/100.0 | bc -l`  $o $dirName
        done
    done
done
