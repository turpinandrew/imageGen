#!/bin/bash

root=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/Glass_temp
n=3           # number of each
#levels="0.08 0.16 0.24 0.32 0.40 0.48 0.52"
levels="0.80"

##################################
# mkdirs
##################################
\rm -rf $root
mkdir $root

seq=`awk 'BEGIN{for(i=1;i<='"$n"';i++) printf"%03d ",i; exit}'`

########################
# make signal patches
########################
for f in $levels
do
    mkdir $root/$f
    echo "Doing $f"
    for i in $seq
    do
        echo -n " $i"
        echo "#!/bin/bash" > xglass.sh
        echo "#PBS -l procs=1" >> xglass.sh
        echo "#PBS -l walltime=:00:10:00" >> xglass.sh
        echo "#PBS -N xglass$f"_"$i" >> xglass.sh
        echo "module load R-gcc/2.15.0" >> xglass.sh
        echo "module load imagemagick/6.6.5-10" >> xglass.sh
        echo "R --slave --args $f a < glass.r > $root/$f/$i.pbm" >> xglass.sh
        echo "mogrify -format png $root/$f/$i.pbm" >> xglass.sh
        qsub -d `pwd` xglass.sh
    done
done

###########################
# make 0 signal patches
###########################
#mkdir $root/noise
#for i in $seq
#do
#    echo -n " $i"
#    echo "#!/bin/bash" > xglass.sh
#    echo "#PBS -l procs=1" >> xglass.sh
#    echo "#PBS -l walltime=:00:10:00" >> xglass.sh
#    echo "#PBS -N xglass0"_"$i" >> xglass.sh
#    echo "module load R-gcc/2.15.0" >> xglass.sh
#    echo "module load imagemagick/6.6.5-10" >> xglass.sh
#    echo "R --slave --args 0 a < glass.r > $root/noise/$i.pbm" >> xglass.sh
#    echo "mogrify -format png $root/noise/$i.pbm" >> xglass.sh
#    qsub -d `pwd` xglass.sh
#done
