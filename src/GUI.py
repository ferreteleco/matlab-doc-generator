from PyQt5 import QtWidgets, QtGui
from wizard import Ui_MainWindow
import sys
import time
import os


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
        self.browseidir.clicked.connect(self.__browse_idir)
        self.browseodir.clicked.connect(self.__browse_odir)
        self.browselogo.clicked.connect(self.__browse_logo)
        self.verbose.clicked.connect(self.__isverbose)
        self.code.clicked.connect(self.__appendcode)
        self.usage.clicked.connect(self.__checkusage)
        self.recursive.clicked.connect(self.__maderecursive)
        self.generate.clicked.connect(self.__lestdocalcs)

        # Parse checking correctness of input and output directories
        self.idir.editingFinished.connect(self.__dbg)
        self.odir.editingFinished.connect(self.__dbg)
        self.logo.editingFinished.connect(self.__dbg)

        # Parameters used to feed document generation
        self.updatelog = self.console.append
        self.updatetaskbar = self.taskprogress.setValue
        self.updateprogbar = self.overallprogress.setValue
        self.__idir = None
        self.__odir = None
        self.__name = None
        self.__logo = None
        self.__verbose = False
        self.__code = False
        self.__usage = False
        self.__recursive = False

    # Thrash method, used for debug
    def __dbg(self):

        self.updatelog('haschanged')

    def __browse_idir(self):
        idir = QtWidgets.QFileDialog.getExistingDirectory(parent=None,
                                                          caption="Select source base directory",
                                                          directory=".\\",
                                                          options=QtWidgets.QFileDialog.ShowDirsOnly)
        if idir:
            self.__idir = idir
            self.idir.setText(idir)

    def __browse_odir(self):
        odir = QtWidgets.QFileDialog.getExistingDirectory(parent=None,
                                                          caption="Select output base directory",
                                                          directory=".\\",
                                                          options=QtWidgets.QFileDialog.ShowDirsOnly)
        if odir:
            self.__odir = odir
            self.odir.setText(odir)

    def __browse_logo(self):
        logo = QtWidgets.QFileDialog.getOpenFileName(parent=None,
                                                     caption="Select project logo",
                                                     directory=".\\",
                                                     filter="Image File(*.png *.jpg)")
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

    def __lestdocalcs(self):

        self.updatelog('<FONT color="green"> aaaaaa <br> ksdsdjaslkjasd </font>')
        for i in range(0, 101):
            self.taskprogress.setValue(i)
            time.sleep(0.05)


if __name__ == '__main__':

    app = QtWidgets.QApplication(sys.argv)
    prog = GUIDocGen()
    prog.show()

    sys.exit(app.exec_())
