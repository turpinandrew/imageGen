#!/bin/bash

root=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/Glass
sDir=signal     # signal images in    $root/$sDir
nDir=nosignal   # no signal images in $root/$nDir
n=200           # number of each
levels="0.08 0.16 0.24 0.32 0.40 0.48 0.52"

##################################
# mkdirs
##################################
\rm -rf $root
mkdir $root
mkdir $root/$sDir
mkdir $root/$nDir

seq=`awk 'BEGIN{for(i=1;i<='"$n"';i++) printf"%03d ",i; exit}'`

########################
# make signal patches
########################
for f in $levels
do
    echo "Doing $f"
    for i in $seq
    do
        echo -n " $i"
        echo "#!/bin/bash" > xglass.sh
        echo "#PBS -l procs=1" >> xglass.sh
        echo "#PBS -l walltime=:00:10:00" >> xglass.sh
        echo "#PBS -N xglass$f"_"$i" >> xglass.sh
        echo "module load R-gcc/2.15.0" >> xglass.sh
        echo "R --slave --args $f a < glass.r > $root/$sDir/s"$f"_"$i".pbm" >> xglass.sh
        qsub -d `pwd` xglass.sh
    done
done

###########################
# make 0 signal patches
###########################
for i in $seq
do
    echo -n " $i"
    echo "#!/bin/bash" > xglass.sh
    echo "#PBS -l procs=1" >> xglass.sh
    echo "#PBS -l walltime=:00:10:00" >> xglass.sh
    echo "#PBS -N xglass$f"_"$i" >> xglass.sh
    echo "module load R-gcc/2.15.0" >> xglass.sh
    echo "R --slave --args 0 a < glass.r > $root/$nDir/n_"$i".pbm" >> xglass.sh
    qsub -d `pwd` xglass.sh
done
