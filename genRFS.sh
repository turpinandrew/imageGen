#!/bin/bash

rootDir=RFS_wide

n=40
seq=`awk 'BEGIN{for(i=21;i<='"$n"';i++) print i; exit}'`
levels="02 04 08 16 32"

#####################################################
# make n*|levels| signal and distractor patches
#####################################################
for i in $seq
do
    echo "Number $i"
    for j in $levels
    do
        echo -n " $j"
        R --slave --args $j 3 4 1 < RFS.r > $rootDir/s"$j"_"$i".pgm # &
        w="$!"
        R --slave --args $j 4 4 1 < RFS.r > $rootDir/n"$j"_"$i".pgm 
        wait $w

        mogrify -format png $rootDir/s"$j"_"$i".pgm # &
        w="$!"
        mogrify -format png $rootDir/n"$j"_"$i".pgm 
        wait $w

        rm $rootDir/*.pgm
    done
done
