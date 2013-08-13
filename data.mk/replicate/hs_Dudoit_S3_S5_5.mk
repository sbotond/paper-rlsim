
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037466
AN2=SRR037467

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037466/SRR037466
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037467/SRR037467

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
