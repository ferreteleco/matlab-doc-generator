import os
import os.path
from docGeneratorClasses import *
from generateDoc import generatedoc
import itertools


# @desc Here the .m files will be allocated prior to opean each one and get the parameters
# @iparam pathvar
# @iparam filespec
# @iparam recur
# @iparam appendcode
# @iparam usage
# @iparam verbose
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 20/03/17
# @version 1.3
###
def formatlabfiles(pathvar, outputdir, recur=False, appendcode=False, usage=False, verbose=False):
    if verbose:
        print('\nEVENT!!!! Beginning process...\n')
        print('Step 1) Searching in directories:\n')

    chainoffiles = []  # Array that will store the list of files
    chainofdirs = []  # Array that will store the paths of the files in chainOfFiles

    # Now iterate through the directories and, if 'recursive' is enabled, also through
    # subdirectories searching for m files

    # If the search is not recursive
    if not recur:

        for files in next(os.walk(pathvar)):
            for name in files:
                if name.endswith('.m'):
                    if verbose:
                        print('\t- Fetching ', name, '...', sep='')
                    if not (name in chainoffiles):
                        chainoffiles.append(name)
                        chainofdirs.append(pathvar)

    # In other case, it is recursive
    else:

        for root, dirs, files in os.walk(pathvar):
            for name in files:
                if name.endswith('.m'):
                    if verbose:
                        print('\t- Fetching ', os.path.join(root, name), '...', sep='')
                    if not (name in chainoffiles):
                        chainoffiles.append(name)
                        chainofdirs.append(root)

    if verbose:
        print('\nEVENT!!!! Fetching process finished, found: ', len(chainoffiles), ' elements in ',
              len(set(chainofdirs)), ' directories\n', sep='')

    # Once fetching finishes, begin scanning files
    listoffunctions, listofscripts = __scanformfiles(chainoffiles, chainofdirs,
                                                     appendcode=appendcode, usage=usage,
                                                     verbose=verbose)

    generatedoc(outputdir, chainoffiles, listoffunctions, listofscripts, appendcode=appendcode,
                verbose=verbose)


# @desc Here there will be a loop over all .m files for getting the information of them
##
# @iparam chainoffiles
# @iparam chainofdirs
# @iparam appendcode
# @iparam usage
# @iparam verbose
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 20/03/17
# @version 1.1
###
def __scanformfiles(chainoffiles, chainofdirs, appendcode=False, usage=False, verbose=False):
    if verbose:
        print('Step 2) Loading files to memory:\n')

    index = 0
    # List of 'function' objects
    listoffunctions = []
    # List of 'script' objects
    listofscripts = []

    # Loop over all previously fetched files
    for fil in chainoffiles:

        if verbose:
            print('\t- Opening file ', os.path.join(chainofdirs[index], fil), '...', sep='')

        # Open each file and get the header, specified by '%%%'
        fileid = open(os.path.join(chainofdirs[index], fil), 'r')
        index += 1

        code = []

        chunks = []

        ind = 0
        isscript = False
        isheader = True

        for line in fileid:

            if isheader:

                # Check if its a script or not
                if ind == 0:

                    if '@desc' in line:
                        isscript = True

                    ind += 1

                # If we get the '%%%' the header is over
                if "%%%" in line:
                    isheader = False
                else:
                    chunks.append(line)

            elif usage or appendcode:

                code.append(line.replace('\n', ' '))

            else:

                break

        # And, at last, close the file
        fileid.close()

        if isscript:

            # Parse each function header
            scr = __parsemscript(chunks, verbose=verbose)
            scr.name = fil[0:len(fil) - 2]

            if appendcode or usage:
                scr.addcode(code)

            listofscripts.append(scr)

        else:

            # Parse each function header
            fun = __parsemfunct(chunks, verbose=verbose)
            fun.name = fil[0:len(fil) - 2]

            if appendcode or usage:
                fun.addcode(code)

            listoffunctions.append(fun)

    if verbose:
        print('\nEVENT!!!! Loading process finished\n')

    if usage:
        listoffunctions, listofscripts = __checkusage(listoffunctions, listofscripts,
                                                      verbose=verbose)

    return listoffunctions, listofscripts


# @desc This function checks if the usage between functions and scripts, as 'mutual calls'
##
# @iparam listoffunctions
# @iparam listofscripts
# @iparam verbose
##
# @oparam listoffunctions
# @oparam listofscripts
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.0
###
def __checkusage(listoffunctions, listofscripts, verbose=False):
    merged = listoffunctions + listofscripts
    ind = 0

    if verbose:
        print('Step 3) Checking mutual ussage among ', len(merged), ' files:\n', sep='')
        ind = 0

    for x, y in itertools.permutations(merged, 2):

        if y.name in ' '.join(x.code):
            x.adduses(y.name)
            y.addusedby(x.name)

        if verbose:
            ind += 1
            print('\t- Checked ', ind, '-th combination of files', sep='')

    if verbose:
        print('\nEVENT!!!! All combinations between files checked\n')

    listoffunctions = merged[0:len(listoffunctions)]
    listofscripts = merged[len(listoffunctions):len(merged)]

    return listoffunctions, listofscripts


# This function parses the lines in the input list for a script file
# @iparam chunks
# @iparams verbose
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.0
###
def __parsemscript(chunks, verbose=False):
    # 'Script' object definition
    scr = ScriptDefinition()

    # Current state, used for multi-line fields
    current = '@desc'

    if verbose:
        print('\t- Parsing...')

    for line in chunks:

        line = line.replace('\n', ' ')

        if '@desc' in line:

            token = line[line.find('@desc') + 5:len(line)].strip()

            scr.updatedesc(token)

            current = '@desc'

        elif '@ref' in line:

            token = line[line.find('@ref') + 4:len(line)].strip()

            scr.addref(token)

            current = '@ref'

        elif '@author' in line:

            token = line[line.find('@author') + 7:len(line)].strip()

            scr.author = token

            current = '@author'

        elif '@company' in line:

            token = line[line.find('@company') + 8:len(line)].strip()

            scr.company = token

            current = '@company'

        elif '@date' in line:

            token = line[line.find('@date') + 5:len(line)].strip()

            scr.date = token

            current = '@date'

        elif '@version' in line:

            token = line[line.find('@version') + 8:len(line)].strip()

            scr.version = token

            current = '@version'

        elif '%%' in line:

            current = '%%'

        else:

            token = line[1:len(line) - 1].strip()

            if current != '%%':

                try:

                    ({'@desc': scr.updatedesc, '@ref': scr.addref}[current])(token)

                except KeyError:

                    if verbose:
                        print('ERROR!!!! during parse of last highlighted file, skipping it and'
                              ' moving forward')
                    continue
    return scr


# This function parses the lines in the input list for a function file
# @iparam chunks
# @iparams verbose
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.0
###
def __parsemfunct(chunks, verbose=False):
    # 'Function' object definition
    fun = FuncDefinition()
    # Current state, used for multi-line fields
    current = 'function'

    if verbose:
        print('\t- Parsing...')

    # Loop through the lines of the header searching for predefined tags and storing the relevant
    # information in a 'function' object
    for line in chunks:

        line = line.replace('\n', ' ')

        if current == 'function':

            token = line[line.find('function') + 8:len(line)].strip()

            fun.usage = token

            current = '@summ'

        elif current == '@summ':

            token = line.split(' ', 1)

            fun.updatesumm(''.join(token[1:len(token)]))

            current = '@summn'

        elif '@desc' in line:

            token = line[line.find('@desc') + 5:len(line)].strip()

            fun.updatedesc(token)

            current = '@desc'

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

            token = line[1:len(line) - 1].strip()

            if current != '%%':

                try:

                    ({'@summn': fun.updatesumm, '@desc': fun.updatedesc, '@ref': fun.addref,
                      '@iparam': fun.updateiparam, '@oparam': fun.updateoparam}[current])(token)

                except KeyError:

                    if verbose:
                        print('Error during parse of last highlighed file, skipping it and moving '
                              'forward')
                    continue
    return fun


# Junk function, ignore
#
def forothers():
    print('junk')
