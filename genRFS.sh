#!/bin/bash

rootDir=RFS

n=9
seq=`awk 'BEGIN{for(i=1;i<='"$n"';i++) print i; exit}'`
levels="2 4 8 16 32"

#####################################################
# make n*|levels| signal and distractor patches
#####################################################
for i in $seq
do
    echo "Number $i"
    for j in $levels
    do
        echo -n " $j"
        R --slave --args $j 3 4 30 < RFS.r > $rootDir/s"$j"_"$i".pgm &
        R --slave --args $j 4 4 30 < RFS.r > $rootDir/n"$j"_"$i".pgm 
    done
done
