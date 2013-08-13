
include	tools.mk # Tools & utility targets.

# leukemia cell line (K562 analog)
#  http://genome.ucsc.edu/cgi-bin/hgTrackUi?db=mm9&g=wgEncodeSydhRnaSeq
#  http://www.ebi.ac.uk/ena/data/view/SRS352520

# STRANDED

# Reference genome:
GENOME   =mus_musculus

# Lane accession number:
AN       =SRR530635

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR530/SRR530635/SRR530635

# Simulation parameters:
NR_CYCLES			=11                        # ASSUMED number of PCR cycles.
READ_LENGTH         =101                       # Read length.
SIM_POLYA			='1.0:g:(38,1,0,77)'       # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"   	   # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double" 	   # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.0                       # Strand bia.

include bias_analysis.mk # Bias analysis pipeline.

