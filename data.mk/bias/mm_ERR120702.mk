
include	tools.mk # Tools & utility targets.

# liver
# http://europepmc.org/articles/PMC3514667;jsessionid=GelIsSszWLHWdH8r8rhW.30
# http://www.ebi.ac.uk/ena/data/view/ERS134248

# Reference genome:
GENOME   =mus_musculus

# Lane accession number:
AN       =ERR120702

# Lane URL:
URL      =ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR120/ERR120702/ERR120702

# Simulation parameters:
NR_CYCLES			=11                        # ASSUMED number of PCR cycles.
READ_LENGTH         =72                        # Read length.
SIM_POLYA			='1.0:g:(38,1,0,77)'      # Poly(A) tail length distribution (full simulation).
SIM_FRAG_METHOD     ="after_prim_double"       # Fragmentation method (full simulation).
FLAT_FRAG_METHOD    ="after_noprim_double"     # Fragmentation method (flat simulation).
SIM_STRAND_BIAS     =0.5                       # Strand bias.

include bias_analysis.mk # Bias analysis pipeline.

