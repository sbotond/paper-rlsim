#!/bin/bash

# LSF parameters:
CORES=2
Q=research-rh6
MEMORY=10000
LAUNCH="bsub -q $Q -M $MEMORY -n $CORES -R rusage[mem=$MEMORY],span[ptile=$CORES]"
LOGDIR=runlogs

function run {
    $LAUNCH "make -f data.mk/replicate/$1.mk $2 &> $LOGDIR/$1.log"
}

run hs_Dudoit_S3_S5_1 replicate_analysis
run hs_Dudoit_S3_S5_2 replicate_analysis
run hs_Dudoit_S3_S5_3 replicate_analysis
run hs_Dudoit_S3_S5_4 replicate_analysis
run hs_Dudoit_S4_S6_1 replicate_analysis
run hs_Dudoit_S4_S6_2 replicate_analysis
run hs_Dudoit_S4_S6_3 replicate_analysis

# Unmatched lanes
run hs_Dudoit_S3_S5_5 replicate_analysis
run hs_Dudoit_S4_S6_4 replicate_analysis