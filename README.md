# Running SIMPLE

## Getting set-up on GitHub for the HPCC:

Access the HPCC via terminal:

```bash
ssh <username>@hpcc.msu.edu
```
or by going to https://ondemand.hpcc.msu.edu and clicking `dev-intel-16` under the `Development Nodes` drop-down, which will open a terminal on a new tab.
In the terminal follow the instructions under "Generating a new SSH key" to create an SSH key [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). 

Now that you have the key created you will need to run the `cat ~/.ssh/id_ed25519.pub` and copy the contents it displays (it should look like “ssh-ed25519 AAA …… email@website.com”).

Log in to GitHub and click the icon in the right hand corner and select “Settings”. Click the section labeled "SSH and GPG keys". Next, click "New SSH Key" paste the contents copied above into the box provided, and give it a good title (maybe your computer name) and an expiration date if desired.

## First Steps

***The following shoulld be done on the Lab MacBook:***

1. Download zipped data to the Desktop, unzip it, and upload it to the HPCC. This can be done in two ways:

    * **Online GUI:** Go to https://ondemand.hpcc.msu.edu and navigate to `Files` -> `Home Directory`. Here, you can navigate through the GUI to the correct folder and hit the blue `Upload` button to upload folders or files from the local computer.
    * **Terminal:** Open terminal on the MacBook and run the following. This will prompt you to enter a password for your HPCC account (same as MSU account).
      ```bash
      scp -r ~/Desktop/FileFolder <username>@hpcc.msu.edu:FileFolder
      ```
2. Access the HPCC terminal. This can also be done in two ways:

    * **HPCC Web Terminal:**: Go to https://ondemand.hpcc.msu.edu and click `Development Nodes` -> `dev-intel-16` to open a terminal on a new tab.  
    * **Local Terminal:** Open terminal on the MacBook and run the following. This will prompt you to enter a password for your HPCC account (same as MSU account).
      ```bash
      ssh <username>@hpcc.msu.edu
      ```

In my example, the data was stored as 
`/mnt/home/manneyas/BenningLab/210409_sequencing/`, which had subfolders `A`, representing the MUT files and `B` representing the WT files. Each file should have a format like `V300098986_L03_PLAujbeR032370-663_1.fq.gz`, where the `fq.gz` implies that it is a zipped fastq file and the `_1` means that it is the `R1` read.

3. Set up an analysis directory in the directory as the one containing the data folder. This can be done in two ways:

   * **Manually:** Download this GitHub repository to the MacBook as a zipped folder and unzip it. Next, rename the folder with the name of suppresor mutant. In my example, it is named as `number_twelve`. Then, upload the folder to the HPCC so that it is in the folder containing the data folder. 
   * **HPCC Web Terminal:** Navigate to the HPCC's web terminal and run the following code. (This may require SSH keys to be set-up on the HPCC).
     ```bash
     cd ~
     git clone git@github.com:yashmanne/Benning_Simple.git
     mv Benning_Simple number_twelve
     ```

## Preprocessing of Data

Keep in mind that the folder "210409_sequencing" is where I have stored my data files and should be replaced with the name of your folder containing the data. Subfolder A contains all files for the mutant and B contains all files for the WT. If your folder is not separated this way, I encourage you to do so.

Ideally, we should be able to concatenate the three separate files for each of the four read types (MUT R1, MUT R2, WT R1, WT R2) into one file for each read type by doing the following:

First, navigate to the `import_data.sh` file in the `input` folder using the "Files" -> "Home Directory" GUI on the HPCC OnDemand Dashboard. Edit the file by clicking "Edit" after hitting the three vertical dots next to each file.

Now, rename the variable `dataFolder` with the path to the folder containing the data. If your data folder is in the same repository as the base folder `number_twelve`, it should be the following:

```bash
dataFolder="../../<folder_name>"
```
Make sure to not leave a space on either end of the `=` sign.

Likewise, rename the `lineName` variable with the name of the suppressor mutant. 

Once the script is edited, run it in the terminal:

```bash
# Navigate to desired input directory of scripts to be run.
cd ./number_twelve/input
bash import_data.sh
```

**Side Note:** In the example `number_twelve` sequencing, one of the MUT R2 files was corrupted so I needed to manually go through the file and remove the corruption by doing the following:

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
cd ../number_twelve/input

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

Ex: In the `runFastqc_slurm_EMS.sb` file, you'll need to replace `cd /mnt/home/`**manneyas/BenningLab/number_twelve**`/fastQC` with `cd /mnt/home/`**\<userName>/\<folderName>**`/fastQC`. So if your username is `cookron` and the folder is `number_eleven`, the line will look like `cd /mnt/home/cookron/number_eleven/fastQC`.

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
