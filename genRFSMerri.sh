#!/bin/bash


#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_Aspect  # Jan 2013
#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_Wide    # Jan 2013
#rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_bigImage # Mon Feb 25 16:15:10 EST 2013
rootDir=/vlsci/VR0052/aturpin/doc/papers/merp/src/imageGen/RFS_bigImage2 # Mon Feb 25 21:56:36 EST 2013

\rm -rf $rootDir
mkdir $rootDir

n=100
levels="32 16 08 04 02"

########################
# create and submit pbs script
#   $1 == script file name
#   $2 == job name
#   $3 == output dir
#   $4 == number of sub-images per file/bigImage
#   $5 == level
#   $6 == s or n
########################
function createScript() {
    echo "#!/bin/bash"                               >  $1
    echo "#PBS -l procs=1"                           >> $1
    echo "#PBS -l walltime=:12:15:00"                >> $1
    echo "#PBS -N $2"                                >> $1
    echo "module load R-gcc/2.15.0"                  >> $1
    echo "module load imagemagick/6.6.5-10"          >> $1
    if [ $6 == "s" ]
    then
      echo "R --slave --args $5 3 4 1 $4 < RFS.r | mogrify -format png - > $3/s"$5".png " >> $1
    else
      echo "R --slave --args $5 4 4 1 $4 < RFS.r | mogrify -format png - > $3/n"$5".png " >> $1
    fi

    qsub -d `pwd` $1
}

#####################################################
# make 2 big images per level: signal and noise
#####################################################
for i in $levels
do
    echo "Level $i"
    createScript zrfs.sh zrfsS$i $rootDir $n $i s
    sleep 2s
    createScript zrfs.sh zrfsN$i $rootDir $n $i n
    sleep 2s
done
