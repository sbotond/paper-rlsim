import      os
import      sys
import      time
import      copy
import      subprocess                      as      sp
from        Bio                             import  SeqIO
from        matplotlib                      import  pyplot          as  plt
from        collections                     import  defaultdict
from        matplotlib.backends.backend_pdf import  PdfPages
import      numpy                           as      np
import      cPickle

class Report:
    """ Class for plotting reports """
    def __init__(self, pdf):
        self.pdf    = pdf
        self.pages  = PdfPages(pdf)

    def plot_hash(self, h, title="", xlab="", ylab=""):
        """ Visualise hash as a bar plot """
        fig = plt.figure()
        plt.bar(h.keys(), h.values(), width=0.1)
        plt.xlabel(xlab)
        plt.ylabel(ylab)
        plt.title(title)
        self.pages.savefig(fig)

    def plot_contour(self, z, title="", xlab="", ylab=""):
        """ Visualise matrix as a filled contour plot """
        fig = plt.figure()
        p   = plt.contourf(z)
        plt.colorbar(p, orientation='vertical')
        plt.xlabel(xlab)
        plt.ylabel(ylab)
        plt.title(title)
        self.pages.savefig(fig)

    def plot_array(self, y, title="", xlab="", ylab=""):
        """ Visualise  array as a bar plot """
        fig = plt.figure()
        plt.bar(np.arange(len(y)),y,width=0.1)
        plt.xlabel(xlab)
        plt.ylabel(ylab)
        plt.title(title)
        self.pages.savefig(fig)

    def plot_arrays(self,x, y, title="", xlab="", ylab=""):
        """ Visualise  array as a bar plot """
        fig = plt.figure()
        plt.plot(x,y,'.')
        plt.xlabel(xlab)
        plt.ylabel(ylab)
        plt.title(title)
        self.pages.savefig(fig)

    def close(self):
        self.pages.close()

class Log:
    """ Logging utility class """
    def __init__(self, fname=None, level=0):
        self.level = level
        if fname == None:
            self.fname  = "<sys.stderr>"     
            self.file   = sys.stderr
        else:
            self.file   = open(fname, "w")
            self.fname  = fname

    def close(self):
        self.file.flush()
        self.file.close()

    def log(self, message):
        if self.level < 0:
            return
        self.file.write("[%s] %s\n" % (time.strftime("%y-%m-%d %H:%M:%s"), message) )

    def fatal(self, message):
        self.file.write("[%s] %s\n" % (time.strftime("%y-%m-%d %H:%M:%s"), message) )
        sys.exit(1)

class Rtemp:
    """ Utility class handling temporary storage """
    def __init__(self, base, log, autoclean=False):
        self.log        = log
        self.autoclean  = autoclean
        self.parent     = None
        self.children   = [ ]
        self.files      = [ ]
        if os.path.isdir(base) != True:
            log.fatal("The base must be a directory: %s" % base)
        self.base   = os.path.abspath(base)

    def exists(self, fname):
        """ Check wheteher a file exists """
        return os.path.exists(fname) 

    def _iterate_fname(self, fname):
        """ Iterate until we don't have a name clash """
        i           = 0
        orig_fn     = fname # basename
        while True:
            if (fname in self.files) or self.exists(fname):
                i       += 1
                fname   = orig_fn + ("_%03d" % i)
            else:
                break
        return fname

    def tempfile(self, name):
        """ Get a temporary file """
        fname       = self._iterate_fname(os.path.join(self.base, name))
        self.register(fname)            
        return fname

    def temp_fh(self, name):
        """ Get a temporary file handle """
        fname   = self.tempfile(name)
        f       = open(fname, "w")
        return f

    def clean(self):
        """ Remove registered temporary files """
        for child in self.children:
            child.clean()   # call cleanup on children.
        tmp = list(self.files)
        for f in tmp:
            self.remove(f)
        # Delete the directory if children is  a subdir:
        if self.parent != None:
            os.rmdir(self.base)

    def remove(self, fname):
        """ Remove a temporary file """
        if not (fname in self.files):
            self.log.fatal("The file %s is not mannaged by this object!" % fname)
        if os.path.exists(fname):
            os.remove(fname)
        self.files.remove(fname)

    def subdir(self, dname):
        """ Get a mannaged temporary subdirectory """
        clone           = copy.copy(self)        
        dname           = os.path.join(self.base, dname)
        clone_base      = self._iterate_fname(dname)
        os.mkdir(clone_base)
        clone.base      = clone_base
        clone.parent    = self
        clone.children  = []
        clone.files     = []
        self.children.append(clone)
        return clone

    def register(self, fname):
        """ Register temporary file """
        self.files.append(fname)
    
    def unregister(self, fname):
        """ Unregister temporary file """
        self.files.remove(fname)

    def __del__(self):
        if self.autoclean:
            self.clean()

class Cmd:
    """ Class for running commands """
    def __init__(self, log, prog, pre_args=[], post_args=[], opts={}, inp=None, outp=None, cwd=None, files=[ ], sink_err=False, autoclean=False, path=None):
        self.log        =   log         # log object.
        self.pre_args   =   pre_args    # before options arguments
        self.post_args  =   post_args   # after options arguments
        self.opts       =   opts        # option flags
        self.cwd        =   cwd         # execution directory
        self.files      =   files       # registered files
        self.sink_err   =   sink_err    # sink error messages
        self.autoclean  =   autoclean   # automatic cleanup
        self.path       =   path        # path to binary
        self.name       =   os.path.basename(prog)
        if self.path == None:
            self.prog       =   prog
        else:
            self.prog       =   os.path.join(path, prog)
        self.pre_args   =   pre_args    # before options arguments

        # Build command:
        self.build_cmd()

        # Sort out input:
        input_fh    = sp.PIPE   # get input from pipe
        if inp != None:
            if type(inp) == file:
                input_fh    = inp   # input is a file handler
            elif type(inp) == str:
                input_fh    = open(inp, "r") # input is a file name
            else:
                self.log.fatal("Invalid input source!")
        self.input_fh   = input_fh

        # Sort out output:
        output_fh = sp.PIPE # Output to pipe
        if outp != None:
            if type(outp) == file:
                output_fh = outp    # file handler output
            elif type(outp) == str:
                output_fh    = open(outp, "w")  # create file
            else:
                self.log.fatal("Invalid output!")
        self.output_fh  = output_fh

        # Open pipe:
        self.pipe   =   sp.Popen(args=self.cmd,bufsize=0,stderr=sp.PIPE,stdin=input_fh, stdout=output_fh, shell=False,cwd=self.cwd)

    def build_cmd(self):
        """ Build command list """
        cmd  = [ self.prog ] # executable
        cmd.extend(self.pre_args) # pre-arguments
        # Append flags:
        for (flag, val) in self.opts.iteritems():
            # Flag:
            cmd.append(flag)
            # Value if not none:
            if val != None:
                cmd.append(val)
        # Post-args:
        cmd.extend(self.post_args)
        self.cmd    = cmd

    def comm(self, in_data=''):
        """ Communicate with subprocess """
        (stdout_data, stderr_data)  = self.pipe.communicate(in_data)
        # Log stderr output:
        if stderr_data != None and self.sink_err != True:
            self.log_data(stderr_data)
        return stdout_data

    def log_data(self, data):
        """ Logging helper """
        log = self.log
        tmp = data.split('\n')  
        for line in tmp:
           log.log("<%s> %s" % (self.name, line)) 

    def register(self, fn):
        """ Register temporary file """
        self.files.append(fn)

    def unregister(self, fn):
        """ Unregister temporary file """
        self.files.remove(fn)

    def clean(self):
        """ Cleanup registered temporary files """
        for f in self.files:
            if os.path.exists(f):
                os.remove(f)
        self.files  = [ ]

    def __del__(self):
        if (self.pipe.stdin != None) and (not self.pipe.stdin.closed):
            # Close stdin and wait for final output.
            self.pipe.stdin.close()
            self.pipe.wait()
        if self.autoclean:
            self.clean()

    def close(self):
        # Close stdin, wait for final output.
        if self.pipe.stdin != None:
            self.pipe.stdin.close()
        self.pipe.wait()

class Pipe:
    """ Pipe helper class """
    def __init__(self):
        self.r, self.w  = os.pipe()

class Fasta:
    """ Fasta parsing class """
    def __init__(self, infile):
        self.infile     = infile
        self.in_fh      = open(infile, "r")
        self.iter       = SeqIO.parse(self.in_fh,'fasta')

    def __iter__(self):
        """ Return iterator """
        return iter(self.iter)

    def slurp(self):
        """ Slurp sequences """
        records = { }
        for s in iter(self):
            records[s.name] = str(s.seq)
        return records

class Binner:
    """ Class for binning floating point values """
    def __init__(self, width):
        self.width  = width

    def bin(self, v):
        """ Bin value """
        i = 0
        while True:
            nx = i + self.width
            if nx >= v: # include values at the lower limit
                break
            i += self.width
        return range(i, nx)

def randint(low=0,high=2147483647):
    """ Return a random integer in the positive range of int32 """
    return np.random.randint(low=low, high=high)

def dimcons(at):
    """ Convert two dimensional arrays to the same shape """
    max_one = max([x.shape[0] for x in at]) # maximal first dimension
    max_two = max([x.shape[1] for x in at]) # maximal second dimension
    cat = [] 
    # Fix first dimension
    for a in at:
        dm  = max_one - a.shape[0] 
        if dm == 0:
            cat.append(a)
        else:
            tmp = np.zeros((dm,a.shape[1]),dtype=a.dtype)
            sm  = np.vstack((a,tmp))
            cat.append(sm)
    at  = list(cat)
    cat = []
    # Fix second dimension:
    for a in at:
        dm  = max_two - a.shape[1] 
        if dm == 0:
            cat.append(a)
        else:
            tmp = np.zeros((a.shape[0],dm),dtype=a.dtype)
            sm  = np.hstack((a,tmp))
            cat.append(sm)

    return cat

def chext(s, new_ext):
        """ Change extension of a file name """
        tmp = s.split('.')
        tmp = tmp[0:-1]
        tmp.append(new_ext)
        return '.'.join(tmp)

def unpickle(f):
    """ Load data from pickle file """
    fh     = open(f, "r")
    pickle = cPickle.Unpickler( fh )
    tmp = pickle.load()
    return tmp

def pickle(d, fname):
    """ Pickle data to file """
    fh     = open(fname, "w")
    pickle = cPickle.Pickler( fh )
    pickle.dump(d)
    fh.flush()
    fh.close()


