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
# @iparam log
# @iparam progbr
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 20/03/17
# @version 1.4
###
def formatlabfiles(pathvar, outputdir, projectlogo=None, projectname=None, recur=False,
                   appendcode=False, usage=False, verbose=False, log=None, prgbr=None):

    if log is not None:

        log('<b>EVENT!!!! Beginning process...</b>')
        log('<u>Step 1) Searching in directories:</u>')
    else:

        print('\EVENT!!!! Beginning process...')
        print('Step 1) Searching in directories:')

    if prgbr is not None:

        ind = 1
        prgbr(1)

    chainoffiles = []  # Array that will store the list of files
    chainofdirs = []  # Array that will store the paths of the files in chainOfFiles

    # Now iterate through the directories and, if 'recursive' is enabled, also through
    # subdirectories searching for m files

    # If the search is not recursive
    if not recur:

        for files in next(os.walk(pathvar)):
            for name in files:
                if name.endswith('.m'):

                    if prgbr is not None:
                        ind += 1
                        prgbr(ind)
                        if ind > 25:
                            ind = 1

                    if verbose:
                        if log is not None:
                            var = '- Fetching ' + name + '...'
                            log(var)
                        else:
                            print('\t- Fetching ', name, '...', sep='')
                    if not (name in chainoffiles):
                        chainoffiles.append(name)
                        chainofdirs.append(pathvar)

    # In other case, it is recursive
    else:

        for root, dirs, files in os.walk(pathvar):
            for name in files:
                if name.endswith('.m'):

                    if prgbr is not None:
                        ind += 1
                        prgbr(ind)
                        if ind > 25:
                            ind = 1

                    if verbose:
                        if log is not None:
                            var = '- Fetching ' + os.path.join(root, name) + '...'
                            log(var)
                        else:
                            print('\t- Fetching ', os.path.join(root, name), '...', sep='')
                    if not (name in chainoffiles):
                        chainoffiles.append(name)
                        chainofdirs.append(root)

    if prgbr is not None:
        ind = 25
        prgbr(ind)

    if verbose:
        if log is not None:
            var = '<b>EVENT!!!! Fetching process finished, found: ' + str(len(chainoffiles)) + ' elements in ' + \
                  str(len(set(chainofdirs))) + ' directories</b>'
            log(var)
        else:
            print('\nEVENT!!!! Fetching process finished, found: ', len(chainoffiles), ' elements in ',
                  len(set(chainofdirs)), ' directories\n', sep='')

    # Once fetching finishes, begin scanning files
    listoffunctions, listofscripts, listofclasses = __scanformfiles(chainoffiles, chainofdirs,
                                                                    appendcode=appendcode,
                                                                    usage=usage,
                                                                    verbose=verbose,
                                                                    log=log,
                                                                    prgbr=prgbr)

    generatedoc(outputdir, chainoffiles, chainofdirs, listoffunctions, listofscripts, listofclasses,
                projectlogopath=projectlogo, projectname=projectname, appendcode=appendcode, usage=usage,
                verbose=verbose, log=log, prgbr=prgbr)


# @desc Here there will be a loop over all .m files for getting the information of them
##
# @iparam chainoffiles
# @iparam chainofdirs
# @iparam appendcode
# @iparam usage
# @iparam verbose
# @iparam log
# @iparam progbr
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 20/03/17
# @version 1.2
###
def __scanformfiles(chainoffiles, chainofdirs, appendcode=False, usage=False, verbose=False, log=None, prgbr=None):

    if log is not None:

        log('<u>Step 2) Loading files to memory:</u>')
    else:
        print('Step 2) Loading files to memory:\n')

    if prgbr is not None:
        indx = 25 + round(len(chainoffiles)/24)

    index = 0
    # List of 'function' objects
    listoffunctions = []
    # List of 'script' objects
    listofscripts = []
    # List of 'script' objects
    listofclasses = []

    # Loop over all previously fetched files
    for fil in chainoffiles:

        if prgbr is not None:
            prgbr(indx)
            indx += 1
            if indx > 50:
                indx = 50

        if verbose:

            if log is not None:
                var = '- Opening file ' + os.path.join(chainofdirs[index], fil) + '...'
                log(var)
            else:
                print('\t- Opening file ', os.path.join(chainofdirs[index], fil), '...', sep='')

        # Open each file and get the header, specified by '%%%'
        fileid = open(os.path.join(chainofdirs[index], fil), 'r')
        index += 1

        code = []

        chunks = []

        ind = 0
        isscript = False
        isclass = False
        isheader = True

        for line in fileid:

            if isheader:

                # Check if its a script or not
                if ind == 0:

                    if 'classdef' in line:
                        isclass = True
                        isscript = False

                    elif '@desc' in line:
                        isscript = True
                        isclass = False

                    else:

                        isscript = False
                        isclass = False

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
            scr = __parsemscript(chunks, verbose=verbose, log=log)
            scr.name = fil[0:len(fil) - 2]

            if appendcode or usage:
                scr.addcode(code)

            listofscripts.append(scr)

        elif isclass:

            # Parse each function header
            cla = __parsemclass(chunks, verbose=verbose, log=log)
            cla.name = fil[0:len(fil) - 2]

            if appendcode or usage:
                cla.addcode(code)

            listofclasses.append(cla)

        else:

            # Parse each function header
            fun = __parsemfunct(chunks, verbose=verbose, log=log)
            fun.name = fil[0:len(fil) - 2]

            if appendcode or usage:
                fun.addcode(code)

            listoffunctions.append(fun)

    if verbose:
        if log is not None:
            log('<b>EVENT!!!! Loading process finished</b>')
        else:
            print('\nEVENT!!!! Loading process finished\n')

    if usage:
        listoffunctions, listofscripts, listofclasses = __checkusage(listoffunctions, listofscripts,
                                                                     listofclasses, verbose=verbose, log=log,
                                                                     prgbr=prgbr)

    return listoffunctions, listofscripts, listofclasses


# @desc This function checks if the usage between functions and scripts, as 'mutual calls'
##
# @iparam listoffunctions
# @iparam listofscripts
# @iparam listofclasses
# @iparam verbose
# @iparam log
# @iparam progbr
##
# @oparam listoffunctions
# @oparam listofscripts
# @oparam listofclasses
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.3
###
def __checkusage(listoffunctions, listofscripts, listofclasses, verbose=False, log=None, prgbr=None):
    merged = listoffunctions + listofscripts + listofclasses
    ind = 0

    if verbose:
        if log is not None:
            var = '- Checking mutual ussage among ' + str(len(merged)) + ' files:'
            log(var)
        else:
            print('\t- Checking mutual ussage among ', len(merged), ' files:\n', sep='')
        ind = 0

    if prgbr is not None:
        indx = 25
        prgbr(indx)
        indx += 1

    for x, y in itertools.permutations(merged, 2):

        if prgbr is not None:
            indx += 1
            prgbr(indx)
            if indx > 50:
                indx = 25

        if y.name in ' '.join(x.code):
            x.adduses(y.name)
            y.addusedby(x.name)

        if verbose:
            ind += 1
            if log is not None:
                var = '- Checked ' + str(ind) + '-th combination of files'
                log(var)
            else:
                print('\t- Checked ', ind, '-th combination of files', sep='')

    if prgbr is not None:
        indx = 50
        prgbr(indx)

    if verbose:
        if log is not None:
            log('<b>EVENT!!!! All combinations between files checked</b>')
        else:
            print('\nEVENT!!!! All combinations between files checked\n')

    listoffunctions = merged[0:len(listoffunctions)]
    listofscriptstmp = merged[len(listoffunctions):len(listoffunctions)+len(listofscripts)]
    listofclassestmp = merged[len(listoffunctions)+len(listofscripts):]

    listofscripts = listofscriptstmp
    listofclasses = listofclassestmp

    return listoffunctions, listofscripts, listofclasses


# This function parses the lines in the input list for a script file
# @iparam chunks
# @iparams verbose
# @iparam log
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.1
###
def __parsemscript(chunks, verbose=False, log=None):
    # 'Script' object definition
    scr = ScriptDefinition()

    # Current state, used for multi-line fields
    current = '@desc'

    if verbose:
        if log is not None:
            log('- Parsing...')
        else:
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

            if current != '%%' and (current == '@ref' and token != ''):

                try:

                    ({'@desc': scr.updatedesc, '@ref': scr.addref}[current])(token)

                except KeyError:

                    if verbose:

                        if log is not None:
                            log('ERROR!!!! during parse of last highlighted file, skipping it and moving forward')
                        else:
                            print('ERROR!!!! during parse of last highlighted file, skipping it and moving forward')

                    continue
    return scr


# This function parses the lines in the input list for a function file
# @iparam chunks
# @iparams verbose
# @iparam log
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.2
###
def __parsemfunct(chunks, verbose=False, log=None):
    # 'Function' object definition
    fun = FuncDefinition()
    # Current state, used for multi-line fields
    current = 'function'

    if verbose:
        if log is not None:
            log('- Parsing...')
        else:
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

            if current != '%%' and (current == '@ref' and token != ''):

                try:

                    ({'@summn': fun.updatesumm, '@desc': fun.updatedesc, '@ref': fun.addref,
                      '@iparam': fun.updateiparam, '@oparam': fun.updateoparam}[current])(token)

                except KeyError:

                    if verbose:
                        if log is not None:
                            log('ERROR!!!! during parse of last highlighted file, skipping it and moving forward')
                        else:
                            print('ERROR!!!! during parse of last highlighted file, skipping it and moving forward')
                    continue
    return fun


# This function parses the lines in the input list for a class file
# @iparam chunks
# @iparams verbose
# @iparam log
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 27/03/17
# @version 1.1
###
def __parsemclass(chunks, verbose=False, log=None):

    # 'Class' object definition
    cls = ClassDefinition()
    # Current state, used for multi-line fields
    current = 'classdef'

    if verbose:
        if log is not None:
            log('- Parsing...')
        else:
            print('\t- Parsing...')

    # Loop through the lines of the header searching for predefined tags and storing the relevant
    # information in a 'class' object
    for line in chunks:

        line = line.replace('\n', ' ')

        if current == 'classdef':

            token = line[line.find('classdef') + 9:len(line)].strip()

            cls.usage = token

            current = '@summ'

        elif current == '@summ':

            token = line.split(' ', 1)

            cls.updatesumm(''.join(token[1:len(token)]))

            current = '@summn'

        elif '@desc' in line:

            token = line[line.find('@desc') + 5:len(line)].strip()

            cls.updatedesc(token)

            current = '@desc'

        elif '@ref' in line:

            token = line[line.find('@ref') + 4:len(line)].strip()

            cls.addref(token)

            current = '@ref'

        elif '@method' in line:

            token = line[line.find('@method') + 8:len(line)].strip()

            cls.addmethod(token)

            current = '@method'

        elif '@event' in line:

            token = line[line.find('@event') + 7:len(line)].strip()

            cls.addevent(token)

            current = '@event'

        elif '@attribute' in line:

            token = line[line.find('@attribute') + 11:len(line)].strip()

            cls.addattribute(token)

            current = '@attribute'

        elif '@property' in line:

            token = line[line.find('@property') + 9:len(line)].strip()

            cls.addproperty(token)

            current = '@property'

        elif '@author' in line:

            token = line[line.find('@author') + 7:len(line)].strip()

            cls.author = token

            current = '@author'

        elif '@company' in line:

            token = line[line.find('@company') + 8:len(line)].strip()

            cls.company = token

            current = '@company'

        elif '@date' in line:

            token = line[line.find('@date') + 5:len(line)].strip()

            cls.date = token

            current = '@date'

        elif '@version' in line:

            token = line[line.find('@version') + 8:len(line)].strip()

            cls.version = token

            current = '@version'

        elif '%%' in line:

            current = '%%'

        else:

            token = line[1:len(line) - 1].strip()

            if current != '%%' and (current == '@ref' and token != ''):

                try:

                    ({'@summn': cls.updatesumm, '@desc': cls.updatedesc, '@ref': cls.addref,
                      '@method': cls.updatemethod, '@property': cls.updateproperty, '@attribute':
                      cls.updateattribute, '@event': cls.updateevent}[current])(token)

                except KeyError:

                    if verbose:
                        if log is not None:
                            log('ERROR!!!! during parse of last highlighted file, skipping it and moving forward')
                        else:
                            print('ERROR!!!! during parse of last highlighted file, skipping it and moving forward')
                    continue
    return cls
