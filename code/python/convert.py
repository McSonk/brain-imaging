'''Module to convert ALL DICOM files to NIfTI format using dcm2niix.
It will find all the directories in the sourcedata directory and convert all the
DICOM files in the 'ima' subdirectory to NIfTI format.'''
import os
import tkinter as tk
from pathlib import Path
from tkinter import filedialog
import sys

def get_paths():
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    print('Hi!')
    print()
    print('Please, hit "enter" to select the sourcedata directory')
    input()

    download_dir = filedialog.askdirectory(title="Where is the downloaded data?")
    raw_dir = Path(download_dir).parent / 'rawdata'

    print('Thank you! Now, please tell me the MRIcroGL directory')
    input('(Hit "enter" to continue)')

    return download_dir, raw_dir

def get_microgl_dir():
    print('Please, hit "enter" to select the MRIcroGL directory')
    input()

    return filedialog.askdirectory(title="Where is the MRIcroGL directory?")

if __name__ == '__main__':


    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("Usage: python convert.py [sourcedata_directory] [mricrogl_directory]")
            sys.exit(0)
        download_dir = sys.argv[1]
        raw_dir = Path(download_dir).parent / 'rawdata'
    else:
        download_dir, raw_dir = get_paths()

    print(f"Selected directory: {download_dir}")
    print(f'rawdata location: {raw_dir}')


    if len(sys.argv) > 2:
        mricrogl_dir = sys.argv[2]
    else:
        mricrogl_dir = get_microgl_dir()

    dcm_path = Path(mricrogl_dir) / Path('Resources') / Path('dcm2niix')




    directories = [d for d in Path(download_dir).iterdir() if d.is_dir()]
    print("Directories in the selected directory:")
    for i, directory in enumerate(directories):
        ima_path = Path(download_dir) / Path(directory.name) / Path('ima')
        output_dir = Path(raw_dir) / Path(directory.name)
        dcm_command = f"{dcm_path} -o {output_dir} -p y -f %f_%p_%t_%s -z n {ima_path}"

        output_dir.mkdir(parents=True, exist_ok=True)
        print('*' * 50)
        print(f'{i+1}/{len(directories)}')
        print(f'executing: {dcm_command}')
        print('*' * 50)
        os.system(dcm_command)
    print('All done!')
