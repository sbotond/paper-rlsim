
include	tools.mk # Tools & utility targets.

# embryonic stem cells
# http://www.ncbi.nlm.nih.gov/pubmed/20436462
# http://www.ebi.ac.uk/ena/data/view/SRS059567

# Reference genome:
GENOME   =mus_musculus

# Lane accession number:
AN       =SRR040000

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR040/SRR040000/SRR040000

# Simulation parameters:
NR_CYCLES			=16                        # Number of PCR cycles.
READ_LENGTH         =76                        # Read length.
SIM_POLYA			='1.0:g:(38,1,0,77)'       # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

