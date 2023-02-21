#I modified this script from https://github.com/benstemon/dasanthera_novaseq/tree/main/1_QC
#fastp trims adapter sequences and filters out low quality reads
#fastqc and multiqc run again to summarize new data quality metrics

#Submitted 2023-02-21
#########################################################################################################

#!/bin/sh

#SBATCH -N 1
#SBATCH -n 20
#SBATCH -p wessinger-48core
#SBATCH --job-name=QC_s3a-c

cd $SLURM_SUBMIT_DIR


#source appropriate environments to enable use of conda installs through batch submission
source /home/klj9/.bashrc
source /home/klj9/.bash_profile

#activate conda environment with QC packages installed
conda activate QC


#######
#fastp#
#######

#path to illumina mergedreads
mergedreads="/work/klj9/barvirg/merged_reads"

#path to fastp outfiles (creates directory, and replaces if already present)
out_fastp="/work/klj9/barvirg/filtered_reads"
rm -r $out_fastp
mkdir $out_fastp


#fastp for loop
for r1in in $mergedreads/*_R1_001.fastq.gz; 
do
    r2in="${r1in/R1_001.fastq.gz/R2_001.fastq.gz}"
    r1out="${r1in##*/}"
    r2out="${r1out/R1_001.fastq.gz/R2_001.fastq.gz}"
    fastp -i "$r1in" -I "$r2in" --detect_adapter_for_pe -l 30 --out1 $out_fastp/"${r1out/merged_L001_R1_001.fastq.gz/trimmed_L001_R1_001.fastq.gz}" --out2 $out_fastp/"${r1out/merged_L001_R1_001.fastq.gz/trimmed_L001_R2_001.fastq.gz}" -x -c -w 16 -h $out_fastp/"${r1out/merged_L001_R1_001.fastq.gz/html}" -j $out_fastp/"${r1out/merged_L001_R1_001.fastq.gz/json}"
done



################
#fastqc+multiqc#
################

out_fastqc="/work/klj9/barvirg/fastqc_filtered"
rm -r $out_fastqc
mkdir $out_fastqc

#move to directory with reads (fastp outfile directory)
cd $out_fastp

#store fastq files as array
files=(*.fastq.gz)

#perform fastqc -- distinction from for loop is this can process -t files simultaneously
fastqc "${files[@]}" -t 20 -o $out_fastqc

#summarize results with multiqc
multiqc $out_fastqc -o $out_fastqc


###Distinction from v1:
# in fastp:
#1. include --detect_adapter_for_pe 
#2. require reads to be at least 30bp
#3. do not save the unpaired reads (small proportion, lower quality)