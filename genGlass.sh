#!/bin/bash

root=Glass
sDir=signal     # signal images in    $root/$sDir
nDir=nosignal   # no signal images in $root/$nDir
n=200           # number of each
levels="0.08 0.16 0.24 0.32 0.40 0.48 0.52"

##################################
# mkdirs
##################################
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
        R --slave --args $f a < glass.r > $root/$sDir/"$f"_"$i".pbm
    done
done

###########################
# make 0 signal patches
###########################
for i in $seq
do
    echo -n " $i"
    R --slave --args 0 a < glass.r > $root/$nDir/n_"$i".pbm
done
