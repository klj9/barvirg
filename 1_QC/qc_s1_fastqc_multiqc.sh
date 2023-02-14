#I modified this script from https://github.com/benstemon/dasanthera_novaseq/tree/main/1_QC
#FastQC performs quality checks on raw sequence data
#MultiQC summarizes and visualizes the quality report as an HTML file
#Submitted 2023-02-13

#!/bin/sh

#SBATCH -N 1
#SBATCH -n 20
#SBATCH -p wessinger-48core
#SBATCH --job-name=QC_s1

cd $SLURM_SUBMIT_DIR


#source appropriate environments to enable use of conda installs through batch submission
source /home/klj9/.bashrc
source /home/klj9/.bash_profile

#activate conda environment with QC packages installed
conda activate QC


#Change these: location of raw reads and location of the output directory
#(will need to make output directory)
rawreads="/work/klj9/barvirg/rawreads"

fastqc_outdir_rawreads="/work/klj9/barvirg/qc/fastqc_rawreads"


################
#fastqc+multiqc#
################

#move to directory with reads (raw reads directory)
cd $rawreads

#store fastq files as array
files=(*.fastq.gz)

#perform fastqc -- distinction from for loop is this can process -t files simultaneously
fastqc "${files[@]}" -t 20 -o $fastqc_outdir_rawreads

#summarize results with multiqc
multiqc $fastqc_outdir_rawreads -o $fastqc_outdir_rawreads

