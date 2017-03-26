from scanFromFiles import *
import time

# TODO update the header in test files
# TODO comment regex in scanFromFiles
# TODO test all fields of lists
# TODO HTML template Jinja2 http://kagerato.net/articles/software/libraries/jinja-quickstart.html
# TODO Test With my own files in gridInspector
# TODO reformat verbose to show better the infomation
# TODO http://nuitka.net/pages/overview.html
# TODO support for matlab classes


def main():

    start = time.time()
    pathvar = "..\\testDir"
    outputdir = "..\\doc"
    var = 'mfiles'

    try:

        ({'mfiles': formatlabfiles, 'ker': forothers}[var])(pathvar, outputdir, recur=True,
                                                            appendcode=False, usage=True,
                                                            verbose=True)

    except KeyError:

        print('ERROR: Default gateway')

    end = time.time()

    print('\nTook', end - start, 'seconds')


if __name__ == "__main__":

    main()
