
# Paths & reference:
DIR      		=$(BASE)/Bias/$(AN)
REF      		=$(DIR)/reference/ref.fas
ISO      		=$(DIR)/reference/iso.tab

# Data:
IDX				=$(REF).1.ebwt
IDX_CACHE		=$(BASE)/ref_cache
RAW				=$(DIR)/raw_data
FQ1				=$(RAW)/$(AN)_1.fq
FQ2				=$(RAW)/$(AN)_2.fq
ALN_DIR			=$(DIR)/mapped_reads
ALN				=$(ALN_DIR)/samtools/$(AN)_sort.sam

#Log:
LOG_DIR			=$(DIR)/log
COUNT_FILE		=$(LOG_DIR)/fragment_counts.pk
PRIOR_FILE		=$(LOG_DIR)/fragment_prior.pk
EST_SUGGEST		=$(LOG_DIR)/effest_suggestions.txt 
EST_JSON		=$(LOG_DIR)/effest_raw_params.json
EST_REPORT		=$(LOG_DIR)/effest_report.pdf
EST_LOG			=$(LOG_DIR)/effest_log.txt
EST_REF			=$(LOG_DIR)/$(AN)_expr.fas
EST_REF_FLAT	=$(LOG_DIR)/flat_$(AN)_expr.fas
EST_W			=4
MIN_QUAL		=0

# Re-estimation:
RE_COUNT_FILE		=$(LOG_DIR)/re_fragment_counts.pk
RE_PRIOR_FILE		=$(LOG_DIR)/re_fragment_prior.pk
RE_EST_SUGGEST		=$(LOG_DIR)/re_effest_suggestions.txt 
RE_EST_JSON			=$(LOG_DIR)/re_effest_raw_params.json
RE_EST_REPORT		=$(LOG_DIR)/re_effest_report.pdf
RE_EST_LOG			=$(LOG_DIR)/re_effest_log.txt
RE_EST_REF			=$(LOG_DIR)/re_$(AN)_expr.fas
RE_EST_REF_FLAT		=$(LOG_DIR)/re_flat_$(AN)_expr.fas

# Simulation related files and parameters:
SIM_CORES		=4
SIM_DIR			=$(DIR)/simulation
SIM_DIR_FLAT	=$(DIR)/simulation_flat
SIM_LOG			=$(LOG_DIR)/rlsim_report.json
SIM_LOG_FLAT	=$(LOG_DIR)/rlsim_report_flat.json
SIM_ALN			=$(SIM_DIR)/samtools/reads_sort.sam
SIM_ALN_FLAT	=$(SIM_DIR_FLAT)/samtools/reads_sort.sam
SIM_GOB			=$(SIM_DIR)/frags.gob
SIM_GOB_FLAT	=$(SIM_DIR_FLAT)/frags.gob
# Poly(A) tail length distribution (flat simulation):
SIM_POLYA_FLAT	='1.0:g:(1,1,0,0)'
# Expression level multiplier:
EXPR_MUL        =10000.0
# Minimum PCR efficiency:
SIM_MIN_EFF     =0.05
# Priming bias parameter:
SIM_PRIMING_BIAS=5
# Fixed amplification efficiency for flat simulations:
SIM_FLAT_EFF	=0.87

# Coverage comparison related files and parameters:
CMP_PICKLE			=$(LOG_DIR)/cov_cmp.pk
CMP_PICKLE_FLAT		=$(LOG_DIR)/cov_cmp_flat.pk
CMP_REPORT			=$(LOG_DIR)/cov_cmp.pdf
CMP_REPORT_FLAT		=$(LOG_DIR)/cov_cmp_flat.pdf
CMP_MIN_LEN			=200
CMP_LOG				=$(LOG_DIR)/cov_cmp_report.txt
CMP_LOG_FLAT		=$(LOG_DIR)/cov_cmp_report_flat.txt
CMP_MIN_COV			=50

# pb_plot files:
PB_PLOT_ALN		= $(LOG_DIR)/pb_plot_aln.pdf
PB_PK_ALN		= $(LOG_DIR)/pb_plot_aln.pk
PB_PLOT_SIM		= $(LOG_DIR)/pb_plot_sim.pdf
PB_PK_SIM		= $(LOG_DIR)/pb_plot_sim.pk
PB_PLOT_SIM_FLAT= $(LOG_DIR)/pb_plot_sim_flat.pdf
PB_PK_SIM_FLAT	= $(LOG_DIR)/pb_plot_sim_flat.pk

# meta_cmp related files:
META_COV_CMP			=$(BIN)/meta_cov_cmp
META_COV_REPORT			= $(LOG_DIR)/meta_cov_cmp.pdf
META_COV_PK			= $(LOG_DIR)/meta_cov_cmp.pk
META_COV_LOG			= $(LOG_DIR)/meta_cov_cmp.txt

META_PB_CMP			=$(BIN)/meta_pb_cmp
META_PB_PK_SIM			=$(LOG_DIR)/meta_pb_sim.pk
META_PB_LOG_SIM			=$(LOG_DIR)/meta_pb_sim.log
META_PB_PK_SIM_FLAT		=$(LOG_DIR)/meta_pb_sim_flat.pk
META_PB_LOG_SIM_FLAT	=$(LOG_DIR)/meta_pb_sim_flat.log

MEAN_GC_PK			=$(LOG_DIR)/mean_gc.pk
MEAN_GC_PK_SIM			=$(LOG_DIR)/mean_gc_sim.pk
MEAN_GC_PK_FLAT			=$(LOG_DIR)/mean_gc_flat.pk
MEAN_GC_COR_REPORT		=$(LOG_DIR)/mean_gc_cor.pdf
MEAN_GC_COR_REPORT_FLAT		=$(LOG_DIR)/mean_gc_cor_flat.pdf
MEAN_GC_LOG			=$(LOG_DIR)/mean_gc.txt
MEAN_GC_LOG_FLAT		=$(LOG_DIR)/mean_gc_flat.txt

MEAN_GC_COR_PK			=$(LOG_DIR)/mean_gc_cor.pk
MEAN_GC_COR_PK_FLAT		=$(LOG_DIR)/mean_gc_cor_flat.pk

KMER_LENGTH			=6

KMER_FREQS_PK			=$(LOG_DIR)/kmer_freqs.pk
KMER_FREQS_PK_SIM		=$(LOG_DIR)/kmer_freqs_sim.pk
KMER_FREQS_PK_FLAT		=$(LOG_DIR)/kmer_freqs_flat.pk
KMER_FREQS_COR_LOG		=$(LOG_DIR)/kmer_freqs_sim_cor.txt
KMER_FREQS_COR_LOG_FLAT		=$(LOG_DIR)/kmer_freqs_flat_cor.txt
KMER_FREQS_COR_REPORT		=$(LOG_DIR)/kmer_freq_cor_sim.pdf
KMER_FREQS_COR_PK		=$(LOG_DIR)/kmer_freq_cor_sim.pk
KMER_FREQS_COR_REPORT_FLAT	=$(LOG_DIR)/kmer_freq_cor_sim.pdf
KMER_FREQS_COR_PK_FLAT		=$(LOG_DIR)/kmer_freq_cor_flat.pk

#
# Pipeline targets:
#

bias_analysis: meta_cmp
# bias_analysis: tools meta_cmp re_est

$(EST_JSON): tools $(ALN) $(LOG_DIR)
#$(EST_JSON): $(LOG_DIR)
	@echo ------------------------------------------------------------------
	@echo Running effest on $(AN).
	@echo ------------------------------------------------------------------
	@$(EFFEST) -v -u -f $(REF) -i $(ISO) -c $(NR_CYCLES) -r $(EST_REPORT) \
	-l $(EST_LOG) -g $(EST_REF) -e $(EXPR_MUL) \
	-s $(COUNT_FILE) -p $(PRIOR_FILE) -w $(EST_W) -q $(MIN_QUAL) \
	$(ALN) -j $(EST_JSON)> $(EST_SUGGEST)
est: $(EST_JSON)

$(RE_EST_JSON): $(LOG_DIR) $(SIM_ALN)
#$(RE_EST_JSON): $(LOG_DIR)
	@echo ------------------------------------------------------------------
	@echo Re-running effest on $(AN).
	@echo ------------------------------------------------------------------
	@$(EFFEST) -v -u -f $(REF) -i $(ISO) -c $(NR_CYCLES) -r $(RE_EST_REPORT) \
	-l $(RE_EST_LOG) -g $(RE_EST_REF) -e $(EXPR_MUL) \
	-s $(RE_COUNT_FILE) -p $(RE_PRIOR_FILE) -w $(EST_W) -q $(MIN_QUAL) \
	$(SIM_ALN) -j $(RE_EST_JSON)> $(RE_EST_SUGGEST)
re_est: $(RE_EST_JSON)

$(SIM_ALN): $(EST_JSON)
#$(SIM_ALN): 
	@echo ------------------------------------------------------------------
	@echo Simulating data based on the parameters in: $(EST_JSON)
	@echo Runfile: $(RUNFILE)
	@echo Read length: $(READ_LENGTH)
	@echo ------------------------------------------------------------------
	@$(BIN)/simulate_data -f $(EST_REF) -m $(REF) -n"-n:$(READ_LENGTH)" -r"-t:$(SIM_CORES)|-f:$(SIM_FRAG_METHOD)|-b:$(SIM_STRAND_BIAS)|-p:$(SIM_PRIMING_BIAS)|-j:$(EST_JSON)|-a:$(SIM_POLYA)|-jm:$(SIM_MIN_EFF)|-r:$(SIM_LOG)|-gcfreq:50|-gobdir:$(SIM_GOB)" -o $(DIR) -x $(RUNFILE) -z $(BASE)/simulators 
sim: $(SIM_ALN)

$(SIM_ALN_FLAT): $(EST_JSON)
#$(SIM_ALN_FLAT): 
	@echo ------------------------------------------------------------------
	@echo Simulating data based on "flat" parameters:
	@echo Runfile: $(RUNFILE)
	@echo Read length: $(READ_LENGTH)
	@echo ------------------------------------------------------------------
	@$(BIN)/simulate_data -f $(EST_REF_FLAT) -m $(REF) -n"-n:$(READ_LENGTH)" -r"-t:$(SIM_CORES)|-f:$(FLAT_FRAG_METHOD)|-b:$(SIM_STRAND_BIAS)|-j:$(EST_JSON)|-e:$(SIM_FLAT_EFF)|-a:$(SIM_POLYA_FLAT)|-jm:$(SIM_MIN_EFF)|-r:$(SIM_LOG_FLAT)|-gcfreq:50|-gobdir:$(SIM_GOB_FLAT)" -o $(DIR) -x $(RUNFILE) -z $(BASE)/simulators -y simulation_flat
sim_flat: $(SIM_ALN_FLAT)

plot_rlsim: $(SIM_ALN) $(SIM_ALN_FLAT)
	@$(PLOT_RLSIM) $(SIM_LOG)
	@$(PLOT_RLSIM) $(SIM_LOG_FLAT)

pb_plot: $(SIM_ALN) $(SIM_ALN_FLAT)
#pb_plot: 
	@echo ------------------------------------------------------------------
	@echo Generating sequence bias plots for $(AN)
	@echo ------------------------------------------------------------------
	@$(PB_PLOT)	-f $(REF) $(ALN) -r $(PB_PLOT_ALN) -p $(PB_PK_ALN) 
	@$(PB_PLOT)	-f $(REF) $(SIM_ALN) -r $(PB_PLOT_SIM) -p $(PB_PK_SIM) 
	@$(PB_PLOT)	-f $(REF) $(SIM_ALN_FLAT) -r $(PB_PLOT_SIM_FLAT) -p $(PB_PK_SIM_FLAT) 

cmp: $(SIM_ALN) $(SIM_ALN_FLAT) plot_rlsim
#cmp: 
	@echo ------------------------------------------------------------------
	@echo Comparing coverage trends for $(AN)
	@echo ------------------------------------------------------------------
	@$(COV_CMP)  -c $(CMP_MIN_COV) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) -r $(CMP_REPORT) -p $(CMP_PICKLE) -f $(REF) $(ALN) $(SIM_ALN) > $(CMP_LOG)
	@$(COV_CMP)  -c $(CMP_MIN_COV) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) -r $(CMP_REPORT_FLAT) -p $(CMP_PICKLE_FLAT) -f $(REF) $(ALN) $(SIM_ALN_FLAT) > $(CMP_LOG_FLAT)

kmer_freqs: # $(SIM_ALN) $(SIM_ALN_FLAT) 
	@echo ------------------------------------------------------------------
	@echo Calculating kmer frequencies for $(AN)
	@echo ------------------------------------------------------------------
	@$(KMER_FREQS) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) -p $(KMER_FREQS_PK) -f $(REF) $(ALN)
	@$(KMER_FREQS) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) -p $(KMER_FREQS_PK_SIM) -f $(REF) $(SIM_ALN)
	@$(KMER_FREQS) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) -p $(KMER_FREQS_PK_FLAT) -f $(REF) $(SIM_ALN_FLAT)

mean_gc: # $(SIM_ALN) $(SIM_ALN_FLAT) 
	@echo ------------------------------------------------------------------
	@echo Calculating mean GC for $(AN)
	@echo ------------------------------------------------------------------
	@$(MEAN_GC) -c $(CMP_MIN_COV) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) \
	-p $(MEAN_GC_PK) -f $(REF) $(ALN)
	@$(MEAN_GC) -c $(CMP_MIN_COV) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) \
	-p $(MEAN_GC_PK_SIM) -f $(REF) $(SIM_ALN)
	@$(MEAN_GC) -c $(CMP_MIN_COV) -q $(MIN_QUAL) -l $(CMP_MIN_LEN) \
	-p $(MEAN_GC_PK_FLAT) -f $(REF) $(SIM_ALN_FLAT)

#meta_cmp: cmp pb_plot mean_gc mean_gc
#meta_cmp:
#	@$(META_COV_CMP) -m $(CMP_PICKLE) -f $(CMP_PICKLE_FLAT) -r $(META_COV_REPORT) -p $(META_COV_PK) > $(META_COV_LOG)
#	@$(META_PB_CMP) -a $(PB_PK_ALN) -s $(PB_PK_SIM) -p $(META_PB_PK_SIM) > $(META_PB_LOG_SIM)
#	@$(META_PB_CMP) -a $(PB_PK_ALN) -s $(PB_PK_SIM_FLAT) -p $(META_PB_PK_SIM_FLAT) > $(META_PB_LOG_SIM_FLAT)
#	@$(MEAN_GC_COR) -r $(MEAN_GC_COR_REPORT) -p $(MEAN_GC_COR_PK) -a $(MEAN_GC_PK) -s $(MEAN_GC_PK_SIM)
#	@$(MEAN_GC_COR) -r $(MEAN_GC_COR_REPORT_FLAT) -p $(MEAN_GC_COR_PK_FLAT) -a $(MEAN_GC_PK) -s $(MEAN_GC_PK_FLAT)
meta_cmp: kmer_freqs
	@$(KMER_FREQS_COR) -r $(KMER_FREQS_COR_REPORT) -p $(KMER_FREQS_COR_PK) -k $(KMER_LENGTH) \
	$(KMER_FREQS_PK) $(KMER_FREQS_PK_SIM) > $(KMER_FREQS_COR_LOG)
	@$(KMER_FREQS_COR) -r $(KMER_FREQS_COR_REPORT_FLAT) -p $(KMER_FREQS_COR_PK_FLAT) -k $(KMER_LENGTH) \
	$(KMER_FREQS_PK) $(KMER_FREQS_PK_FLAT) > $(KMER_FREQS_COR_LOG_FLAT)

# Create log directory:
$(LOG_DIR):
	@mkdir -p $(LOG_DIR)

# Map and sort reads:
$(ALN): $(IDX) $(RAW)
#$(ALN): 
	@echo ------------------------------------------------------------------
	@echo Mapping reads using BWA.
	@echo ------------------------------------------------------------------
	@mkdir -p  $(ALN_DIR)
	@( cd $(ALN_DIR); $(BIN)/mapnsort -f $(REF) $(FQ1) $(FQ2) )
map: $(ALN)

# Download reads:
$(RAW): $(DIR)
	@echo ------------------------------------------------------------------
	@echo Fetching raw data for $(AN).
	@echo ------------------------------------------------------------------
	@mkdir -p $(RAW) 
	-@( cd $(RAW); wget -nv $(URL)_1.fastq.gz; mv $(AN)_1.fastq.gz $(FQ1).gz; gzip -d $(FQ1).gz )
	-@( cd $(RAW); wget -nv $(URL)_2.fastq.gz; mv $(AN)_2.fastq.gz $(FQ2).gz; gzip -d $(FQ2).gz )
raw: $(RAW)

# Create analysis directory.
$(DIR):
	@echo ------------------------------------------------------------------
	@echo Creating analysis directory for $(AN).
	@echo ------------------------------------------------------------------
	@mkdir -p $(DIR)

# Link reference index:
$(IDX): $(DIR)
	@(cd $(IDX_CACHE); make)
	@echo ------------------------------------------------------------------
	@echo Linking index for $(GENOME) reference transcriptome.
	@echo ------------------------------------------------------------------
	@ test -h $(DIR)/reference || ln -s "$(IDX_CACHE)/$(GENOME)" "$(DIR)/reference"
idx: $(IDX)

