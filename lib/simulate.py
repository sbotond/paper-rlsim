
import  os
import  subprocess  as  sp
import  utils       as  u

class Rlsim:
    """ rlsim wrapper class """
    def __init__(self, log, bin_path, ref=None, frags=None, opts={},autoclean=False, sink_err=False):
        self.log        =   log
        self.bin_path   =   bin_path
        self.ref        =   ref
        self.frags      =   frags
        self.opts       =   opts
        self.autoclean  =   autoclean
        self.sink_err   =   sink_err

    def _construct_cmd(self):
        """ Construct command object """
        self.cmd = os.path.join(self.bin_path,"rlsim") 
        for k,v in self.opts.iteritems():
            self.cmd += " %s %s " % (k,v)
        self.cmd += str(self.ref) + " > " + self.frags

    def simulate(self):
        """ Run simulation """
        if self.frags == None:
            self.log.fatal("Cannot simulate fragments: no output file sepcified!")
        self._construct_cmd()

        res = os.system(self.cmd)
        if res != 0:
            self.log.fatal("Failed to simulate library construction!")
        self.files = [self.frags, 'rlsim_report.json']

    def clean(self):
        # Clean up registered files:
        for f in self.files:
            os.remove(f)

    def __del__(self):
        if self.autoclean:
            self.clean()

class SimNGS:
    """ simNGS wrapper class """
    def __init__(self, log, bin_path, runfile, frags=None, fq=None, opts={}, autoclean=False, sink_err=True):
        self.log        = log
        self.bin_path   = bin_path
        self.runfile    = runfile
        self.frags      = frags
        self.fq         = fq
        self.opts       = opts
        self.autoclean  = autoclean
        self.sink_err   = sink_err

    def _construct_cmd(self):
        """ Construct simulation command object """
        if self.frags  == None:
            self.log.fatal("Cannot simulate as no input file is specified!")
        # Append runfile:
        if not os.path.exists(self.runfile):
            self.log.fatal("Runfile does not exists!")
        files = [ self.runfile ]
        # Apend input file:
        if not os.path.exists(self.frags):
            self.log.fatal("Fragment file does not exists!")
        if  self.frags != None:
            files.append(self.frags)
        # Construct command object: 
        self.cmd    = u.Cmd(log=self.log, prog=os.path.join(self.bin_path, "simNGS"), opts=self.opts, post_args=files, sink_err=self.sink_err)
        if self.frags != None:
            self.cmd.register(self.frags)

    def simulate(self):
        """ Run headles simulation """
        self._construct_cmd()
        # Process output.
        self.cmd.comm()

    def init_iter(self):
        """ Initialise iterative simulation """
        self._construct_cmd() 

    def _get_reads(self,out_pipe, nr_reads):
        """ Get reads from simNGS output """
        # Read the resulting reads:
        reads   = [ ]
        c   = 0; # line counter
        r   = '' # read buffer
        for line in out_pipe:
            c += 1
            r += line
            if c % 4 == 0:
                reads.append(r)
                c   = 0
                r   = ''
                if len(reads) == nr_reads:
                    tmp     = reads
                    reads   = [ ]
                    yield tmp
        
    def simulate_iter(self):
        """ Iterate over simulated reads """
        in_pipe         = self.cmd.pipe.stdin
        out_pipe        = self.cmd.pipe.stdout
        nr_reads        = self.nr_ends()
        return self._get_reads(out_pipe, nr_reads)

    def close_iter(self):
        """ Close iterative simulation """
        self.cmd.comm()
        self.cmd.close()

    def nr_ends(self):
        """ Return the number of reads """
        if self.opts.has_key("-p") and self.opts["-p"] == "paired":
            return 2
        return 1

