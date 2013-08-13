
include	tools.mk # Tools & utility targets.

# S2-DRSC cell line
# http://www.ncbi.nlm.nih.gov/pubmed/20921232
# http://www.ebi.ac.uk/ena/data/view/SRR034309

# Reference genome:
GENOME   =drosophila_melanogaster

# Lane accession number:
AN       =SRR031717

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR031/SRR031717/SRR031717

# Simulation parameters:
NR_CYCLES			=11                        # ASSUEMD number of PCR cycles.
READ_LENGTH         =37                        # Read length.
SIM_POLYA			='1.0:g:(65,1,0,130)'      # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

