
import      utils       as      u
import      os
import      re
import      samtools    as      st

class Bwa:
    """ Bwa wrapper class """
    def __init__(self, log, ref, rts, reads, index_opts={}, aln_opts={}, samse_opts={}, sampe_opts={}, paired=True, sink_err=True, has_index=False):
        self.log        =   log
        self.prog       =   "bwa"
        self.rts        =   rts.subdir(self.prog)
        self.reads      =   reads
        if not os.path.exists(ref):
            self.log.fatal("<Bwa> Missing reference!")
        self.ref        =   os.path.abspath(ref)
        self.paired     =   paired
        self.samse_opts =   samse_opts
        self.sampe_opts =   sampe_opts
        self.aln_opts   =   aln_opts
        self.sink_err   =   sink_err
        self.index_opts =   index_opts
        self.has_index  =   has_index
    
    def index(self):
        """ Sort out indexing """
        # Symlink reference:
        new_ref         =   os.path.join(self.rts.base, os.path.basename(self.ref))
        os.symlink(self.ref,new_ref)
        # Register reference:
        self.rts.register(new_ref)

        old_ref         =   self.ref
        self.ref        =   new_ref
        ind_suf         =   [".amb",".ann", ".bwt", ".pac", ".rbwt", ".rpac", ".rsa", ".sa"]

        if self.has_index:
            # Symlink index:
            for sx in ind_suf:
                os.symlink(old_ref + sx, new_ref + sx)
        else:
            # Run indexing:
            cmd         = u.Cmd(self.log, prog="bwa",opts=self.index_opts,pre_args=["index", self.ref], sink_err=self.sink_err)
            cmd.comm()

        # Register index files:
        for suf in ind_suf:
            self.rts.register(self.ref + suf)

    def aln(self):
        """ Generate sai files """
        sais = [ ]
        for  fq  in self.reads:
            (path, base)    = os.path.split(fq) 
            sai             = os.path.join(self.rts.base, base + ".sai")
            cmd             = u.Cmd(self.log, "bwa", pre_args=["aln"], opts=self.aln_opts, post_args=[ self.ref, fq], outp=sai, cwd=self.rts.base, sink_err=self.sink_err)
            cmd.comm()
            self.rts.register(sai)
            sais.append(sai)
        self.sai    =   sais

    def sam(self):
        """ Generate sam file """
        # Check input:
        if type(self.sai) != list:
            self.log.fatal("<bwa> Invalid sai!")
        if len(self.sai) < 1:
            self.log.fatal("<bwa> Empty sai array!")

        (path, base)    = os.path.split(self.reads[0]) 
        pattern         = re.compile("_\d\.fq")
        base            = pattern.split(base)[0]

        mode            = str()
        opts            = str()

        # Set up paired-end alignment:
        if self.paired:
            if len(self.sai) != 2:
                self.log.fatal("<bwa/sampe> Not enough sai!")
            if len(self.reads) != 2:
                self.log.fatal("<bwa/sampe> Exactly 2 fastq files needed!")
            mode    = 'sampe'
            opts    =   self.samse_opts
        else:
        # Set up single-ended alignment:
            if len(self.sai) != 1:
                self.log.fatal("<bwa/sampe> Exactly one sai needed!")
            if len(self.sai) != 1:
                self.log.fatal("<bwa/samse> Exactly one fastq needed!")
            mode    =   'samse'
            opts    =   self.samse_opts

        # Generate SAM file:
        sam     = os.path.join(self.rts.base, base + ".sam")
        # Register sam file:
        self.rts.register(sam)
        # Construct post args:
        inf     = [ self.ref ]
        inf.extend(self.sai)
        inf.extend(self.reads)
        # Construct command object:
        cmd     = u.Cmd(self.log, prog="bwa", pre_args=[ mode ], opts=opts, post_args=inf, outp=sam, cwd=self.rts.base, sink_err=self.sink_err)
        cmd.comm() 
        return sam

    def align(self):
        """ Align fastq and return SAM output """
        self.index()
        self.aln()
        sam = self.sam()
        return sam

    def clean(self):
        """ Clean up registered tempfiles """
        self.rts.clean()

class Bowtie:
    """ Bowtie wrapper class """
    def __init__(self, log, ref, rts, reads, index_opts={}, aln_opts={}, sink_err=True, has_index=False):
        self.prog       =       "bowtie"
        self.log        =       log
        self.ref        =       ref
        self.rts        =       rts.subdir(self.prog)
        self.reads      =       reads
        self.index_opts =       index_opts
        self.aln_opts   =       aln_opts
        self.sink_err   =       sink_err
        self.has_index  =       has_index
        if not os.path.exists(ref):
            self.log.fatal(self.prog + ": Missing reference!")
        self.ref        =   os.path.abspath(ref)

    def index(self):
        """ Sort out indexing """
        # Symlink reference:
        new_ref         =   os.path.join(self.rts.base, os.path.basename(self.ref))
        os.symlink(self.ref,new_ref)
        # Register reference:
        self.rts.register(new_ref)

        old_ref         =   self.ref
        self.ref        =   new_ref
        ind_suf         =   [".1.ebwt", ".2.ebwt", ".3.ebwt", ".4.ebwt", ".rev.1.ebwt", ".rev.2.ebwt"]

        if self.has_index:
            # Symlink index:
            for sx in ind_suf:
                os.symlink(old_ref + sx, new_ref + sx)
        else:
            # Run indexing:
            cmd         = u.Cmd(self.log, prog="bowtie-build",opts=self.index_opts,post_args=[self.ref, self.ref], sink_err=self.sink_err)
            cmd.comm()

        # Register index files:
        for suf in ind_suf:
            self.rts.register(self.ref + suf)
        pass

    def sam(self):
        """ Generate sam file """
        # Check input:
        if len(self.reads) == 0:
            self.log.fatal("No fastq files specified")

        (path, base)    = os.path.split(self.reads[0]) 
        pattern         = re.compile("_\d\.fq")
        base            = pattern.split(base)[0]

        # Generate SAM file:
        sam     = os.path.join(self.rts.base, base + ".sam")

        # Register sam file:
        self.rts.register(sam)

        # Construct post args:
        inp_flags   = ["-1", "-2"]
        inf         = [ ]
        for i in xrange(len(self.reads)):
            inf.append(inp_flags[i])            
            inf.append(self.reads[i])            

        # Add bwt base:
        tmp = [self.ref] 
        tmp.extend(inf)
        inf = tmp

        # Tweak flags:
        self.aln_opts["-S"] = None

        # Construct command object:
        cmd                 = u.Cmd(self.log, prog="bowtie", opts=self.aln_opts, post_args=inf, outp=sam, cwd=self.rts.base, sink_err=self.sink_err)
        cmd.comm() 
        return sam

