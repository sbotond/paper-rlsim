
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037470
AN2=SRR037477

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037470/SRR037470
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037477/SRR037477

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
