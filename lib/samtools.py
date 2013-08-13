
import      utils       as      u
import      os
import      sys
import      re

class Samtools:
    """ Samtools wrapper class """
    def __init__(self, log,rts, sink_err=True, path=None, autoclean=False):
        self.prog       =   "samtools"
        self.log        =   log
        self.sink_err   =   sink_err
        self.path       =   path
        self.autoclean  =   autoclean
        self.rts        =   rts.subdir(self.prog)

    def view(self, inp=None, outp=None, opts={"-S":None, "-b":None}): 
        """ View SAM/BAM files """
        if outp != None:
            outp    = os.path.join(self.rts.base, outp)
        cmd = u.Cmd(log=self.log, prog=self.prog, pre_args=["view"], opts=opts, post_args=["-"], inp=inp, outp=outp, path=self.path, sink_err=self.sink_err)
        cmd.comm()
        # Register output file.
        if type(outp) == str:
            self.rts.register(outp)
        return  cmd.output_fh

    def sort(self, inp=None, outp=None, opts={}):
        """ Sort BAM file """
        out_name    = str()
        if type(outp) == file:
            self.log.fatal("Sort does not work on pipe output")
        elif type(outp) == str:
           out_name = self.rts.tempfile(outp)
        elif outp == None and type(inp) == str:
            base        = os.path.basename(inp).split(".bam")[0] + "_sort"
            out_name    = base
        else:
            self.log.fatal("No output available!")

        cmd = u.Cmd(log=self.log, prog=self.prog, pre_args=["sort"], opts=opts, post_args=["-", out_name], inp=inp, outp=None, path=self.path, sink_err=self.sink_err,cwd=self.rts.base)
        cmd.comm()
        out_name    += ".bam"
        self.rts.register(out_name)
        return os.path.join(self.rts.base, out_name)

    def clean(self):
        self.rts.clean()

    def index(self, bam):
        """ Index BAM file """
        cmd = u.Cmd(log=self.log, prog=self.prog, pre_args=["index"], opts={}, post_args=[bam], inp=None, outp=None, path=self.path, sink_err=self.sink_err,cwd=self.rts.base)
        cmd.comm() 
        self.rts.register(bam + ".sai")

    def flagstat(self, bam):
        """ Get BAM statistics """
        if not os.path.exists(bam):
            self.log.fatal("BAM file does not exists.")

        cmd         = u.Cmd(log=self.log, prog=self.prog, pre_args=["flagstat"], opts={}, post_args=[bam], path=self.path, sink_err=self.sink_err)
        data        = cmd.comm()

        stats       = { }

        feat_map    = { 
            re.compile("(\d+)\sQC failure"):tuple(["qc_fail"]),
            re.compile("(\d+)\sduplicates"):tuple(["duplicates"]),
            re.compile("(\d+)\smapped\s\((\S+)%\)"):tuple(["nr_mapped","percent_mapped"]),
            re.compile("(\d+)\spaired in sequencing"):tuple(["seq_paired"]),
            re.compile("(\d+)\sproperly paired \((\S+)%\)"):tuple(["nr_proper_pairs","percent_proper_pairs"]), 
            re.compile("(\d+)\swith itself and mate mapped"):tuple(["nr_proper_with_mate"]),
            re.compile("(\d+)\ssingletons\s\((\S+)%\)"):tuple(["singletons", "percent_singletons"]),
            re.compile("(\d+)\sread1"):tuple(["nr_read1"]),
            re.compile("(\d+)\sread2"):tuple(["nr_read2"]),
            re.compile("(\d+)\swith mate mapped to a different chr \(mapQ.+\)\Z"):tuple(["chr_mismatch_q5"]),
            re.compile("(\d+)\swith mate mapped to a different chr\Z"):tuple(["chr_mismatch"])
        }

        for line in data.split("\n"):
            for (pattern, names) in feat_map.iteritems():
                m = pattern.match(line) 
                if m != None:
                    groups = m.groups()
                    if len(groups) != len(names):
                        self.log.fatal("Name/group mismatch: %s %s" % (groups, names))
                    for i in xrange(len(groups)):
                        stats[names[i]] = float(groups[i])
        return stats

    def __del__(self):
        if self.autoclean:
            self.clean() 
