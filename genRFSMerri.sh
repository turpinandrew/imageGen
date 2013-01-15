#!/bin/bash

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS

\rm -rf $rootDir
mkdir $rootDir

n=200
seq=`awk 'BEGIN{for(i=1;i<='"$n"';i++) print i; exit}'`
levels="2 4 8 16 32"

#####################################################
# make n*|levels| signal and n distractor patches
#####################################################
for i in $seq
do
    echo "Number $i"
    for j in $levels
    do
        echo "#!/bin/bash" > xrfs.sh
        echo "#PBS -l procs=1" >> xrfs.sh
        echo "#PBS -l walltime=:00:02:00" >> xrfs.sh
        echo "#PBS -N xrfs$j"_"$i" >> xrfs.sh
        echo "module load R-gcc/2.15.0" >> xrfs.sh
        echo "R --slave --args $j 3 4 30 < RFS.r > $rootDir/s"$j"_"$i".pgm " >> xrfs.sh
        qsub -d `pwd` xrfs.sh

        echo "#!/bin/bash" > xrfs.sh
        echo "#PBS -l procs=1" >> xrfs.sh
        echo "#PBS -l walltime=:00:02:00" >> xrfs.sh
        echo "#PBS -N xrfs$j"_"$i" >> xrfs.sh
        echo "module load R-gcc/2.15.0" >> xrfs.sh
        echo "R --slave --args $j 4 4 30 < RFS.r > $rootDir/n"$j"_"$i".pgm " >> xrfs.sh
        qsub -d `pwd` xrfs.sh
    done
done
