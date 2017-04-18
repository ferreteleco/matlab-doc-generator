from PyQt5 import QtWidgets, QtGui, QtCore
from wizard import Ui_MainWindow
from scanFromFiles import formatlabfiles
import sys
import time
import os
import imghdr


class processThread(QtCore.QThread):

    progress_data = QtCore.pyqtSignal(object)

    def __init__(self, idir, odir, projectlogo=None, projectname='', recur=False, appendcode=False, usage=False,
                 verbose=False):

        QtCore.QThread.__init__(self)
        self.__idir = idir
        self.__odir = odir
        self.__logo = projectlogo
        self.__name = projectname
        self.__recursive = recur
        self.__code = appendcode
        self.__usage = usage
        self.__verbose = verbose

    def run(self):

        self.progress_data.emit('<FONT weight="bold">Beginning process</font>')
        start = time.time()

        var = 'mfiles'
        ({'mfiles': formatlabfiles}[var])(self.__idir, self.__odir, projectlogo=self.__logo,
                                          projectname=self.__name, recur=self.__recursive,
                                          appendcode=self.__code, usage=self.__usage, verbose=self.__verbose,
                                          log=self.progress_data.emit)

        end = time.time()
        self.progress_data.emit('PROCESS FINISHED!!')
        var = '\nTook' + str(end - start) + 'seconds'
        self.progress_data.emit(var)
        self.progress_data.emit('succeeded')


class GUIDocGen(QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__(self):
        super(GUIDocGen, self).__init__()

        # Must use absolute path for displaying window icon
        base = os.path.realpath(__file__).split('\\')
        base = '\\'.join(base[0:-1])
        ico = base + "\\templates\\utils\\info.png"
        self.setWindowIcon(QtGui.QIcon(ico))

        self.setupUi(self)

        # Connections between GUI and internal functions
        self.resAll.clicked.connect(self.__resetall)
        self.resConsole.clicked.connect(self.__resetconsole)
        self.dumpLog.clicked.connect(self.__dumplog)
        self.browseidir.clicked.connect(self.__browse_idir)
        self.browseodir.clicked.connect(self.__browse_odir)
        self.browselogo.clicked.connect(self.__browse_logo)
        self.verbose.clicked.connect(self.__isverbose)
        self.code.clicked.connect(self.__appendcode)
        self.usage.clicked.connect(self.__checkusage)
        self.recursive.clicked.connect(self.__maderecursive)
        self.generate.clicked.connect(self.__lestdocalcs, QtCore.Qt.QueuedConnection)

        self.odir.editingFinished.connect(self.__isidir)
        self.odir.editingFinished.connect(self.__isodir)
        self.odir.editingFinished.connect(self.__isfile)

        # Parameters used to feed document generation
        self.updatelog = self.console.append
        self.__idir = None
        self.__odir = None
        self.__name = None
        self.__logo = None
        self.__verbose = False
        self.__code = False
        self.__usage = False
        self.__recursive = False
        self.__flagidir = False
        self.__flagodir = False
        self.threads = []

    def __dumplog(self):

        file = QtWidgets.QFileDialog.getSaveFileName(parent=None,
                                                     caption="Select file to dump log",
                                                     directory=".\\",
                                                     filter="Text File(*.txt .*log)")
        if file[0]:
            lines = self.console.toPlainText()

            file = open(file[0], 'w')

            for line in lines:
                file.write(line)

            file.close()

    def __resetconsole(self):

        self.console.setText('')

    def __resetall(self):

        self.idir.setText('')
        self.odir.setText('')
        self.logo.setText('')
        self.name.setText('')

        self.__resetconsole()

        self.code.setChecked(False)
        self.usage.setChecked(False)
        self.verbose.setChecked(False)
        self.recursive.setChecked(False)

    def __browse_idir(self):

        idir = QtWidgets.QFileDialog.getExistingDirectory(parent=None,
                                                          caption="Select source base directory",
                                                          directory=".\\",
                                                          options=QtWidgets.QFileDialog.ShowDirsOnly)
        if idir:
            self.__idir = idir
            self.idir.setText(idir)
            self.__flagidir = True

    def __browse_odir(self):
        odir = QtWidgets.QFileDialog.getExistingDirectory(parent=None,
                                                          caption="Select output base directory",
                                                          directory=".\\",
                                                          options=QtWidgets.QFileDialog.ShowDirsOnly)
        if odir:
            self.__odir = odir
            self.odir.setText(odir)
            self.__flagodir = True

    def __browse_logo(self):
        logo = QtWidgets.QFileDialog.getOpenFileName(parent=None,
                                                     caption="Select project logo",
                                                     directory=".\\",
                                                     filter="Image File(*.png *.jpg *.jpeg)")
        if logo[0]:
            self.__logo = logo[0]
            self.logo.setText(logo[0])

    def __isverbose(self):

        self.__verbose = self.verbose.isChecked()

    def __appendcode(self):

        self.__code = self.code.isChecked()

    def __checkusage(self):

        self.__usage = self.usage.isChecked()

    def __maderecursive(self):

        self.__recursive = self.recursive.isChecked()

    def __isidir(self):

        if self.idir.text() is None or self.idir.text() is "":
            pass
        else:
            self.__flagidir = os.path.isdir(self.idir.text())

            if self.__flagidir:
                self.__idir = self.idir.text()

    def __isodir(self):

        if self.odir.text() is None or self.odir.text() is "":
            pass
        else:
            self.__flagodir = os.path.isdir(self.odir.text())

            if self.__flagodir:
                self.__odir = self.odir.text()

    def __isfile(self):

        dic = ['png', 'jpg', 'ppp', 'jpeg', 'bmp']

        if self.logo.text() is None or self.logo.text() is "":
            pass

        else:
            tmpflg = os.path.isfile(self.logo.text())

            if tmpflg:
                typ = imghdr.what(self.logo.text())
                if typ in dic:
                    self.__logo = self.logo.text()

                else:
                    self.__logo = None
            else:
                self.__logo = None

    def __lestdocalcs(self):

        self.gooo()

    @QtCore.pyqtSlot()
    def gooo(self):

        self.__name = self.name.text()

        if self.__flagidir and self.__flagodir:
            process = processThread(self.__idir, self.__odir, projectlogo=self.__logo,
                                    projectname=self.__name, recur=self.__recursive,
                                    appendcode=self.__code, usage=self.__usage, verbose=self.__verbose)

            process.progress_data.connect(self.dbg)
            self.threads.append(process)
            process.start()

        else:
            QtWidgets.QMessageBox.warning(
                self, 'Error', 'Incorrect path for input/output directory')

    def dbg(self, data):

        print(data)
        self.updatelog(data)


if __name__ == '__main__':

    app = QtWidgets.QApplication(sys.argv)
    prog = GUIDocGen()
    prog.show()

    sys.exit(app.exec_())
