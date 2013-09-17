#!/bin/bash

rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM5
#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/GDM
#levels="0.00 0.04 0.08 0.12 0.16 0.20 0.24 0.28" # 0 == noise
#levels="0.00 0.04"
levels=`awk 'BEGIN{for(i=0;i<1.01;i+=0.02) printf"%04.2f ",i; exit}'`
n=100 # number of each level /2 (for 0 180) # / 4 (reps for 0,90,180,270 degrees)

##################################
# mkdir $root
##################################
\rm -rf $rootDir
mkdir $rootDir

##################################
# Generate an array of orient angles, n * each value
##################################
#Orient=(`awk 'BEGIN{
#    #split("0 90 180 270 ", a)
#    split("0 180", a)
#    for(j in a)
#        for(i=1;i<='"$n"';i++) 
#            printf"%d ",a[j]
#    exit}'`)
#
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
    dirname=$rootDir/$f
    mkdir $dirname

    echo "#!/bin/bash" > xgdm.sh
    echo "#PBS -l procs=1" >> xgdm.sh
    echo "#PBS -l walltime=:03:3:00" >> xgdm.sh
    echo "#PBS -N xgdm$f"_"$i" >> xgdm.sh
    echo "module load R-gcc/2.15.0" >> xgdm.sh
    echo "module load imagemagick/6.6.5-10" >> xgdm.sh

    seq=`awk 'BEGIN{for(i=0;i<'"$n"';i++) printf"%03d ",i; exit}'`
    for i in $seq
    do
      mkdir $dirname/"1_"$i
      mkdir $dirname/"2_"$i
      echo "R --slave --args $f   0 $dirname/"1_"$i 1 < GDM.r" >> xgdm.sh
      echo "R --slave --args $f 180 $dirname/"2_"$i 1 < GDM.r" >> xgdm.sh
      echo "mogrify -format png     $dirname/"1_"$i/*.pbm " >> xgdm.sh
      echo "mogrify -format png     $dirname/"2_"$i/*.pbm " >> xgdm.sh
    done

    qsub -d `pwd` xgdm.sh
    sleep 2s
done
