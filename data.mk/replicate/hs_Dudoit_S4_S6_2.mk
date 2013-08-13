
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037471
AN2=SRR037478

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037471/SRR037471
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037478/SRR037478

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
