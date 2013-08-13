
include	tools.mk # Tools & utility targets.

# CME_W1_Cl.8+ cell line
# http://intermine.modencode.org/release-32/report.do?id=111001155
# http://www.ebi.ac.uk/ena/data/view/SRS002587

# Reference genome:
GENOME   =drosophila_melanogaster

# Lane accession number:
AN       =SRR015074

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR015/SRR015074/SRR015074

# Simulation parameters:
NR_CYCLES			=11                        # ASSUMED number of PCR cycles.
READ_LENGTH         =50                        # Read length.
SIM_POLYA			='1.0:g:(65,1,0,130)'      # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD		="after_prim_double"	   # Fragmentation method (full simulation).
FLAT_FRAG_METHOD	="after_noprim_double"	   # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

