from scanFromFiles import *
import timeit

# TODO next, open each file and fill an array of objects of class 'function' or class 'script'
# TODO define class 'script'
# TODO implement some flag do decide if the code is processed
# TODO and appended or not (different parsing function)
# TODO set properties for lists in class Function in order to return strings instead of lists
# TODO parse iparams and oparams to get sub-elements (type, desc...)
# TODO consider scripts

def main():

    start = timeit.timeit()
    pathvar = "..\\testDir"
    var = 'mat'

    try:

        ({'mat': formatlabfiles, 'ker': forothers}[var])(pathvar, recur=1, verbose=1)

    except KeyError:

        print('ERROR: Default gateway')

    end = timeit.timeit()

    print('Took ', end - start, ' seconds')


if __name__ == "__main__":

    main()




