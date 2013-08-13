
include	tools.mk # Tools & utility targets.

# human liver carcinoma (HepG2)
# http://genome.ucsc.edu/cgi-bin/hgTrackUi?db=hg19&g=wgEncodeCaltechRnaSeq
# http://www.ebi.ac.uk/ena/data/view/SRP003497

# Reference genome:
GENOME   =human

# Run accession number:
AN       =SRR065496

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR065/SRR065496/SRR065496

# Simulation parameters:
NR_CYCLES			=11                         # ASSUMED number of PCR cycles.
READ_LENGTH         =75                         # Read length.
SIM_POLYA			='1.0:g:(125,1,0,250)'     	# Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

