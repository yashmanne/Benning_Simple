#!/bin/bash -login

# set up pipeline of jobs. 
# Usage: 
# ./pipeline n
# where n is the number of pipeline instances.


#(1) Submit and run one instance.
if [ $1 -eq 1 ]
then
   # first task - no dependencies
   jid1=`sbatch array.sb |cut -d " " -f 4`       # note: array.sb is an jobs scritp. 
   # second task that depends on the first task
   sbatch --export=jid1=$jid1 --dependency=afterany:$jid1 checkarray.sb   # submit second dependent job
   exit 0
fi


#(2) Array job case

if [ $1 -gt 1 ]
then
   # submit first array tasks - no dependencies
   jid1=`sbatch --array=1-$1 array.sb |cut -d " " -f 4`       # note: array.sb is an jobs scritp. 
   # second task that depends on the first task
   sbatch --array=1-$1 --export=jid1=$jid1 --dependency=aftercorr:$jid1 checkarray.sb   # submit second dependent job
   exit 0
fi
