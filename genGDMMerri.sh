#!/bin/bash

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM3
#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM
#levels="0.00 0.04 0.08 0.12 0.16 0.20 0.24 0.28" # 0 == noise
n=3 # number of each level / 4 (reps for 0,90,180,270 degrees)

##################################
# mkdir $root
##################################
#\rm -rf $rootDir
#mkdir $rootDir

##################################
# Generate an array of orient angles, n * each value
##################################
Orient=(`awk 'BEGIN{
    #split("0 90 180 270 ", a)
    split("0 180", a)
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
    dirName=$rootDir/$f
    mkdir $dirName
    seq=`awk 'BEGIN{for(i=0;i<'"$n"'*4;i++) printf"%03d ",i; exit}'`
    for i in $seq
    do
        dirName=$rootDir/$f/$i
        mkdir $dirName
        echo -n " $dirName"

        echo "#!/bin/bash" > xgdm.sh
        echo "#PBS -l procs=1" >> xgdm.sh
        echo "#PBS -l walltime=:00:3:00" >> xgdm.sh
        echo "#PBS -N xgdm$f"_"$i" >> xgdm.sh
        echo "module load R-gcc/2.15.0" >> xgdm.sh
        echo "module load imagemagick/6.6.5-10" >> xgdm.sh
        echo "R --slave --args $f ${Orient[`echo $i | sed 's/^0*//'`]} $dirName  < GDM.r" >> xgdm.sh
        echo "mogrify -format png $dirName/*.pbm " >> xgdm.sh
        qsub -d `pwd` xgdm.sh
    done
done
