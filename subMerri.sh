#!/bin/bash

module load R-gcc/2.15.0

n=1
for trial in `awk 'BEGIN{for(i=1;i<='"$n"';i++) printf"%03d ",i; exit}'`
do
   for level in 0 0.04 0.08 0.12 0.16 0.20 0.24 0.28
   do
      echo "#!/bin/bash" > x
      echo "srun --cpus-per-task=1 --time=0:00:30 ./genGDM $trial $level" >> x
      sbatch --cpus-per-task=1 --time=0:00:30 --job-name=genGDM$trial --time=0:00:30 ./x
   done
done

