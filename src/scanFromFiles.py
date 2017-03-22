import os
import os.path
from docGeneratorClasses import *


# Here the files will be allocated prior to opean each one ans get the parameters
# @iparam pathvar
# @iparam recur
# @iparam verbose
def formatlabfiles(pathvar, recur=0, verbose=False):

    if verbose:
        print('Beginning with process')
        print('Step 1: Searching in directories')

    chainoffiles = []           # Array that will store the list of files
    chainofdirs = []            # Array that will store the paths of the files in chainOfFiles

    # Now iterate through the directories and, if 'recursive' is enabled, also through subdirectories
    # searching for m files

    # If the search is not recursive
    if recur == 0:

        for files in next(os.walk(pathvar)):
            for name in files:
                if name.endswith('.m'):
                    if verbose:
                        print('Fetching', name, '...')
                    if not (name in chainoffiles):
                        chainoffiles.append(name)
                        chainofdirs.append(pathvar)

    # In other case, it is recursive
    else:

        for root, dirs, files in os.walk(pathvar):
            for name in files:
                if name.endswith('.m'):
                    if verbose:
                        print('Fetching', os.path.join(root, name), '...')
                    if not(name in chainoffiles):
                        chainoffiles.append(name)
                        chainofdirs.append(root)

    # Once fetching finishes, begin scanning files
    __scanforfiles(chainoffiles, chainofdirs, verbose=verbose)


# Here there will be a loop over all files for getting the information of them
# @iparam chainoffiles
# @iparam chainofdirs
# @iparam verbose
def __scanforfiles(chainoffiles, chainofdirs, verbose=False):

    index = 0
    # List of 'function' objects
    listoffunctions = []
    # Loop over all previously fetched files
    for fil in chainoffiles:

        if verbose:
            print('Opening file', os.path.join(chainofdirs[index], fil), '...')

        # Open each file and get the header, specified by '%%%'
        fileid = open(os.path.join(chainofdirs[index], fil), 'r')
        index += 1

        chunks = []

        for line in fileid:

            # If we get the '%%%' the header is over
            if "%%%" in line:
                break
            else:
                chunks.append(line)

        # Parse each function header
        fun = __parsefunct(chunks, verbose=verbose)
        fun.name = fil[0:len(fil) - 2]
        listoffunctions.append(fun)

        # And, at last, close the file
        fileid.close()

    for funct in listoffunctions:
        for param in funct.oparams:
            print(param.name, param.typ, ' '.join(param.desc))


# This function parses the lines in the input list
# @iparam chunks
# @iparams verbose
def __parsefunct(chunks, verbose=False):

    # 'Function' object definition
    fun = FuncDefinition()
    # Current state, used for multi-line fields
    current = 'function'

    if verbose:
        print('Parsing file...')

    # Loop through the lines of the header searching for predefined tags and storing the relevant information in a
    # 'function' object
    for line in chunks:

        if current == 'function':

            token = line[line.find('function')+8:len(line)].strip()

            fun.usage = token

            current = '@desc'

        elif '@summ' in line:

            token = line[line.find('@summ') + 5:len(line)].strip()

            fun.addsumm(token)

            current = '@summ'

        elif '@ref' in line:

            token = line[line.find('@ref') + 4:len(line)].strip()

            fun.addref(token)

            current = '@ref'

        elif '@iparam' in line:

            token = line[line.find('@iparam') + 7:len(line)].strip()

            fun.addiparam(token)

            current = '@iparam'

        elif '@oparam' in line:

            token = line[line.find('@oparam') + 7:len(line)].strip()

            fun.addoparam(token)

            current = '@oparam'

        elif '@author' in line:

            token = line[line.find('@author') + 7:len(line)].strip()

            fun.author = token

            current = '@author'

        elif '@company' in line:

            token = line[line.find('@company') + 8:len(line)].strip()

            fun.company = token

            current = '@company'

        elif '@date' in line:

            token = line[line.find('@date') + 5:len(line)].strip()

            fun.date = token

            current = '@date'

        elif '@version' in line:

            token = line[line.find('@version') + 8:len(line)].strip()

            fun.version = token

            current = '@version'

        elif '%%' in line:

            current = '%%'

        else:

            token = line[2:len(line)].strip()

            if current != '%%':

                try:

                        ({'@desc': fun.adddesc, '@summ': fun.addsumm, '@ref': fun.addref,
                            '@iparam': fun.updateiparam, '@oparam': fun.updateoparam}[current])(token)

                except KeyError:

                    if verbose:
                        print('Error during parse of last highlighed file, skipping it and moving forward')
                    continue
    return fun


# Junk function, ignore
#
def forothers():

    print('junk')
