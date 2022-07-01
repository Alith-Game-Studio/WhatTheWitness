import os
import shutil
import sys
EDITOR_PATH = R'D:\Programming\WitnessVisualizer\WitnessVisualizer\bin\Release'
BUILD_FOLDER = '_build'
DEFAULT_BUILD_ZIP = 'build.zip'

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
    if (len(sys.argv) > 1):
        build_zip = sys.argv[1]
        if (not build_zip.endswith('.zip')):
            build_zip = build_zip + '.zip'
    else:
        build_zip = DEFAULT_BUILD_ZIP
    try:
        shutil.rmtree(BUILD_FOLDER)
    except:
        pass
    copy_editor()
    dir = os.getcwd()
    os.chdir('../..')
    os.system('Godot_v3.4.3-stable_mono_win64.exe --export "Windows Desktop"')
    os.chdir(dir)
    shutil.copytree('../../puzzles', os.path.join(BUILD_FOLDER, 'puzzles'))
    shutil.copyfile('Custom Witness Puzzles.exe', os.path.join(BUILD_FOLDER, 'Player.exe'))
    shutil.copyfile('Custom Witness Puzzles.pck', os.path.join(BUILD_FOLDER, 'Player.pck'))
    shutil.copyfile('csugar.dll', os.path.join(BUILD_FOLDER, 'csugar.dll'))
    try:
        os.unlink(build_zip)
        os.unlink(os.path.join(BUILD_FOLDER, 'Toolkit', 'current.toolkit'))
    except:
        pass
    try:
        os.unlink(build_zip)
    except:
        pass
    shutil.make_archive(os.path.splitext(build_zip)[0], 'zip', BUILD_FOLDER)
    # shutil.rmtree(BUILD_FOLDER)