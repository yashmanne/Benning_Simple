### collect data 
cd ./scripts
### argument to say whether or not to collect data.
arg=$1
if [ $arg = "data" ]
then
    ### if data is already present in ./input folder
    # exists for cases where modifications need to be made
    echo "Data is preloaded and starting pipeline!"
    sbatch getReferences_Arabidopsis.sb
else
    ### if need to collect data:
    echo "Importing data!"
    sbatch import_data.sb
fi
