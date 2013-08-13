
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037467
AN2=SRR037474

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037467/SRR037467
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037474/SRR037474

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
