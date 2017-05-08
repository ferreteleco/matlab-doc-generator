import re
import jinja2
import os
import os.path
from distutils.dir_util import copy_tree
from shutil import copy2
import time


# @desc This function generates the documentation files in HTML by using Jinja2 templating
##
# @iparam outputdir
# @iparam chainoffiles
# @iparam chainofdirs
# @iparam listoffunctions
# @iparam listofscripts
# @iparam listofclasses
# @iparam verbose
# @iparam usage
# @iparam log
# @iparam progbr
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 27/03/17
# @version 1.6
###
def generatedoc(outputdir, chainoffiles, chainofdirs, listoffunctions, listofscripts, listofclasses,
                projectlogopath=None, projectname='', appendcode=False, usage=False, verbose=False, log=None,
                prgbr=None):

    if log is not None:
        log('<u>Step 3) Beginning preformatting:</u>')
    else:
        print('Step 3) Beginning preformatting:\n')

    ver = 3.1

    listfuncmod = __preformparameters(listoffunctions, wh='functions', verbose=verbose, log=log, prgbr=prgbr)
    listclassmod = __preformparameters(listofclasses, wh='classes', verbose=verbose, log=log, prgbr=prgbr)

    outputdir = os.path.realpath(outputdir)

    if prgbr is not None:
        ind = 75
        prgbr(ind)

    if verbose:

        if log is not None:
            log('<b>EVENT!!!! All files preformatted</b>')
        else:
            print('\nEVENT!!!! All files preformatted\n')

    if log is not None:
        log('<u>Step 4) Beginning file dumping:</u>')
    else:
        print('Step 4) Beginning file dumping:\n')

    if not os.path.exists(outputdir):

        if prgbr is not None:
            ind = 76
            prgbr(ind)

        if verbose:
            if log is not None:
                var = '- Creating output directory: ' + outputdir
                log(var)
            else:
                print('\t- Creating output directory: ', outputdir, sep='')

        os.makedirs(outputdir)

    if not os.path.exists(os.path.join(outputdir, "files")):

        if prgbr is not None:
            ind = 77
            prgbr(ind)

        if verbose:
            if log is not None:
                var = '- Creating output directory: ' + os.path.join(outputdir, "files")
                log(var)
            else:
                print('\t- Creating output directory: ', os.path.join(outputdir, "files"), sep='')

        os.makedirs(os.path.join(outputdir, "files"))

    basedircss = os.path.join(outputdir, 'utils')

    if not os.path.exists(basedircss):

        if prgbr is not None:
            ind = 78
            prgbr(ind)

        if verbose:
            if log is not None:
                var = '- Creating CSS&icons directory: ' + basedircss
                log(var)
            else:
                print('\t- Creating CSS&icons directory: ', basedircss, sep='')

        os.makedirs(basedircss)

    # Copy utils (CSS and icons) to output directory
    base = os.path.realpath(__file__).split('\\')
    base = '\\'.join(base[0:-1])
    fromdirectory = base+"\\templates\\utils"
    todirectory = basedircss

    if prgbr is not None:
        ind = 79
        prgbr(ind)

    if verbose:
        if log is not None:
            log('- Copying utils to destination directory.')
        else:
            print('\t- Copying utils to destination directory.')

    copy_tree(fromdirectory, todirectory)

    # Copy project logo to output directory
    if projectlogopath is not None:

        if prgbr is not None:
            ind = 80
            prgbr(ind)

        if verbose:
            if log is not None:
                log('- Copying project logo to destination directory.')
            else:
                print('\t- Copying project logo to destination directory.')

        copy2(projectlogopath, todirectory)

        if '\\' in projectlogopath:
            filename = projectlogopath.split('\\')
        else:
            filename = projectlogopath.split('/')

        projectlogo = filename[len(filename)-1]

        print(projectlogo)

    else:

        if prgbr is not None:
            ind = 80
            prgbr(ind)

        projectlogo = ''

    outsnames = []
    outsroutes = []
    outspath = []
    outsrel = []

    outputdirfiles = os.path.join(outputdir, "files")

    if verbose:
        if log is not None:
            log('- Generating output paths and names.')
        else:
            print('\t- Generating output paths and names.')

    if prgbr is not None:
        ind = 80 + round(len(chainoffiles)/10)

    basedirs = os.path.commonprefix(chainofdirs)

    for indx, namein in enumerate(chainoffiles):

        if prgbr is not None:
            prgbr(ind)
            ind += 1
            if ind > 90:
                ind = 80

        curdir = chainofdirs[indx].replace(basedirs, '')
        outsnames.append(namein[0:-2])

        if curdir is '':
            outspath.append(os.path.join(outputdirfiles, 'root'))
            outsrel.append('files/root')
            outsroutes.append(['files/root', namein[0:-2]])
        else:
            outspath.append(os.path.join(outputdirfiles, curdir[1:]))
            outsrel.append('files/'+curdir[1:])
            outsroutes.append(['files/'+curdir[1:], namein[0:-2]])

    # Template loader for Jinja2 templates
    templateloader = jinja2.FileSystemLoader(searchpath=base + "/templates/")
    templateenv = jinja2.Environment(loader=templateloader)

    cmmprfxout = os.path.commonprefix(list(set(outspath)))

    for it in (set(outspath)):

        if not os.path.exists(it):
            os.makedirs(it)

        if verbose:
            if log is not None:
                var = '- Creating output directory: ' + it
                log(var)
            else:
                print('\t- Creating output directory: ', it, sep='')

        indxs = [index for index, item in enumerate(outspath) if item == it]

        funs = []
        scrs = []
        clss = []

        for ii, funx in enumerate(listoffunctions):

            if funx.name in [outsnames[i] for i in indxs]:
                funs.append(funx)
                listoffunctions[ii].path = 'files/'+it.replace(cmmprfxout, '')

        for ii, scrx in enumerate(listofscripts):

            if scrx.name in [outsnames[i] for i in indxs]:
                scrs.append(scrx)
                listofscripts[ii].path = 'files/'+it.replace(cmmprfxout, '')

        for ii, cl in enumerate(listofclasses):

            if cl.name in [outsnames[i] for i in indxs]:
                clss.append(cl)
                listofclasses[ii].path = 'files/'+it.replace(cmmprfxout, '')

        # This constant string specifies the template file we will use.
        template_file = "indexFolderTemplate.jinja"

        # Read the template file using the environment object.
        # This also constructs our Template object.
        template = templateenv.get_template(template_file)

        bsst = it.replace(cmmprfxout, '').split()
        bss = '../'*(len(bsst)+1)

        templatevars = {"base": bss,
                        "project_name": projectname,
                        "project_logo": projectlogo,
                        "project_folders": sorted(list(set(outsrel))),
                        "pathslist": outsroutes,
                        "functions": funs,
                        "classes": clss,
                        "date": time.strftime("%a %d/%m/%Y at %H:%S"),
                        "scripts": scrs,
                        "currfold": 'files/'+it.replace(cmmprfxout, ''),
                        "version": ver
                        }
        try:

            if verbose:
                if log is not None:
                    log('- Rendering template: index.html...')
                else:
                    print('\t- Rendering template: index.html...')

            outputtext = template.render(templatevars)

            with open(os.path.join(it, "index.html"), "w") as fh:

                if verbose:
                    if log is not None:
                        var = '- Saving file to: ' + it + '\\index.html ...'
                        log(var)
                    else:
                        print('\t- Saving file to: ', it, '\\index.html ...', sep='')
                fh.write(outputtext)
                fh.close()

        except ReferenceError:

            if log is not None:
                log('Fatal error')
            else:
                print('Fatal error')

        if prgbr is not None:
            ind = 90

    # This constant string specifies the template file we will use.
    template_file = "indexTemplate.jinja"

    # Read the template file using the environment object.
    # This also constructs our Template object.
    template = templateenv.get_template(template_file)

    templatevars = {"base": './',
                    "project_name": projectname,
                    "project_logo": projectlogo,
                    "project_folders": sorted(list(set(outsrel))),
                    "pathslist": outsroutes,
                    "functions": listoffunctions,
                    "classes": listofclasses,
                    "date": time.strftime("%a %d/%m/%Y at %H:%S"),
                    "scripts": listofscripts,
                    "version": ver
                    }
    try:

        if projectname == '':
            name = 'index.html'
        else:
            name = projectname.lower().replace(' ', '_')+'.html'

        if verbose:
            if log is not None:
                var = '- Rendering template: ' + name
                log(var)
            else:
                print('\t- Rendering template: ' + name + '...')

        outputtext = template.render(templatevars)

        with open(os.path.join(outputdir, name), "w") as fh:

            if verbose:
                if log is not None:
                    var = '- Saving file to: ' + outputdir + '\\' + name + '...'
                    log(var)
                else:
                    print('\t- Saving file to: ', outputdir, '\\' + name + '...', sep='')
            fh.write(outputtext)
            fh.close()

    except ReferenceError:

        if log is not None:
            log('Fatal error')
        else:
            print('Fatal error')

    if prgbr is not None:
        ind = 90

    for index, file in enumerate(outsnames):

        if prgbr is not None:
            prgbr(ind)
            ind += 1
            if ind > 99:
                ind = 90

        for fun in listfuncmod:
            if file == fun.name:
                current = fun
                template_file = "functionTemplate.jinja"

                # Read the template file using the environment object.
                # This also constructs our Template object.
                template = templateenv.get_template(template_file)
                break

        for scr in listofscripts:

            if file == scr.name:
                current = scr
                template_file = "scriptTemplate.jinja"

                # Read the template file using the environment object.
                # This also constructs our Template object.
                template = templateenv.get_template(template_file)
                break

        for cls in listclassmod:

            if file == cls.name:
                current = cls
                template_file = "classTemplate.jinja"

                # Read the template file using the environment object.
                # This also constructs our Template object.
                template = templateenv.get_template(template_file)
                break

        code = None

        if appendcode:

            if verbose:
                if log is not None:
                    var = '- Parsing code of : ' + current.name + ' ...'
                    log(var)
                else:
                    print('\t- Parsing code of : ', current.name, ' ...', sep='')

            code = __parsecode(current.code)

        bsst = outspath[index].replace(cmmprfxout, '').split()
        bss = '../' * (len(bsst)+1)

        templatevars = {"base": bss,
                        "project_name": projectname,
                        "project_logo": projectlogo,
                        "project_folders": sorted(list(set(outsrel))),
                        "pathslist": outsroutes,
                        "currbase": outspath[index].replace(cmmprfxout, ''),
                        "fun": current,
                        "date": time.strftime("%a %d/%m/%Y at %H:%S"),
                        "usage": usage,
                        "code": code,
                        "version": ver
                        }

        try:

            if verbose:
                if log is not None:
                    var = '- Rendering template: ' + current.name + ' ...'
                    log(var)
                else:
                    print('\t- Rendering template: ', current.name, ' ...', sep='')

            outputtext = template.render(templatevars)

            with open(os.path.join(outspath[index], outsnames[index]+".html"), "w") as fh:

                if verbose:
                    if log is not None:
                        var = '- Saving file to: ' + os.path.join(outspath[index], outsnames[index]+".html") + ' ...'
                        log(var)
                    else:
                        print('\t- Saving file to: ', os.path.join(outspath[index], outsnames[index]+".html"),
                              ' ...', sep='')

                fh.write(outputtext)
                fh.close()

        except ReferenceError:

            if log is not None:
                log('<FONT color="red"><b>Fatal error</b></FONT>')
            else:
                print('Fatal error')


# This function adds highlighting and font color for types found in parameters description of the
# function or class given lists
##
# @iparam listin
# @iparam which
# @iparam verbose
# @iparam log
# @iparam progbr
##
# @oparam modifiedlist
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 23/03/17
# @version 1.4
def __preformparameters(listin, wh='...', verbose=False, log=None, prgbr=None):

    if verbose is True:
        if log is not None:
            var = '- Preformatting ' + wh + ' parameters description...'
            log(var)
        else:
            print('\t- Preformatting ', wh, ' parameters description...\n', sep='')

    if prgbr is not None:
        ind = 50

    if wh == 'functions':

        for index, clas in enumerate(listin):

            if prgbr is not None:
                ind += index
                if ind > 75:
                    ind = 50
                prgbr(ind)

            if verbose:
                if log is not None:
                    var = '- Evaluating (' + str(index + 1) + '/' + str(len(listin)) + ') element(s): ' + clas.name + \
                          '...'
                    log(var)
                else:
                    print('\t- Evaluating (', index + 1, '/', len(listin), ') element(s): ', clas.name, '...', sep='')

            for oparam in clas.oparams:
                for idx, line in enumerate(oparam.desc):
                    p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                    linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                    p = re.compile('{ ( [^} ]* ) }', re.VERBOSE)
                    linemod = p.sub(r'{<u>\1</u>}', linemod)
                    p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                    linemod = p.sub(r'(<i>\1</i>)', linemod)
                    p = re.compile('([\w\']*):', re.VERBOSE)
                    linemod = p.sub(r'<b>\1:</b>', linemod)
                    oparam.desc[idx] = linemod

            for iparam in clas.iparams:
                for idx, line in enumerate(iparam.desc):
                    p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                    linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                    p = re.compile('{ ( [^} ]* ) }', re.VERBOSE)
                    linemod = p.sub(r'{<u>\1</u>}', linemod)
                    p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                    linemod = p.sub(r'(<i>\1</i>)', linemod)
                    p = re.compile('([\w\']*):', re.VERBOSE)
                    linemod = p.sub(r'<b>\1:</b>', linemod)
                    iparam.desc[idx] = linemod

    elif wh == 'classes':

        for index, clas in enumerate(listin):

            if prgbr is not None:
                ind += index
                if ind > 75:
                    ind = 50
                prgbr(ind)

            if verbose:
                if log is not None:
                    var = '- Evaluating (' + str(index + 1) + '/' + str(len(listin)) + ') element(s): ' + clas.name + \
                          '...'
                    log(var)
                else:
                    print('\t- Evaluating (', index + 1, '/', len(listin), ') element(s): ', clas.name, '...', sep='')

            for event in clas.events:
                for idx, line in enumerate(event.desc):
                    p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                    linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                    p = re.compile('{ ( [^} ]* ) }', re.VERBOSE)
                    linemod = p.sub(r'{<u>\1</u>}', linemod)
                    p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                    linemod = p.sub(r'(<i>\1</i>)', linemod)
                    p = re.compile('([\w\']*):', re.VERBOSE)
                    linemod = p.sub(r'<b>\1:</b>', linemod)
                    event.desc[idx] = linemod

            for attribute in clas.attributes:
                for idx, line in enumerate(attribute.desc):
                    p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                    linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                    p = re.compile('{ ( [^} ]* ) }', re.VERBOSE)
                    linemod = p.sub(r'{<u>\1</u>}', linemod)
                    p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                    linemod = p.sub(r'(<i>\1</i>)', linemod)
                    p = re.compile('([\w\']*):', re.VERBOSE)
                    linemod = p.sub(r'<b>\1:</b>', linemod)
                    attribute.desc[idx] = linemod

            for prop in clas.properties:
                for idx, line in enumerate(prop.desc):
                    p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                    linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                    p = re.compile('{ ( [^} ]* ) }', re.VERBOSE)
                    linemod = p.sub(r'{<u>\1</u>}', linemod)
                    p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                    linemod = p.sub(r'(<i>\1</i>)', linemod)
                    p = re.compile('([\w\']*):', re.VERBOSE)
                    linemod = p.sub(r'<b>\1:</b>', linemod)
                    prop.desc[idx] = linemod

            for method in clas.methods:
                for idx, line in enumerate(method.desc):
                    p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                    linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                    p = re.compile('{ ( [^} ]* ) }', re.VERBOSE)
                    linemod = p.sub(r'{<u>\1</u>}', linemod)
                    p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                    linemod = p.sub(r'(<i>\1</i>)', linemod)
                    p = re.compile('([\w\']*):', re.VERBOSE)
                    linemod = p.sub(r'<b>\1:</b>', linemod)
                    method.desc[idx] = linemod

    else:

        if verbose:
            if log is not None:
                var = '- Unrecognized element: ' + wh + '. No operations performed.'
                log(var)
            else:
                print('\t- Unrecognized element: ', wh, '. No operations performed.', sep='')

    return listin


# This function adds basic syntax highlighting for code elements
##
# @iparam imputcode
##
# @oparam parsedcode
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 27/03/17
# @version 1.6
def __parsecode(inputcode):

    parsedcode = []

    for line in inputcode:

        line = line.replace('<', '&lt;').replace('>', '&gt;')

        aux = line.lstrip()

        if aux == '':
            aux = '###############'
            
        if line[0] == '%' or aux[0] == '%':
            parsedcode.append('<span class="comm">'+line+'</span>')

        else:

            p = re.compile('(?<!\'|\w|>)(\'[^\']*\')(?!\')', re.VERBOSE)
            linemod = p.sub(r'<span class="string">\1</span>', line)

            if '<span ' not in linemod:

                p = re.compile('((?<!\'|\w|\$|%|@|>)(end|elseif|else|if|switch|case|otherwise'
                               '|break|continue|properties|methods|function|classdef|for|try|catch)'
                               '(?!\'))', re.VERBOSE)

                linemod = p.sub(r'<span class="keyword">\1</span>', linemod)

            else:

                litemp = linemod

                p = re.compile('((?<!\'|\w|\$|%|@|>)(end|elseif|else|if|switch|case|otherwise'
                               '|break|continue|properties|methods|function|classdef|for|try|catch)'
                               '(?!\'))', re.VERBOSE)

                indini = litemp.index('<span')

                linem = linemod[0:indini]

                linem = p.sub(r'<span class="keyword">\1</span>', linem)

                linemod = linem + litemp[indini:]

            if '% ' in linemod:

                ind = linemod.index('% ')
                indspa = ind - ind

                if '<span class="string">' in linemod or '<span class="keyword">'in linemod:

                    indspa = linemod.index('</span>')

                if indspa < ind:

                    linemod = linemod[0:ind]+linemod[ind:].replace('<span class="keyword">', '')\
                        .replace('<span class="string">', '').replace('</span>', '')
                    linemod = linemod.replace('% ', '<span class="comm">% ')+'</span>'

            elif '%%%' in linemod:

                ind = linemod.index('%%%')
                linemod = linemod[0:ind] + linemod[ind:].replace('<span class="keyword">', '') \
                    .replace('<span class="string">', '')
                linemod = linemod.replace('%%%', '<span class="comm">%%%')+'</span>'

            parsedcode.append(linemod)

    return parsedcode
