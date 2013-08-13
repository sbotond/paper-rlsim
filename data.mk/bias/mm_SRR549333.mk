
include	tools.mk # Tools & utility targets.

# mouse megakaryocyte erythroid progenitor cells with lineages CD16/32 and CD34
#  http://genome.ucsc.edu/cgi-bin/hgTrackUi?db=mm9&g=wgEncodePsuRnaSeq
#  http://www.ebi.ac.uk/ena/data/view/SRS360144

# STRANDED

# Reference genome:
GENOME   =mus_musculus

# Lane accession number:
AN       =SRR549333

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR549/SRR549333/SRR549333

# Simulation parameters:
NR_CYCLES			=11                        # ASSUMED number of PCR cycles.
READ_LENGTH         =99                        # Read length.
SIM_POLYA			='1.0:g:(38,1,0,77)'       # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"   	   # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double" 	   # Fragmentation method (flat simulation).
SIM_STRAND_BIAS		=0.0					   # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

