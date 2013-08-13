
include	tools.mk # Tools & utility targets.

# multipotential cell line that can be converted by 5-azacytidine into three mesodermal stem cell lineages.
# http://genome.ucsc.edu/cgi-bin/hgTrackUi?db=mm9&g=wgEncodeCaltechRnaSeq
# http://www.ebi.ac.uk/ena/data/view/SRS333640

# Reference genome:
GENOME   =mus_musculus

# Lane accession number:
AN       =SRR496440

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR496/SRR496440/SRR496440

# Simulation parameters:
NR_CYCLES			=11                        # ASSUMED number of PCR cycles.
READ_LENGTH         =100                       # Read length.
SIM_POLYA			='1.0:g:(38,1,0,77)'       # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

