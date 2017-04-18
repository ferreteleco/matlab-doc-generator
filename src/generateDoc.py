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
# @iparam listoffunctions
# @iparam listofscripts
# @iparam listofclasses
# @iparam verbose
# @iparam usage
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 27/03/17
# @version 1.4
###
def generatedoc(outputdir, chainoffiles, listoffunctions, listofscripts, listofclasses,
                projectlogopath=None, projectname='', appendcode=False, usage=False, verbose=False, log=None):

    if log is not None:
        log('Step 3) Beginning preformatting:\n')
    else:
        print('Step 3) Beginning preformatting:\n')

    ver = 1.2

    listfuncmod = __preformparameters(listoffunctions, wh='functions', verbose=verbose, log=log)
    listclassmod = __preformparameters(listofclasses, wh='classes', verbose=verbose, log=log)

    if verbose:

        if log is not None:
            log('\nEVENT!!!! All files preformatted\n')
        else:
            print('\nEVENT!!!! All files preformatted\n')

    if log is not None:
        log('Step 4) Beginning file dumping:\n')
    else:
        print('Step 4) Beginning file dumping:\n')

    if not os.path.exists(outputdir):

        if verbose:
            if log is not None:
                var = '- Creating output directory: ' + outputdir
                log(var)
            else:
                print('\t- Creating output directory: ', outputdir, sep='')

        os.makedirs(outputdir)

    if not os.path.exists(os.path.join(outputdir, "files")):

        if verbose:
            if log is not None:
                var = '- Creating output directory: ' + os.path.join(outputdir, "files")
                log(var)
            else:
                print('\t- Creating output directory: ', os.path.join(outputdir, "files"), sep='')

        os.makedirs(os.path.join(outputdir, "files"))

    basedircss = os.path.join(outputdir, 'utils')

    if not os.path.exists(basedircss):

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

    if verbose:
        if log is not None:
            log('- Copying utils to destination directory.')
        else:
            print('\t- Copying utils to destination directory.')

    copy_tree(fromdirectory, todirectory)

    # Copy project logo to output directory
    if projectlogopath is not None:

        if verbose:
            if log is not None:
                log('- Copying project logo to destination directory.')
            else:
                print('\t- Copying project logo to destination directory.')

        copy2(projectlogopath, todirectory)

        filename = projectlogopath.split('\\')

        projectlogo = os.path.join("./utils", filename[len(filename)-1])

    else:

        projectlogo = ''

    outsnames = []
    outspath = []

    if verbose:
        if log is not None:
            log('- Generating output paths and names.')
        else:
            print('\t- Generating output paths and names.')

    for namein in chainoffiles:

        outsnames.append(namein[0:-2])
        outspath.append(os.path.join(os.path.join(outputdir, 'files'), namein[0:-2]))

    # Template loader for Jinja2 templates
    templateloader = jinja2.FileSystemLoader(searchpath=base+"/templates/")
    templateenv = jinja2.Environment(loader=templateloader)

    # This constant string specifies the template file we will use.
    template_file = "indexTemplate.jinja"

    # Read the template file using the environment object.
    # This also constructs our Template object.
    template = templateenv.get_template(template_file)

    templatevars = {"project_name": projectname,
                    "project_logo": projectlogo,
                    "style": "./utils",
                    "functions": listoffunctions,
                    "classes": listofclasses,
                    "date": time.strftime("%a %d/%m/%Y at %H:%S"),
                    "scripts": listofscripts,
                    "version": ver
                    }
    try:

        if verbose:
            if log is not None:
                log('- Rendering template: index.html...')
            else:
                print('\t- Rendering template: index.html...')

        outputtext = template.render(templatevars)

        with open(os.path.join(outputdir, "index.html"), "w") as fh:

            if verbose:
                if log is not None:
                    var = '- Saving file to: ' + outputdir + '\\index.html ...'
                    log(var)
                else:
                    print('\t- Saving file to: ', outputdir, '\\index.html ...', sep='')
            fh.write(outputtext)
            fh.close()

    except ReferenceError:

        if log is not None:
            log('Fatal error')
        else:
            print('Fatal error')

    for index, file in enumerate(outsnames):

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

        templatevars = {"project_name": projectname,
                        "project_logo": projectlogo,
                        "style": "../utils",
                        "pathslist": outsnames,
                        "dir": outputdir,
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

            with open(outspath[index]+".html", "w") as fh:

                if verbose:
                    if log is not None:
                        var = '- Saving file to: ' + outspath[index]+".html" + ' ...'
                        log(var)
                    else:
                        print('\t- Saving file to: ', outspath[index]+".html", ' ...', sep='')

                fh.write(outputtext)
                fh.close()

        except ReferenceError:

            if log is not None:
                log('Fatal error')
            else:
                print('Fatal error')


# This function adds highlighting and font color for types found in parameters description of the
# function or class given lists
##
# @iparam listin
# @iparam which
# @iparam verbose
##
# @oparam modifiedlist
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 23/03/17
# @version 1.3
def __preformparameters(listin, wh='...', verbose=False, log=None):

    if verbose is True:
        if log is not None:
            var = '- Preformatting ' + wh + ' parameters description...\n'
            log(var)
        else:
            print('\t- Preformatting ', wh, ' parameters description...\n', sep='')

    if wh == 'functions':

        for index, clas in enumerate(listin):

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
# @iparam verbose
##
# @oparam parsedcode
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 27/03/17
# @version 1.5
def __parsecode(inputcode):

    parsedcode = []

    for line in inputcode:

        line = line.replace('<', '&lt;').replace('>', '&gt;')

        if line[0] == '%':
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
