import re
import jinja2
import os
import os.path
from distutils.dir_util import copy_tree
from shutil import copy2


def generatedoc(outputdir, chainoffiles, listoffunctions, listofscripts,
                appendcode=False, verbose=False):

    projectlogopath = "..\\logo_POLARYS.png"

    listmod = __preformparameters(listoffunctions, which='functions', verbose=verbose)

    if not os.path.exists(outputdir):
        os.makedirs(outputdir)

    basedircss = os.path.join(outputdir, 'utils')
    if not os.path.exists(basedircss):
        os.makedirs(basedircss)

    # copy subdirectory example
    fromdirectory = ".\\templates\\utils"
    todirectory = basedircss

    copy_tree(fromdirectory, todirectory)
    copy2(projectlogopath, todirectory)

    filename = projectlogopath.split('\\')
    projectlogo = os.path.join(basedircss, filename[len(filename)-1])

    outsnames = []
    outspath = []
    for namein in chainoffiles:

        outsnames.append(namein[0:-2])
        outspath.append(os.path.join(outputdir, namein[0:-2]))

    templateloader = jinja2.FileSystemLoader(searchpath="./templates/")
    templateenv = jinja2.Environment(loader=templateloader)
    # This constant string specifies the template file we will use.
    template_file = "functionTemplate.jinja"
    template = templateenv.get_template(template_file)

    for index, file in enumerate(outsnames):

        for fun in listmod:
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

        code = []

        if appendcode:

            code = current.code

        templatevars = {"project_name": "POLARYS PROJECT",
                        "project_logo": projectlogo,
                        "style": basedircss,
                        "pathslist": outspath,
                        "dir": outputdir,
                        "fun": current,
                        "code": code
                        }
        try:
            outputtext = template.render(templatevars)

            with open(outspath[index]+".html", "w") as fh:
                fh.write(outputtext)
                fh.close()

        except ReferenceError:

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
# @version 1.1
def __preformparameters(listin, which='...', verbose=False):
    if verbose:
        print('Step 4) Preformatting ', which, ' parameters description...\n', sep='')

    for index, clas in enumerate(listin):

        if verbose:
            print('\t- Evaluating (', index + 1, '/', len(listin), ') element(s): ', clas.name,
                  '...', sep='')

        for oparam in clas.oparams:
            for idx, line in enumerate(oparam.desc):
                p = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
                linemod = p.sub(r'[<b><font color="#0000FF">\1</font></b>]', line)
                p = re.compile('{ ( [\w.^} ]* ) }', re.VERBOSE)
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
                p = re.compile('{ ( [\w.^} ]* ) }', re.VERBOSE)
                linemod = p.sub(r'{<u>\1</u>}', linemod)
                p = re.compile('\( ( [a-zA-Z\'\d^) ]* ) \)', re.VERBOSE)
                linemod = p.sub(r'(<i>\1</i>)', linemod)
                p = re.compile('([\w\']*):', re.VERBOSE)
                linemod = p.sub(r'<b>\1:</b>', linemod)
                iparam.desc[idx] = linemod

    return listin
