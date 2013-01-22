#!/bin/bash


#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_Aspect
rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_Wide

\rm -rf $rootDir
mkdir $rootDir

n=1
levels="02"  #  04 08 16 32"

seq=`awk 'BEGIN{for(i=1;i<='"$n"';i++) print i; exit}'`

########################
# create and submit pbs script
#   $1 == script file name
#   $2 == job name
#   $3 == output dir
########################
function createScript() {
    echo "#!/bin/bash"                               >  $1
    echo "#PBS -l procs=8"                           >> $1
    echo "#PBS -l walltime=:00:10:00"                >> $1
    echo "#PBS -N $2"                                >> $1
    echo "module load R-gcc/2.15.0"                  >> $1
    echo "module load imagemagick/6.6.5-10"          >> $1
    echo "w="                                        >> $1
    for j in $levels
    do
      echo "R --slave --args $j 3 4 1 < RFS.r > $3/s"$j"_"$i".pgm &" >> $1
      echo "w=\"\$w  \$!\"" >> $1
      echo "R --slave --args $j 4 4 1 < RFS.r > $3/n"$j"_"$i".pgm &" >> $1
      echo "w=\"\$w  \$!\"" >> $1
    done
    echo "wait \$w" >> $1
    echo "mogrify -format png $3/*.pgm             " >> $1
    #echo "rm $3/*.pgm                              " >> $1
    qsub -d `pwd` $1
}

#####################################################
# make n*|levels| signal and n distractor patches
#####################################################
for i in $seq
do
    echo "Number $i"
    createScript xrfs.sh xrfs$i $rootDir
done
