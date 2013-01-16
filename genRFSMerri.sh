#!/bin/bash

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_Aspect

\rm -rf $rootDir
mkdir $rootDir

n=50
levels="2 4 8 16 32"

seq=`awk 'BEGIN{for(i=1;i<='"$n"';i++) print i; exit}'`

########################
# create and submit pbs script
#   $1 == script file name
#   $2 == job name
#   $3 == level
#   $4 == target RF
#   $5 == distractor RF
#   $6 == radius
#   $7 == output file
########################
function createScript() {
    echo "#!/bin/bash"                               >  $1
    echo "#PBS -l procs=1"                           >> $1
    echo "#PBS -l walltime=:00:2:00"                 >> $1
    echo "#PBS -N $2"                                >> $1
    echo "module load R-gcc/2.15.0"                  >> $1
    echo "R --slave --args $3 $4 $5 $6 < RFS.r > $7" >> $1
    qsub -d `pwd` $1
}

#####################################################
# make n*|levels| signal and n distractor patches
#####################################################
for i in $seq
do
    echo "Number $i"
    for j in $levels
    do
        createScript xrfs.sh xrfs$j"_"$i $j 3 4 1 $rootDir/s"$j"_"$i".pgm
        createScript xrfs.sh xrfs$j"_"$i $j 4 4 1 $rootDir/n"$j"_"$i".pgm
    done
done
