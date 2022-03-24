# Running SIMPLE

## Getting set-up on GitHub:
In the command line utility of your choice follow the instructions under "Generating a new SSH key" to create an SSH key [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). 

Now that you have the key created you will need to run the `cat ~/.ssh/id_ed25519.pub` and copy the contents it displays (it should look like “ssh-ed25519 AAA …… email@website.com”).

Log in to GitHub and click the icon in the right hand corner and select “Settings”. Click the section labeled "SSH and GPG keys". Next, click "New SSH Key" paste the contents copied above into the box provided, and give it a good title (maybe your computer name) and an expiration date if desired.

## First Steps
On the Lab MacBook:

Download data to the Desktop and then copy to the HPCC. Copying can be done by opening terminal and run:
```bash
scp ~/Desktop/FileFolder <username>@hpcc.msu.edu:FileFolder
```
This will prompt you to enter a password for your HPCC account.

Next, access the HPCC via terminal:

```bash
ssh <username>@hpcc.msu.edu
```
or by going to https://ondemand.hpcc.msu.edu and clicking `dev-intel-16` under the `Development Nodes` drop-down, which will open a terminal on a new tab.

In my example, the data was stored as 
`/mnt/home/manneyas/BenningLab/210409_sequencing/`, which had subfolders `A`, representing the MUT files and `B` representing the WT files. Each file should have a format like `V300098986_L03_PLAujbeR032370-663_1.fq.gz`, where the `fq.gz` implies that it is a zipped fastq file and the `_1` means that it is the `R1` read.

Now, make a separate folder for analysis in the same directory as the directory containing the raw data files. Make subfolders for input, scripts, archive, refs, and fastQC. 

```bash 
mkdir ./number_twelve/ # name of folder to do analysis in
cd number_twelve
mkdir input
mkdir scripts
mkdir refs
mkdir archive
mkdir fastQC
mkdir output
```

Alternatively, you can download this repository directly that contains all the subfolders and scripts in place and rename the repository as the line. In my example, it is named as `number_twelve` as shown below. 

```bash
cd ~
git clone https://github.com/yashmanne/Benning_Simple.git
mv Benning_Simple number_twelve
```

## Preprocessing of Data

Ideally, we should be able to concatenate the three separate files for each of the four read types (MUT R1, MUT R2, WT R1, WT R2) into one file for each read type by doing the following:

```bash
# Navigate to desired input directory of scripts to be run.
cd ./number_twelve/input

# Concatentae three reads of each type together. Then zip the file for storage.
# mut R1
gunzip -c ../../210409_sequencing/A/*L02*_1* ../../210409_sequencing/A/*L03*_1* ../../210409_sequencing/A/*L04*_1* > number_twelve.mut.R1.fastq
gzip number_twelve.mut.R1.fastq

# mut R2
gunzip -c ../../210409_sequencing/A/*L02*_2* ../../210409_sequencing/A/*L03*_2* ../../210409_sequencing/A/*L04*_2* > number_twelve.mut.R2.fastq
gzip number_twelve.mut.R2.fastq

# wt R1
gunzip -c ../../210409_sequencing/B/*L02*_1* ../../210409_sequencing/B/*L03*_1* ../../210409_sequencing/B/*L04*_1* > number_twelve.wt.R1.fastq
gzip number_twelve.wt.R1.fastq

# wt R2
gunzip -c ../../210409_sequencing/B/*L02*_2* ../../210409_sequencing/B/*L03*_2* ../../210409_sequencing/B/*L04*_2* > number_twelve.wt.R2.fastq
gzip number_twelve.wt.R2.fastq
```

In the case of the our sample sequencing, one of the MUT R2 files was corrupted so I needed to manually go through the file and remove the corruption:

```bash
# navigate to folder with files
cd 210409_sequencing/A

# unzip files and move files to separate folder
mkdir ../mut/
gunzip -k *.gz
mv *.fq ../mut
cd ../mut

# edit corrupted file
head -69323007 V300098986_L03_PLAujbeR032370-663_2.fq -> V300098986_L03_PLAujbeR032370-663_2_Uncorrupted.fq

# navigate to input directory of scripts to be run
cd cd ./number_twelve/input

# concatenate files and zip to make the MUT R2.
cat ../../210409_sequencing/mut/V300098986_L02_PLAujbeR032370-663_2.fq ../../210409_sequencing/mut/V300098986_L03_PLAujbeR032370-663_2_Uncorrupted.fq ../../210409_sequencing/mut/V300098986_L04_PLAujbeR032370-663_2.fq > number_twelve.mut.R2.fastq
gzip number_twelve.mut.R2.fastq
```

## Scripts
Scripts can be found in the scripts folder of this repository. Here are the main scripts to run in the following order.

1. `runFastqc_slurm_EMS.sb` (optional)
2. `getReferences_Arabidopsis.sb`
3. `runBwaMem2Index_slurm_ArabidopsisEMS.sb`
4. `runBwaMem2Aln_slurm_ArabidopsisEMS.sb`
5. `runSamtoolsSamToBam_slurm_ArabidopsisEMS.sb`
6. `runSamtoolsBam_Sort_IndexEMS.sb`
7. `runSamtoolsMarkDuplicatesEMS.sb`

Before running each script, you'll need to replace the first line that tells the software where files are located with with your own file path:

Ex: In the `runFastqc_slurm_EMS.sb` file, you'll need to replace `cd /mnt/home/manneyas/BenningLab/number_twelve/fastQC` with `cd /mnt/home/cook/number_twelve/fastQC`.

Each script can be edited by going to https://ondemand.hpcc.msu.edu/, and clicking `Home Directory` under the `Files` drop-down. Then, navigate to the desired script and hit `Edit` under the three dots drop-down for the file you want to edit. A new tab will allow you to edit the file and you can save the file by hitting the `Save` button on the top left.


Each script can be run by using:
```bash
# navigate to scripts folder
cd ./scripts/
sbatch <script_name>
``` 

Once the script is ran, its progress can be checked by the following:

```bash 
squeue -lu <username>
```

Run each script only after the previous one has finished. 

Once all scripts are complete. Move files to output:

```bash
cd number_twelve
scp ./archive/EMS* ./output
scp EMS* ./output
```

## Running SIMPLE
Once all the output files have been generated, copy the output files from the HPCC to the Lab Macbook by doing the following:

1. Open up terminal.
2. Navigate to desktop by doing `cd ~/Desktop/`
3. `scp -r <username>@hpcc.msu.edu:number_twelve/output ./` 
4. Go run a PCR while files download (can take close to an hour)

Once all the files have transferred, download [Simple](https://github.com/wacguy/Simple) to your desktop and unzip. Go to the `simple_variables.sh` file and change the line variable from “EMS” to your line desired name. 

Next, copy all files in the output folder to the the `Simple/output` folder.

Now, in `Simple/scripts/`, replace the `simple.sh` with the `simple.sh` file present in the `scripts` folder of this repository:

```bash
cd ~/Desktop/Simple/scripts/
scp <username>@hpcc.msu.edu:number_twelve/scripts/simple.sh ./simple.sh
```

Now, SIMPLE is ready to run by doing the following on the MacBook:

```bash
cd ~/Desktop/Simple
chmod +x ./scripts/simple.sh
./scripts/simple.sh
```

Come back in a day and it should be ready. Congrats, now you get to do the fun stuff!
