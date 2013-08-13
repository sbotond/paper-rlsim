# Paths:
BASE	=$(shell pwd)
BIN	=$(BASE)/scripts
LABELS	=$(BASE)/Info/dataset_labels.tab

# Utility targets:                                                                                                                                             
.PHONY: com push

com:                                                                                                                                                           
	git commit -a                                                                                                                                          

# Runnables:
RLSIM=$(BASE)/simulators/rlsim/rlsim
EFFEST=$(BASE)/simulators/rlsim/tools/effest
SIMNGS=$(BASE)/simulators/simNGS/bin/simNGS
COV_CMP=$(BASE)/simulators/rlsim/tools/cov_cmp
PB_PLOT=$(BASE)/simulators/rlsim/tools/pb_plot
PLOT_RLSIM=$(BASE)/simulators/rlsim/tools/plot_rlsim_report
VER_LOG  = $(BASE)/Info/soft_versions.log

# simNGS runfile:
RUNFILE_DIR=$(BASE)/simulators/simNGS/data
RUNFILE=$(RUNFILE_DIR)/s_3_4x.runfile

# Build tools:

$(SIMNGS):                                                                                                                                                     
	@echo Building simNGS.                                                                                                                                 
	@cd $(BASE)/simulators/simNGS/src; make                                                                                                                
$(RLSIM):                                                                                                                                                      
	@echo Building rlsim.                                                                                                                                  
	@cd $(BASE)/simulators/rlsim; make                                                                                                                     
$(EFFEST):                                                                                                                                                     
	@cd $(BASE)/simulators/rlsim/tools; make                                                                                                               
tools: $(RLSIM) $(SIMNGS) $(EFFEST) ver                                                                                                                        

ver:                                                                                                                                                           
	@echo BWA `bwa 2>&1| grep Version` > $(VER_LOG)                                                                                                        
	@echo samtools `samtools 2>&1| grep Version` >> $(VER_LOG)                                                                                             
	@$(BIN)/py_versions >> $(VER_LOG)                                       
	@( source load_ensembl; $(BIN)/ensembl_versions >> $(VER_LOG))

GLOB_REP_DIR=$(BASE)/reports
GLOB_REP	=$(GLOB_REP_DIR)/global_bias_report.pdf
DIR=

gr: 
	@echo Generating global report.
	@$(BIN)/plot_global_report -l $(LABELS) -c `find $(BASE)/Bias -name "meta_cov_cmp.pk"` \
	-p `find $(BASE)/Bias -name meta_pb_sim*.pk` -r $(GLOB_REP) -bc $(BASE)/Replicate/*/log/cov_cmp.pk \
	-bp $(BASE)/Replicate/*/log/meta_pb.pk

