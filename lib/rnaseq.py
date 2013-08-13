
import      os

import      utils       as  u
import      simulate    as  sim
import      align
import      samtools

class SimLib:
    def __init__(self, log, ref, rlsim_opts, simngs_opts, path_info, run_folder=None, lib_dir="lib", fq_prefix="reads",sink_err=True, rts=None):
        self.log        =   log
        self.ref        =   ref
        self.path_info  = path_info
        if run_folder == None:
            run_folder  = os.getcwd()    
        if rts == None:
            self.rts        = u.Rtemp(run_folder, self.log)
        else:
            self.rts        = rts
        self.rts        =   self.rts.subdir(lib_dir)
        self.fq_prefix  =   fq_prefix
        # Get output file:
        frags           = self.rts.tempfile('fragments.fas')
        # Initialize rlsim object:
        #rlsim_opts["-v"]= ""
        self.rlsim      =   sim.Rlsim(self.log, path_info['RLSIM_PATH'], self.ref, frags, opts=rlsim_opts,sink_err=sink_err)
        # Initialize simNGS object:
        self.fq_base    = os.path.join(self.rts.base, fq_prefix)
        simngs_opts["-O"]= self.fq_base 
        self.sim_ngs    =   sim.SimNGS(log, path_info['SIMNGS_PATH'], path_info['SIMNGS_RUNFILE'], frags, opts=simngs_opts,sink_err=True)

    def simulate(self):
        self.rlsim.simulate()
        self.sim_ngs.simulate()
        # Rename fastq files:
        fqs = [ ]
        for i in xrange(1,3): 
            old_name    = self.fq_base + "_end" + str(i) + ".fq"
            new_name    = self.fq_base + "_" + str(i) + ".fq"
            os.rename(old_name, new_name)
            fqs.append(new_name)
        self.fqs = fqs
        return ( self.fqs, self.rts)

class PrepSam:
    def __init__(self, log, rts, fqs, ref, autoclean=False):
        self.log        = log
        self.rts        = rts
        self.fqs        = fqs
        self.ref        = ref
        self.autoclean  = autoclean

    def align(self):
        #bwt = align.Bowtie(log=self.log, ref=self.ref,has_index=True, rts=self.rts, reads=self.fqs,aln_opts={"-X":"1500"}, sink_err=True)
        #bwt.index()
        bwt =   align.Bwa(self.log, self.ref, self.rts, self.fqs, sink_err=True, has_index=True)
        bwt.aln()
        self.sam = bwt.sam() 

    def sort_sam(self):
        st      = samtools.Samtools(log=self.log, rts=self.rts,sink_err=True)

        bam     = u.chext(self.sam, "bam")
        st.view(inp=self.sam, outp=bam)

        sbam        = st.sort(bam, opts={"-n":None})
        ssam        = st.view(inp=sbam, outp=u.chext(sbam,"sam"), opts={"-h":None})

        self.ssam   = ssam
        return ssam

    def prep_sam(self):
        self.align()
        return self.sort_sam()

    def clean(self):
        self.rts.clean()

    def __del__(self):
        if self.autoclean:
            self.clean()

