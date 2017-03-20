import os
import os.path

# Here the files will be allocated prior to opean each one ans get the parameters
def forMatlabFiles(pathVar, recur):

    # Do Debug
    print('First step')

    #############################################################################################
    chainOfFiles = []           # Array that will store the list of files
    chainOfDirs = []            # Array that will store the paths of the files in chainOfFiles

    # Now iterate through the directories and, if 'recursive' is enabled, also through subdirectories
    # searching for m files

    # If the search is not recursive
    if recur == 0:

        for _, _, files in os.walk(pathVar):
            for name in files:
                if name.endswith(('.m')):
                   # if not(name in chainOfFiles):
                        chainOfFiles.append(name)
                        chainOfDirs.append(pathVar)

    # In other case, it is recursive
    else:

        for root, dirs, files in os.walk(pathVar):
            for name in files:
                if name.endswith(('.m')):
                    # print(os.path.join(root,name))
                    if not(name in chainOfFiles):
                        chainOfFiles.append(name)
                        chainOfDirs.append(root)


    # DoDebug
    print(chainOfDirs)
    print(chainOfFiles)

    #############################################################################################

    #@TODO put the code above in a different functions file
    #@TODO next, open each file and fill an array of objects of class 'function' or class 'script'
    #@TODO define class 'function' and class 'script'


def forOthers():

    print('junk')


if __name__ == "__main__":

    pathVar = '.\Dir'
    var = 'mat'
    recur = 0

    try:

        ({'mat': forMatlabFiles, 'ker': forOthers}[var]) (pathVar,recur)
    except:
        print('Default gateway')