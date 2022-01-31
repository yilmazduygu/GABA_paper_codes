# Gut et al. 2022

## Info about the scripts necessary to recreate results reported in the paper

All the codes in this folder are compatible with Matlab R2017a and onwards. They were written on R2017a, and tested again on R2021a.
Everything should run the same way in both Windows and Mac, as these scripts were written using both of these OSs. They also don't depend on any specific toolbox, or hardware. Just download the contents of this repository, and make it the current directory for Matlab. 

## Demo scripts

There are two demo scripts in this folder: <demo_init.m> and <demo_exec.m> 
These are for reproducing the results for the action initiation and action execution paradigms we report in the paper, respectively. The steps to get the results are the same, but the data used in these steps and the initial retrieval of the data differ slightly from each other in these paradigm, hence the separate demo scripts. 

In order to get a feel for how we imported the raw data and process it, please run the first section of the demo scripts, titled "Turn individual data files into one .mat data table". This section will use the example raw data files that are in their respective subfolders ("init_example_raw_data", "exec_example_raw_data").

For reproducing the rest of the figures (Fig 5&6 + Suppl. Fig 4), continue running the rest of the demo scripts. 


