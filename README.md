# Running SIMPLE

## Getting set-up on GitHub for the HPCC:

**Please note that this step is only neccessary if you plan to edit scripts and have access to this repository as a collaborator.**

0. Create a GitHub account [here](https://github.com/).
1. Access the HPCC by going to https://ondemand.hpcc.msu.edu and clicking `dev-intel-16` under the `Development Nodes` drop-down, which will open a terminal on a new tab.
2. In the terminal follow the instructions under "Generating a new SSH key" to create an SSH key [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). 
3. Now that you have the key created you will need to run the `cat ~/.ssh/id_ed25519.pub` and copy the contents it displays (it should look like “ssh-ed25519 AAA …… email@website.com”).
4. Log in to [GitHub](https://github.com/) and click the icon in the right hand corner and select “Settings”. Click the section labeled "SSH and GPG keys". Next, click "New SSH Key" paste the contents copied above into the box provided, and give it a good title (maybe your computer name) and an expiration date if desired.

## First Steps

***The following should be done on the Lab MacBook:***

1. Download the zipped data folder to the Desktop and unzip it. Verify that it contains two subfolders called `A` and `B`, where `A` contains the sequencing files for the MUT reads, and `B` contains the sequencing files for the WT reads. Each file should have a format like `V300098986_L03_PLAujbeR032370-663_1.fq.gz`, where the `L03` indicates that the file is from sequencing lane 3, the `_1` means that it is the `R1` read, and the `fq.gz` implies that it is a zipped fastq file. The current sequencing company splits reads across 3 lanes and these three files must be joined together in increasing order by the lane. For example, if the lanes are `L02`, `L03`, and `L04`, we must join `L02`->`L03`->`L04` such that `L02` is the beginning and `L04` is the end. The following script will ideally concatenate the three separate files for each fo the four read types: MUT R1, MUT R2, WT R1, and WT R2.
   
2. Once we check that the data is formatted correctly, upload the data folder to the HPCC. This can be done in two ways:

    * **Online GUI:** Go to https://ondemand.hpcc.msu.edu and navigate to `Files` -> `Home Directory`. Here, you can navigate through the GUI to the correct folder and hit the blue `Upload` button to upload folders or files from the local computer.
    * **Terminal:** Open terminal on the MacBook and run the following. This will prompt you to enter a password for your HPCC account (same as MSU account).
      ```bash
      scp -r ~/Desktop/DataFolder <username>@hpcc.msu.edu:<DataFolder>     # replace <>'s with your MSU username and the name of your data folder
      ```
3. Access the HPCC terminal. This can also be done in two ways:

    * **HPCC Web Terminal:**: Go to https://ondemand.hpcc.msu.edu and click `Development Nodes` -> `dev-intel-16` to open a terminal on a new tab.  
    * **Local Terminal:** Open terminal on the MacBook and run the following. This will prompt you to enter a password for your HPCC account (same as MSU account).
      ```bash
      ssh <username>@hpcc.msu.edu      # replace <> with your MSU username 
      ```

4. Set up an analysis directory adjacent to the data folder. This can be done in two ways:

   * **Manually:** Download this GitHub repository to the MacBook as a zipped folder and unzip it. Next, rename the folder with the name of suppresor mutant. Then, upload the folder to the HPCC so that it is in the folder containing the data folder. 
   * * **Terminal, after manual download:** Open terminal on the MacBook and run the following. This will prompt you to enter a password for your HPCC account (same as MSU account).
      ```bash
      scp -r ~/Desktop/DataFolder <username>@hpcc.msu.edu:<DataFolder>     # replace <>'s with your MSU username and the name of your data folder
      ```
   * **HPCC Web Terminal, straight from GitHub:** Navigate to the HPCC's web terminal and run the following code. (This may require SSH keys to be set-up on the HPCC).
     ```bash
     cd ~
     git clone git@github.com:yashmanne/Benning_Simple.git
     mv Benning_Simple <analysis_folder>     # replace {analysis_folder} with {your_sample_name}
     ```

## Setting up Variables

Once the analysis folder is set-up, open the `variables.sh` file on the Web GUI by clicking the three dots next to the file and hitting `EDIT` to open the file on a new tab. The script should look as follows:

      ```bash
      #### Change these to what yours are

      # data folder
      dataLocation="../DefaultData"
      # output file
      lineName="defaultEMS"

      #### Note that in the example case, data was spread across 3 lanes L02, L03, L04. This may not always be the case and might need to be modified
      lane1="L02"
      lane2="L03"
      lane3="L04"
      ```
Now, change the `dataLocation` variable to `"../DataFolder"`, where `"DataFolder"` is the name of your data folder. Next, change `lineName` to `"your_sample_name"`, where `"your_sample_name"` is the name of your sample. Next, change `lane1` to the lowest lane value, in this case `"L02"` and `lane2` to the next lowest value, and `lane3` to the highest lane value. Save the script by hitting the blue `SAVE` button.

Once this file is saved, we can run subsequent HPCC scripts!

## Running HPCC Scripts

Navigate to the folder you uploaded from this GitHub to the HPCC (what you just named after your mutant):

 ```bash
      cd ./<folder_name>/ 
 ``` 

To run the analysis, simply run the following in terminal:

 ```bash
      bash runScripts.sh 
 ```

This will run all scripts listed below in the following order. These scripts can be found in the scripts folder of this repository.
   1. `import_data.sb` : gathers all data into the `input` folder into a compatible file names.
   2. `getReferences_Arabidopsis.sb` : downloads necessary reference genome information.
   3. `runBwaMem2Index_slurm_ArabidopsisEMS.sb` : indexes the reference genome for comparison with sequencing files.
   4. `runBwaMem2Aln_slurm_ArabidopsisEMS.sb` : aligns the sequencing files to the reference genome and generates `.sam` files that contains the alignment data.
   5. `runSamtoolsSamToBam_slurm_ArabidopsisEMS.sb` : convert alignment data into more efficient `.bam` format.
   6. `runSamtoolsBam_Sort_IndexEMS.sb` : sorts and indexes the alignments for future SNP-calling.
   7. `runSamtoolsMarkDuplicatesEMS.sb`: removes all duplicates to ensure efficient and accurate SNP-calling.

Each `.sb` script will generate a `slurm-########.out` file that shows the log of commands run in each script. These files are useful to debug any issues that may pop up. In most cases, it will be easy to debug, if not, the HPCC folks can be contacted [here](https://contact.icer.msu.edu/contact). 

Each script can be edited if needed by going to https://ondemand.hpcc.msu.edu/, and clicking `Home Directory` under the `Files` drop-down. Then, navigate to the desired script and hit `EDIT` under the three dots drop-down for the file you want to edit. A new tab will allow you to edit the file and you can save the file by hitting the `SAVE` button on the top left.

All scripts are finished when all 7 `slurm-########.out` files show up in the scripts folder. If all scripts are successful, there should be multiple non-empty files in the `output` folder.

A common issue while running the script may be that 1 or more of the data files are corrupted. In this case, the corrupted portion of the corrupted data files must be cut out. In these cases, it's common to manually contatetate three files of each files and put into the `input` folder. Since data has already been added to the `input`, script 1 (`import_data.sb`) can be skipped and the subsequent scripts can be run by running the following:

      ```bash
      bash runScripts.sh data
      ```

Additionally, the quality of the sequencing files can be tested by running the `runFastqc_slurm_EMS.sb` script, which outputs HTML files containing plots of different metrics of data quality. This can be run separately by doing the following:

      ```bash
      # navigate to scripts folder
      cd ./scripts/
      sbatch runFastqc_slurm_EMS.sb
      ``` 

Once the script is run, its progress can be checked by the following:

      ```bash 
      squeue -lu <username>      # replace <> with your MSU username 
      ```
 
Once all the output files have been successfully generated, copy the output files from the HPCC to the Lab Macbook by doing the following:

1. Open up terminal.
2. Navigate to desktop by doing `cd ~/Desktop/`
3. `scp -r <username>@hpcc.msu.edu:<analysis_folder_name>/output .      # replace <>'s with your MSU username and name of analysis folder `  
4. Run other lab experiments while files download. (It can take close to an hour)

## Running SIMPLE
1. Once all the files have transferred, download [Simple](https://github.com/wacguy/Simple) to your desktop and unzip. Rename the folder as `Simple` instead of `Simple-master`. Go to the `simple_variables.sh` file under `Simple/scripts/` and change the `line` variable from “EMS” to your desired sample name as done for the `lineName` variable above. 

2. Next, copy all files in the output folder to the the `Simple/output` folder.

3. Now, in `Simple/scripts/`, replace the `simple.sh` with the `simple.sh` file present in the `scripts` folder of the data analysis repository. The new `simple.sh` file can be downloaded using the HPCC GUI as done above.
      
<!--       ```bash
      cd ~/Desktop/Simple/scripts/
      scp <username>@hpcc.msu.edu:<analysis_folder>/scripts/simple.sh ./simple.sh      # replace <>'s with your MSU username and name of analysis folder
      ``` -->
 
4. Now, SIMPLE is ready to run by doing the following on the MacBook:

      ```bash
      cd ~/Desktop/Simple
      chmod +x ./scripts/simple.sh
      ./scripts/simple.sh
      ```

Come back in a day and it should be ready. Congrats, now you get to do the fun stuff!
