# Concatentae three reads of each type together. Then zip the file for storage.

# Rename data folder

dataFolder="../../210409_sequencing"

# mut R1

gunzip -c $dataFolder/A/*L02*_1* $dataFolder/A/*L03*_1* $dataFolder/A/*L04*_1* > number_twelve.mut.R1.fastq

gzip number_twelve.mut.R1.fastq

# mut R2

gunzip -c $dataFolder/A/*L02*_2* $dataFolder/A/*L03*_2* $dataFolder/A/*L04*_2* > number_twelve.mut.R2.fastq

gzip number_twelve.mut.R2.fastq

# wt R1

gunzip -c $dataFolder/B/*L02*_1* $dataFolder/B/*L03*_1* $dataFolder/B/*L04*_1* > number_twelve.wt.R1.fastq

gzip number_twelve.wt.R1.fastq

# wt R2

gunzip -c $dataFolder/B/*L02*_2* $dataFolder/B/*L03*_2* $dataFolder/B/*L04*_2* > number_twelve.wt.R2.fastq

gzip number_twelve.wt.R2.fastq
