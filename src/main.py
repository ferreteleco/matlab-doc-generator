from scanFromFiles import *
import time

# TODO HTML template use Jinja2 http://kagerato.net/articles/software/libraries/jinja-quickstart.html
# TODO Test With my own files in gridInspector
# TODO reformat verbose to show better the infomation


def main():

    start = time.time()
    pathvar = "..\\testDir"
    var = 'mfiles'

    try:

        ({'mfiles': formatlabfiles, 'ker': forothers}[var])(pathvar, recur=1, appendcode=True, usage=True, verbose=1)

    except KeyError:

        print('ERROR: Default gateway')

    end = time.time()

    print('\nTook', end - start, 'seconds')


if __name__ == "__main__":

    main()
