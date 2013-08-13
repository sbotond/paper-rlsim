
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037469
AN2=SRR037476

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037469/SRR037469
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037476/SRR037476

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
