
include	tools.mk # Tools & utility targets.

# mixed stage embryos
# http://intermine.modencode.org/query/report.do?id=111000331
# http://www.ebi.ac.uk/ena/data/view/SRS009659

# Reference genome:
GENOME   =drosophila_melanogaster

# Lane accession number:
AN       =SRR034309

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR034/SRR034309/SRR034309

# Simulation parameters:
NR_CYCLES			=11                        # ASSUMED number of PCR cycles.
READ_LENGTH         =76                        # Read length.
SIM_POLYA			='1.0:g:(65,1,0,130)'      # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

