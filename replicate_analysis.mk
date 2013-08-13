
# Paths & reference:
DIR      		=$(BASE)/Replicate/$(AN1)-$(AN2)
REF      		=$(DIR)/reference/ref.fas
ISO      		=$(DIR)/reference/iso.tab
#REF=$(BASE)/simulators/rlsim/tools/test/ref.fas
#ISO=$(BASE)/simulators/rlsim/tools/test/iso.list

# Data:
IDX			=$(REF).1.ebwt
IDX_CACHE		=$(BASE)/ref_cache
RAW			=$(DIR)/raw_data
FQ1			=$(RAW)/$(AN1).fq
FQ2			=$(RAW)/$(AN2).fq
ALN_DIR			=$(DIR)/mapped_reads
ALN1=$(ALN_DIR)/samtools/$(AN1)_sort_1.sam
ALN2=$(ALN_DIR)/samtools/$(AN2)_sort_2.sam
#ALN1=$(BASE)/simulators/rlsim/tools/test/aln1.sam
#ALN2=$(BASE)/simulators/rlsim/tools/test/aln2.sam

#Log:
LOG_DIR			=$(DIR)/log
COUNT_FILE		=$(LOG_DIR)/fragment_counts.pk
PRIOR_FILE		=$(LOG_DIR)/fragment_prior.pk

# Coverage comparison related files and parameters:
CMP_PICKLE		=$(LOG_DIR)/cov_cmp.pk
CMP_REPORT		=$(LOG_DIR)/cov_cmp.pdf
CMP_MIN_LEN		=400
CMP_MIN_COV			=50
CMP_LOG			=$(LOG_DIR)/cov_cmp_report.txt
CMP_LOG_FLAT		=$(LOG_DIR)/cov_cmp_report_flat.txt

# pb_plot files:
PB_PLOT_ALN1		= $(LOG_DIR)/pb_plot_$(AN1).pdf
PB_PK_ALN1		= $(LOG_DIR)/pb_plot_$(AN1).pk
PB_PLOT_ALN2		= $(LOG_DIR)/pb_plot_$(AN2).pdf
PB_PK_ALN2		= $(LOG_DIR)/pb_plot_$(AN2).pk

# meta_cmp related files:
META_PB_CMP		=$(BIN)/meta_pb_cmp
META_PB_PK		=$(LOG_DIR)/meta_pb.pk
META_PB_LOG		=$(LOG_DIR)/meta_pb.log

KMER_LENGTH		=6

KMER_PICKLE_1		=$(LOG_DIR)/kmer_freqs_1.pk
KMER_PICKLE_2		=$(LOG_DIR)/kmer_freqs_2.pk
KMER_LOG_1		=$(LOG_DIR)/kmer_freqs_report_1.txt
KMER_LOG_2		=$(LOG_DIR)/kmer_freqs_report_2.txt
KMER_COR_LOG		=$(LOG_DIR)/kmer_freqs_cor.txt
KMER_COR_REPORT		=$(LOG_DIR)/kmer_freq_cor.pdf
KMER_COR_PICKLE		=$(LOG_DIR)/kmer_freq_cor.pk

MEAN_GC_PK_1		=$(LOG_DIR)/mean_gc.pk
MEAN_GC_PK_2		=$(LOG_DIR)/mean_gc_sim.pk
MEAN_GC_PK_FLAT		=$(LOG_DIR)/mean_gc_flat.pk
MEAN_GC_LOG		=$(LOG_DIR)/mean_gc.txt
MEAN_GC_COR_PK		=$(LOG_DIR)/mean_gc_cor.pk
MEAN_GC_COR_REPORT	=$(LOG_DIR)/mean_gc_cor.pdf

#
# Pipeline targets:
#
replicate_analysis: mean_gc_cor kmer_freqs_cor cmp # meta_pb_cmp

kmer_freqs: # ...
	@echo ------------------------------------------------------------------
	@echo Calculating kmer frequencies
	@echo ------------------------------------------------------------------
	@$(KMER_FREQS) $(ALN1) -f $(REF) -p $(KMER_PICKLE_1) -l $(CMP_MIN_LEN) \
	-k $(KMER_LENGTH) -s > $(KMER_LOG_1)
	@$(KMER_FREQS) $(ALN2) -f $(REF) -p $(KMER_PICKLE_2) -l $(CMP_MIN_LEN) \
	-k $(KMER_LENGTH) -s > $(KMER_LOG_2)

kmer_freqs_cor: kmer_freqs
	@echo ------------------------------------------------------------------
	@echo Calculating kmer frequency correlation
	@echo ------------------------------------------------------------------
	$(KMER_FREQS_COR) $(KMER_PICKLE_1) $(KMER_PICKLE_2) -r KMER_COR_REPORT \
	-p $(KMER_COR_PICKLE) -k $(KMER_LENGTH) > $(KMER_COR_LOG)

mean_gc: # ...
	@echo ------------------------------------------------------------------
	@echo Calculating mean GC
	@echo ------------------------------------------------------------------
	@$(MEAN_GC) -l $(CMP_MIN_LEN) -p $(MEAN_GC_PK_1) -f $(REF) -s $(ALN1)
	@$(MEAN_GC) -l $(CMP_MIN_LEN) -p $(MEAN_GC_PK_2) -f $(REF) -s $(ALN2)

mean_gc_cor: mean_gc
	@echo ------------------------------------------------------------------
	@echo Calculating mean GC correlation
	@echo ------------------------------------------------------------------
	@$(MEAN_GC_COR) -r $(MEAN_GC_COR_REPORT) -p $(MEAN_GC_COR_PK) -a $(MEAN_GC_PK_1) -s $(MEAN_GC_PK_2)

# pb_plot: map $(LOG_DIR)
pb_plot: 
	@echo ------------------------------------------------------------------
	@echo Generating sequence bias plots for $(AN)
	@echo ------------------------------------------------------------------
	@$(PB_PLOT)	-f $(REF) $(ALN1) -r $(PB_PLOT_ALN1) -p $(PB_PK_ALN1) -s
	@$(PB_PLOT)	-f $(REF) $(ALN2) -r $(PB_PLOT_ALN2) -p $(PB_PK_ALN2) -s

#cmp: map $(LOG_DIR)
cmp: 
	@echo ------------------------------------------------------------------
	@echo Comparing coverage trends for $(AN1) and $(AN2)
	@echo ------------------------------------------------------------------
	@$(COV_CMP) -l $(CMP_MIN_LEN) -c $(CMP_MIN_COV) -r $(CMP_REPORT) -p $(CMP_PICKLE) -f $(REF) -s $(ALN1) $(ALN2) > $(CMP_LOG)

# meta_cmp: cmp pb_plot $(LOG_DIR)
meta_pb_cmp: pb_plot
# @$(META_COV_CMP) -m $(CMP_PICKLE) -f $(CMP_PICKLE_FLAT) -r $(META_COV_REPORT)
	@$(META_PB_CMP) -a $(PB_PK_ALN1) -s $(PB_PK_ALN2) -p $(META_PB_PK) > $(META_PB_LOG)

report: 

# Create log directory:
$(LOG_DIR):
	@mkdir -p $(LOG_DIR)

# Map and sort reads:
# $(ALN): $(IDX) $(RAW)
map: $(IDX) $(RAW)
#$(ALN): 
	@echo ------------------------------------------------------------------
	@echo Mapping reads using BWA.
	@echo ------------------------------------------------------------------
	@mkdir -p  $(ALN_DIR)
	@( cd $(ALN_DIR); PYTHONPATH=$(BASE)/lib $(BIN)/mapnsort -f $(REF) $(FQ1) -s -o $(ALN1) )
# map: $(ALN)

# Download reads:
$(RAW): $(DIR)
	@echo ------------------------------------------------------------------
	@echo Fetching raw data for $(AN1) and $(AN2).
	@echo ------------------------------------------------------------------
	@mkdir -p $(RAW) 
	-@( cd $(RAW); wget -nv $(URL1).fastq.gz; mv $(AN1).fastq.gz $(FQ1).gz; gzip -d $(FQ1).gz )
raw: $(RAW)

# Create analysis directory.
$(DIR):
	@echo ------------------------------------------------------------------
	@echo Creating analysis directory for $(AN1).
	@echo ------------------------------------------------------------------
	@mkdir -p $(DIR)
dir: $(DIR)

# Link reference index:
$(IDX): $(DIR)
	@(cd $(IDX_CACHE); make)
	@echo ------------------------------------------------------------------
	@echo Linking index for $(GENOME) reference transcriptome.
	@echo ------------------------------------------------------------------
	@ test -h $(DIR)/reference || ln -s "$(IDX_CACHE)/$(GENOME)" "$(DIR)/reference"
idx: $(IDX)
