#!/bin/bash

#
# For single image GDM, so 29 folders.
#       7 * filenames level_0/n.*/frame*
#       7 * filenames level_90/n.*/frame*
#       7 * filenames level_180/n.*/frame*
#       7 * filenames level_270/n.*/frame*
#       1 * filenames n/n.*/frame*
#
#

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM3
levels="0.04 0.08 0.12 0.16 0.20 0.24 0.28" # 0 == noise
n=50  # number of each level / 4 (reps for 0,90,180,270 degrees)

##################################
# mkdir $root
##################################
#\rm -rf $rootDir
#mkdir $rootDir

########################
# create and submit pbs script
#   $1 == script file name
#   $2 == job name
#   $3 == level
#   $4 == orinetation
#   $5 == dirname for output
########################
function createScript() {
    echo "#!/bin/bash"                        >  $1
    echo "#PBS -l procs=1"                    >> $1
    echo "#PBS -l walltime=:00:6:00"          >> $1
    echo "#PBS -N $2"                         >> $1
    echo "module load R-gcc/2.15.0"           >> $1
    echo "module load imagemagick/6.6.5-10"   >> $1
    echo "R --slave --args $3 $4 $5  < GDM.r" >> $1
    echo "mogrify -format png $7            " >> $1
    qsub -d `pwd` $1
}

########################
# make signal patches
########################
## for f in $levels
## do
##     echo ""
##     echo "Doing $f"
##     for o in 0 90 180 270
##     do
##         dirName="$rootDir"/"$f"_"$o"
##         mkdir $dirName
##         seq=`awk 'BEGIN{for(i=0;i<'"$n"'*4;i++) printf"%03d ",i; exit}'`
##         for i in $seq
##         do
##             dirName="$rootDir"/"$f"_"$o"/$i
##             mkdir $dirName
##             echo -n " $dirName"
##         
##             createScript xgdm2.sh xgdm2$f"_"$o"_"$n $f $o $dirName
##         done
##     done
## done

########################
# make noise patches
########################
echo ""
echo "Doing Noise"
dirName=$rootDir/noise
mkdir $dirName
seq=`awk 'BEGIN{for(i=0;i<'"$n"'*4;i++) printf"%03d ",i; exit}'`
for i in $seq
do
    dirName=$rootDir/noise/$i
    mkdir $dirName
    echo -n " $dirName"
    for o in 0 90 180 270
    do
        createScript xgdm2.sh xgdm2n"_"$o"_"$i 0 $o $dirName
    done
done
