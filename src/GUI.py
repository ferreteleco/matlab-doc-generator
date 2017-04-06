from PyQt5 import QtWidgets
from wizard import Ui_MainWindow
import sys
import time


class GUIDocGen(Ui_MainWindow):
    def __init__(self, maiw):
        Ui_MainWindow.__init__(self)
        self.setupUi(maiw)

        # Connections between GUI and internal functions
        self.browseidir.clicked.connect(self.__browse_idir)
        self.browseodir.clicked.connect(self.__browse_odir)
        self.browselogo.clicked.connect(self.__browse_logo)
        self.verbose.clicked.connect(self.__isverbose)
        self.code.clicked.connect(self.__appendcode)
        self.usage.clicked.connect(self.__checkusage)
        self.recursive.clicked.connect(self.__maderecursive)
        self.generate.clicked.connect(self.__lestdocalcs)

        self.idir.textChanged.connect(self.__dbg)

        self.updatelog = self.console.append
        self.__idir = None
        self.__odir = None
        self.__name = None
        self.__logo = None
        self.__verbose = False
        self.__code = False
        self.__usage = False
        self.__recursive = False

    def __dbg(self):

        print('haschanged')

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

        self.updatelog('<FONT color="green"> aaaaaa </font>')
        for i in range(0, 101):
            self.taskprogress.setValue(i)
            time.sleep(0.05)


if __name__ == '__main__':

    app = QtWidgets.QApplication(sys.argv)
    mainw = QtWidgets.QMainWindow()

    prog = GUIDocGen(mainw)

    mainw.show()
    sys.exit(app.exec_())
