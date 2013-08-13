
include	tools.mk # Tools & utility targets.

# Illumina BodyMap: kidney
# http://www.ensembl.info/blog/2011/05/24/human-bodymap-2-0-data-from-illumina/
# http://www.ebi.ac.uk/ena/data/view/ERS025081

# Reference genome:
GENOME   =human

# Lane accession number:
AN       =ERR030885

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR030/ERR030885/ERR030885

# Simulation parameters:
NR_CYCLES			=15                        # Number of PCR cycles.
READ_LENGTH         =50                        # Read length.
SIM_POLYA			='1.0:g:(125,1,0,250)'     # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

