# Build reference:
BIN		=../scripts
REF		=$(GENOME)/ref.fas
IDX		=$(REF).bwt
ISO		=$(GENOME)/iso.tab

# Fetch reference:
$(REF):
	@echo ------------------------------------------------------------------
	@echo Building $(GENOME) reference transcriptome.
	@echo ------------------------------------------------------------------
	@mkdir -p $(GENOME)
	@$(BIN)/get_ref_transcripts $(GENOME) $(REF) $(ISO)
ref: $(REF)

# Index reference:
$(IDX): $(REF)
	@echo ------------------------------------------------------------------
	@echo Indexing $(GENOME) reference transcriptome.
	@echo ------------------------------------------------------------------
	@bwa index $(REF)
idx: $(IDX)
