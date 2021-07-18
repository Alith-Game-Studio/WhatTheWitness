import os
import shutil
EDITOR_PATH = R'D:\Programming\WitnessVisualizer\WitnessVisualizer\bin\Release'
BUILD_FOLDER = '_build'
BUILD_ZIP = 'build.zip'

IGNORE_EXTENSIONS = ['.zip', '.rar', '.docx', '.pdb', '.config']

def copy_editor():
    shutil.copytree(EDITOR_PATH, BUILD_FOLDER)
    os.rename(os.path.join(BUILD_FOLDER, 'WitnessVisualizer.exe'), os.path.join(BUILD_FOLDER, 'Editor.exe'))
    shutil.rmtree(os.path.join(BUILD_FOLDER, 'Puzzles'))
    for file in os.listdir(BUILD_FOLDER):
        base, ext = os.path.splitext(file)
        if (ext.lower() in IGNORE_EXTENSIONS):
            os.unlink(os.path.join(BUILD_FOLDER, file))
        if (file.lower() == 'templategenerator.exe'):
            os.unlink(os.path.join(BUILD_FOLDER, file))

if __name__ == '__main__':
    try:
        shutil.rmtree(BUILD_FOLDER)
    except:
        pass
    copy_editor()
    shutil.copytree('../../puzzles', os.path.join(BUILD_FOLDER, 'puzzles'))
    shutil.copyfile('../../Credits.txt', os.path.join(BUILD_FOLDER, 'Credits.txt'))
    shutil.copyfile('Custom Witness Puzzles.exe', os.path.join(BUILD_FOLDER, 'Player.exe'))
    shutil.copyfile('Custom Witness Puzzles.pck', os.path.join(BUILD_FOLDER, 'Player.pck'))
    try:
        os.unlink(BUILD_ZIP)
    except:
        pass
    shutil.make_archive(os.path.splitext(BUILD_ZIP)[0], 'zip', BUILD_FOLDER)
    shutil.rmtree(BUILD_FOLDER)