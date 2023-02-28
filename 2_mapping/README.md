I first created a conda environment called "mapping" and installed bwa, samtools v1.15.1, and bamutil v1.0.15:

conda create --name mapping
conda install -c bioconda bwa
conda install -c bioconda samtools samtools=1.15.1
conda install -c bioconda bamutil bamutil=1.0.15