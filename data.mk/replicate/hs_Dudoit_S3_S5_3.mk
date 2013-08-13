
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037468
AN2=SRR037475

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037468/SRR037468
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037475/SRR037475

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
