
include	tools.mk # Tools & utility targets.

# 
# 
# 

# STD-seq!

# Reference genome:
GENOME=human

# Lane accession number:
AN1=SRR037472
AN2=SRR037479

# Lane URL:
URL1=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037472/SRR037472
URL2=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR037/SRR037479/SRR037479

# Simulation parameters:

include replicate_analysis.mk # Bias analysis pipeline.
