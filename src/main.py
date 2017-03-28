from scanFromFiles import formatlabfiles, forothers
import time


def main():

    start = time.time()
    pathvar = "..\\testDir"
    outputdir = "G:\\Proyectos\\RepoWriteDoc\\doc"
    projectlogopath = "..\\logo_POLARYS.png"
    projectname = 'POLARYS PROJECT'
    var = 'mfiles'

    try:

        ({'mfiles': formatlabfiles, 'ker': forothers}[var])(pathvar, outputdir,
                                                            projectlogo=projectlogopath,
                                                            projectname=projectname,
                                                            recur=True,
                                                            appendcode=True, usage=True,
                                                            verbose=True)

    except KeyError:

        print('ERROR: Default gateway')

    end = time.time()

    print('\nTook', end - start, 'seconds')


if __name__ == "__main__":

    main()
