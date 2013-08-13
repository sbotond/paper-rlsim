
include	tools.mk # Tools & utility targets.

# 30 third-instar wandering larva
# http://www.ncbi.nlm.nih.gov/pubmed/21177959
# http://www.ebi.ac.uk/ena/data/view/SRR059066

# Reference genome:
GENOME   =drosophila_melanogaster

# Lane accession number:
AN       =SRR059066

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR059/SRR059066/SRR059066

# Simulation parameters:
NR_CYCLES			=11                        # ASSUEMD number of PCR cycles.
READ_LENGTH         =75                        # Read length.
SIM_POLYA			='1.0:g:(65,1,0,130)'      # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

