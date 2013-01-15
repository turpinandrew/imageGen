#!/bin/bash

rootDir=GDM
levels="0.00 0.04 0.08 0.12 0.16 0.20 0.24 0.28" # 0 == noise
n=10  # number of each level / 4 (reps for 0,90,180,270 degrees)

##################################
# mkdir $root
##################################
mkdir $rootDir

##################################
# Generate an array of orient angles, n * each value
##################################
Orient=(`awk 'BEGIN{
    split("0 90 180 270", a)
    for(j in a)
        for(i=1;i<='"$n"';i++) 
            printf"%d ",a[j]
    exit}'`)

#echo ${Orient[@]}
#echo ${Orient[0]}
#echo ${Orient[39]}
#exit

########################
# make patches
########################
for f in $levels
do
    echo ""
    echo "Doing $f"
    seq=`awk 'BEGIN{for(i=0;i<'"$n"'*4;i++) printf"%03d ",i; exit}'`
    for i in $seq
    do
        dirName="$rootDir"/"$f"_"$i"
        echo -n " $dirName"

        R --slave --args $f ${Orient[`echo $i | sed 's/^0*//'`]}  < GDM.r

        mkdir $dirName
        mv frame_*.pbm $dirName
    done
done
