from scanFromFiles import formatlabfiles
import time


def main():

    start = time.time()

    # Inputs zone
    #################################################################
    pathvar = "..\\testDir"
    outputdir = "..\\doc"
    projectlogopath = "..\\logo_POLARYS.png"
    projectname = 'POLARYS PROJECT'
    recur = True
    appendcode = True
    usage = True
    verbose = True
    #################################################################

    var = 'mfiles'

    try:

        ({'mfiles': formatlabfiles}[var])(pathvar, outputdir, projectlogo=projectlogopath, projectname=projectname,
                                          recur=recur, appendcode=appendcode, usage=usage, verbose=verbose)

    except KeyError:

        print('ERROR: Default gateway')

    end = time.time()

    print('\nTook', end - start, 'seconds')


if __name__ == "__main__":

    main()
