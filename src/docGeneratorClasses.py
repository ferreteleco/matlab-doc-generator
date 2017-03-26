import time
import re


# This class is used to store the data extracted from the different headers analized for functions
##
# @iparam name
# @iparam usage
# @iparam author
# @iparam desc
# @iparam date
# @iparam version
# @iparam iparams
# @iparam oparams
# @iparam summ
# @iparam refs
# @iparam company
# @iparam code
# @iparam usedby
# @iparam uses
##
# @method addiparam
# @method updateiparam
# @method addoparam
# @method updateiparam
# @method addref
# @method addcode
# @method updatedesc
# @method updatesumm
# @method adduses
# @method addusedby
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 21/03/17
# @version 1.3
###
class FuncDefinition:

    def __init__(self, name=None, usage=None, desc=None, author=None, date=None, version=None,
                 iparams=None, oparams=None, summ=None, refs=None, company=None, code=None,
                 usedby=None, uses=None):

        if name is None:
            self._name = ''
        else:
            self._name = name

        if usage is None:
            self._usage = ''
        else:
            self._usage = usage

        if desc is None:
            self._desc = []
        else:
            self._desc = [desc]

        if author is None:
            self._author = ''
        else:
            self._author = author

        if date is None:
            # dd/mm/yyyy format
            self._date = time.strftime("%d/%m/%Y")
        else:
            self._date = date

        if version is None:
            self._version = 1.0
        else:
            self._version = version

        if iparams is None:
            self._iparams = []
        else:
            tokens = iparams.split(' ')
            self._iparams = [ParamDefinition(name=tokens[1], typ=tokens[0].replace('[', '')
                                             .replace(']', ''),
                                             desc=''.join(tokens[2:len(tokens)]))]

        if oparams is None:
            self.oparams = []
        else:
            tokens = oparams.split(' ')
            self._oparams = [ParamDefinition(name=tokens[1], typ=tokens[0].replace('[', '')
                                             .replace(']', ''),
                                             desc=''.join(tokens[2:len(tokens)]))]

        if summ is None:
            self._summ = []
        else:
            self._summ = [summ]

        if refs is None:
            self._refs = []
        else:
            self._refs = [refs]

        if company is None:
            self._company = ''
        else:
            self._company = company

        if code is None:
            self._code = []
        else:
            self._code = [code]

        if usedby is None:
            self._usedby = []
        else:
            self._usedby = [usedby]

        if uses is None:
            self._uses = []
        else:
            self._uses = [uses]

    # This method adds a new input param to the function object
    ##
    # @iparam param
    def addiparam(self, param):

        try:

            pin = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
            var = ''.join(pin.findall(param))

            tokens = param.split(' ', 2)
            par = ParamDefinition(name=tokens[1].replace(':', ''), typ=var, desc=''
                                  .join(tokens[2:]))
            self._iparams.append(par)
        except IndexError:
            self._iparams.append(ParamDefinition())

    # This method updates an existing input param by appending some text to its description
    ##
    # @iparam param
    def updateiparam(self, param):

        self._iparams[len(self._iparams)-1].updatedesc(param)

    # This method adds a new output param
    ##
    # @iparam param
    def addoparam(self, param):

        try:

            pin = re.compile('\[ ( [^\]]* ) \]', re.VERBOSE)
            typ = ''.join(pin.findall(param))
            pin = re.compile('\] ( [^:]* ) :', re.VERBOSE)
            nam = pin.findall(param)[0]
            indx = param.find(':')

            par = ParamDefinition(name=nam, typ=typ, desc=param[indx+1:])
            self._oparams.append(par)
        except IndexError:
            self._oparams.append(ParamDefinition())

    # This method updates an existing output param by appending some text to its desription
    ##
    # @iparam param
    def updateoparam(self, param):

            self._oparams[len(self._oparams)-1].updatedesc(param)

    # This method adds a new input reference to the function object
    ##
    # @iparam param
    def addref(self, param):

        self._refs.append(param)

    # This method updates the description of the function object by adding new information
    ##
    # @iparam param
    def updatedesc(self, param):
        self._desc.append(param)

    # This method updates the summary of the function object by adding new information
    ##
    # @iparam param
    def updatesumm(self, param):
        self._summ.append(param)

    # This method adds a reference of function taht uses the current script object
    ##
    # @iparam param
    def addusedby(self, param):

        if param not in ' '.join(self._usedby):
            self._usedby.append(param)

    # This method adds a new input reference to the script object
    ##
    # @iparam param
    def adduses(self, param):

        if param not in ' '.join(self._uses):
            self._uses.append(param)

    # This method adds a the code of the script to the function object
    ##
    # @iparam param
    def addcode(self, param):
        self.code = param

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        self._name = name

    @property
    def usage(self):
        return self._usage

    @usage.setter
    def usage(self, usage):
        self._usage = usage

    @property
    def desc(self):
        return '\n'.join(self._desc)

    @desc.setter
    def desc(self, desc):
        self._desc = desc

    @property
    def author(self):
        return self._author

    @author.setter
    def author(self, author):
        self._author = author

    @property
    def date(self):
        return self._date

    @date.setter
    def date(self, date):
        self._date = date

    @property
    def version(self):
        return self._version

    @version.setter
    def version(self, version):
        self._version = version

    @property
    def iparams(self):
        return self._iparams

    @iparams.setter
    def iparams(self, iparams):
        self.iparams = iparams

    @property
    def oparams(self):
        return self._oparams

    @oparams.setter
    def oparams(self, oparams):
        self._oparams = oparams

    @property
    def summ(self):
        return ' '.join(self._summ)

    @summ.setter
    def summ(self, summ):
        self._summ = summ

    @property
    def refs(self):
        return self._refs

    @refs.setter
    def refs(self, refs):
        self._refs = refs

    @property
    def company(self):
        return self._company

    @company.setter
    def company(self, company):
        self._company = company

    @property
    def code(self):
        return self._code

    @code.setter
    def code(self, code):
        self._code = code

    @property
    def usedby(self):
        return self._usedby

    @usedby.setter
    def usedby(self, usedby):
        self._usedby = usedby

    @property
    def uses(self):
        return self._uses

    @uses.setter
    def uses(self, uses):
        self._uses = uses


# This class is used to store the data extracted from the different headers analized for scripts
##
# @iparam name
# @iparam author
# @iparam desc
# @iparam date
# @iparam version
# @iparam refs
# @iparam company
# @iparam code
# @iparam usedby
# @iparam uses
##
# @method updatedesc
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.1
###
class ScriptDefinition:

    def __init__(self, name=None, desc=None, code=None, author=None, date=None, version=None,
                 refs=None, uses=None, usedby=None, company=None):

        if name is None:
            self._name = ''
        else:
            self._name = name

        if desc is None:
            self._desc = []
        else:
            self._desc = [desc]

        if code is None:
            self._code = []
        else:
            self._code = [code]

        if refs is None:
            self._refs = []
        else:
            self._refs = [refs]

        if company is None:
            self._company = ''
        else:
            self._company = company

        if code is None:
            self._code = []
        else:
            self._code = [code]

        if usedby is None:
            self._usedby = []
        else:
            self._usedby = [usedby]

        if uses is None:
            self._uses = []
        else:
            self._uses = [uses]

        if author is None:
            self._author = ''
        else:
            self._author = author

        if date is None:
            # dd/mm/yyyy format
            self._date = time.strftime("%d/%m/%Y")
        else:
            self._date = date

        if version is None:
            self._version = 1.0
        else:
            self._version = version

    # This method adds a reference of function taht uses the current script object
    ##
    # @iparam param
    def addusedby(self, param):

        if param not in ' '.join(self._usedby):
            self._usedby.append(param)

    # This method adds a new input reference to the script object
    ##
    # @iparam param
    def adduses(self, param):

        if param not in ' '.join(self._uses):
            self._uses.append(param)

    # This method adds a new input reference to the script object
    ##
    # @iparam param
    def addref(self, param):
        self._refs.append(param)

    # This method adds a the code of the script to the script object
    ##
    # @iparam param
    def addcode(self, param):
        self.code = param

    # This method updates the description of the script object by adding new information
    ##
    # @iparam param
    def updatedesc(self, param):
        self._desc.append(param)

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        self._name = name

    @property
    def refs(self):
        return self._refs

    @refs.setter
    def refs(self, refs):
        self._refs = refs

    @property
    def company(self):
        return self._company

    @company.setter
    def company(self, company):
        self._company = company

    @property
    def code(self):
        return self._code

    @code.setter
    def code(self, code):
        self._code = code

    @property
    def usedby(self):
        return self._usedby

    @usedby.setter
    def usedby(self, usedby):
        self._usedby = usedby

    @property
    def uses(self):
        return self._uses

    @uses.setter
    def uses(self, uses):
        self._uses = uses

    @property
    def desc(self):
        return '\n'.join(self._desc)

    @desc.setter
    def desc(self, desc):
        self._desc = desc

    @property
    def author(self):
        return self._author

    @author.setter
    def author(self, author):
        self._author = author

    @property
    def date(self):
        return self._date

    @date.setter
    def date(self, date):
        self._date = date

    @property
    def version(self):
        return self._version

    @version.setter
    def version(self, version):
        self._version = version


# This class is used to store the param data of the different headers analized
##
# @iparam name
# @iparam typ
# @iparam desc
##
# @method updatedesc
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 22/03/17
# @version 1.1
###
class ParamDefinition:

    def __init__(self, name=None, typ=None, desc=None):

        if name is None:
            self._name = ''
        else:
            self._name = name

        if typ is None:
            self._typ = ''
        else:
            self._typ = typ

        if desc is None:
            self._desc = []
        else:
            self._desc = [desc]

    # This method updates the description of a param by appending it new lines.
    def updatedesc(self, param):

        self._desc.append(param.replace('--->', '\t\t\t\t\t\t').replace('-->', '\t\t\t\t ')
                          .replace('->', '\t\t'))

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        self._name = name

    @property
    def typ(self):
        return self._typ

    @typ.setter
    def typ(self, typ):
        self._typ = typ

    @property
    def desc(self):
        return self._desc

    @desc.setter
    def desc(self, desc):
        self._desc = desc
