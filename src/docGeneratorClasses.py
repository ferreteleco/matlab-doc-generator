import time


# This class is used to store the data extracted from the different headers analized
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
##
# @method addiparam
# @method addoparam
# @method addref
# @method addcode
##
# @author Andres Ferreiro Gonzalez
# @company Own
# @date 21/03/17
# @version 1.0
class FuncDefinition:

    def __init__(self, name=None, usage=None, desc=None, author=None, date=None, version=None, iparams=None,
                 oparams=None, summ=None, refs=None, company=None, code=None):

        if name is None:
            self.name = ''
        else:
            self.name = name

        if usage is None:
            self.usage = ''
        else:
            self.usage = usage

        if desc is None:
            self.desc = []
        else:
            self.desc = [desc]

        if author is None:
            self.author = ''
        else:
            self.author = author

        if date is None:
            # dd/mm/yyyy format
            self.date = time.strftime("%d/%m/%Y")
        else:
            self.date = date

        if version is None:
            self.version = 1.0
        else:
            self.version = version

        if iparams is None:
            self.iparams = []
        else:
            self.iparams = [iparams]

        if oparams is None:
            self.oparams = []
        else:
            self.oparams = [oparams]

        if summ is None:
            self.summ = []
        else:
            self.summ = [summ]

        if refs is None:
            self.refs = []
        else:
            self.refs = [refs]

        if company is None:
            self.company = ''
        else:
            self.company = company

        if code is None:
            self.code = []
        else:
            self.code = [code]

    def addiparam(self, param):

        self.iparams.append(param)

    def addoparam(self, param):

        self.oparams.append(param)

    def addref(self, param):

        self.refs.append(param)

    def addcode(self, param):

        self.code.append(param)

    def adddesc(self, param):

        self.desc.append(param)

    def addsumm(self, param):

        self.summ.append(param)
