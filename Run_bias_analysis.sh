#!/bin/bash

# LSF parameters:
CORES=4
MEMORY=20000
LAUNCH="bsub -M $MEMORY -n $CORES -R rusage[mem=$MEMORY],span[ptile=$CORES]"
LOGDIR=runlogs

function run {
    $LAUNCH "make -f data.mk/bias/$1.mk $2 &> $LOGDIR/$1.log"
}

# run dm_SRR015074 bias_analysis
# run dm_SRR031717 bias_analysis
# run dm_SRR034309 bias_analysis
# run dm_SRR042423 bias_analysis
# run dm_SRR059066 bias_analysis
# run hs_ERR030874 bias_analysis
# run hs_ERR030885 bias_analysis
# run hs_SRR065496 bias_analysis
# run hs_SRR521448 bias_analysis
# run hs_SRR521457 bias_analysis
# run mm_ERR120702 bias_analysis
# run mm_SRR040000 bias_analysis
run mm_SRR496440 bias_analysis
# run mm_SRR530634 bias_analysis
# run mm_SRR530635 bias_analysis
# run mm_SRR549333 bias_analysis
# run mm_SRR549337 bias_analysis
