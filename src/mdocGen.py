from scanFromFiles import formatlabfiles
import time
import sys
import getopt
import os.path


def main(argv):

    start = time.time()

    try:
        opts, args = getopt.getopt(argv, "i:o:l:n:rucvh", ["idir=", "odir=", "logo=", "name="])

    except getopt.GetoptError:

        print('mdocGen.py -h for function usage')
        sys.exit(2)

    pathvar = '.\\'
    outputdir = '..\\docs'
    projectlogopath = None
    projectname = ''
    recur = False
    appendcode = False
    usage = False
    verbose = False

    for opt, arg in opts:

        if opt == '-h':

            print('mdocGen.py [-i <inputdir>] [-o <outputdir>] [-l <projectlogo>] [-n <projectname>] [-r -u -c -v]')
            print('-i -- Specify input directory (default) ./ ')
            print('-o -- Specify output directory (default) ../doc ')
            print('-l -- Specify path to project logo')
            print("-n -- Specify project's name")
            print('-r -- Perform recursive scan (check subdirectories)')
            print('-u -- Check mutual ussage between files')
            print('-c -- Append source code to documentation')
            print('-v -- Verbose mode')

            sys.exit(0)

        elif opt in ("-i", "--idir"):
            pathvar = arg
            basepath = pathvar.split('\\')
            outputdir = os.path.join('\\'.join(basepath[0:-1]), 'doc')
        elif opt in ("-o", "--odir"):
            outputdir = arg
        elif opt in ("-l", "--logo"):
            projectlogopath = arg
        elif opt in ("-n", "--name"):
            projectname = arg
        elif opt == "-r":
            recur = True
        elif opt == "-u":
            usage = True
        elif opt == "-c":
            appendcode = True
        elif opt == "-v":
            verbose = True

    var = 'mfiles'

    try:

        ({'mfiles': formatlabfiles}[var])(pathvar, outputdir, projectlogo=projectlogopath, projectname=projectname,
                                          recur=recur, appendcode=appendcode, usage=usage, verbose=verbose)

    except KeyError:

        print('ERROR: Default gateway')

    end = time.time()

    print('\nTook', end - start, 'seconds')


if __name__ == "__main__":

    main(sys.argv[1:])
