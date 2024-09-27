'''organise.py
Module to organise the required files of the course 
"Functional Brain Imaging Experimental Design and Analysis"
'''
import os
import tkinter as tk
from pathlib import Path
from tkinter import filedialog

def get_download_dirs():
    '''Asks the user the directories where the data was downloaded from the SFTP'''
    print('Hi!')
    print()
    print('Please, hit "enter" to select the directory where the')
    print('data DOWNLOADED from the SFTP (Filezilla) is stored.')
    print('i.e., fMRI_Training')
    print()
    input('Hit "enter" to continue')

    download_dir = filedialog.askdirectory(title="Where is the downloaded data?")
    print(f"Selected directory: {download_dir}")

    beh_dir = Path(download_dir) / "beh"
    ima_dir = Path(download_dir) / "ima"

    if os.path.exists(beh_dir):
        print("The directory 'beh' exists")
    else:
        raise FileNotFoundError(f"The directory 'beh' does not exist at: {beh_dir}")
    
    if os.path.exists(ima_dir):
        print("The directory 'ima' exists")
    else:
        raise FileNotFoundError(f"The directory 'beh' does not exist at: {beh_dir}")
    
    return beh_dir, ima_dir

def get_target_dirs():
    '''Asks the user the directory where the data will be stored'''
    print()
    print('cool. Now, please provide the TARGET dir (where you want to store the data)')
    print('That would be the "data" dir in your file structure for the course')
    print()
    input('Hit "enter" to continue')
    target_dir = filedialog.askdirectory(title="Where do you wanna store the data?")
    print(f"Selected directory: {target_dir}")

    return target_dir

def build_file_structure(target_path):
    '''Creates the file structure for the course'''
    print('Creating file structure...')

    try:
        raw_dir = Path(target_path) / "rawdata"
        raw_dir.mkdir(parents=True, exist_ok=False)
        print(f"Created directory: {raw_dir}")
    except FileExistsError:
        print(f"WARNING: Directory {raw_dir} already exists.")    

    source_dir = Path(target_path) / "sourcedata"
    try:
        source_dir.mkdir(parents=True, exist_ok=False)
    except FileExistsError:
        print(f"WARNING: Directory {source_dir} already exists.")

    return source_dir

def copy_all(source_dir, target_dir):
    '''Copies all files from the source directory to the target directory'''
    for item in source_dir.iterdir():
        destination = target_dir / item.name
        if item.is_dir():
            destination.mkdir(exist_ok=True)
            copy_all(item, destination)  # Recursively copy subdirectories
        else:
            destination.write_bytes(item.read_bytes())

def copy_beh_ima_files(beh_path, ima_path, source_path):
    '''Copies the beh and ima files to the source directory'''
    print('Initiating copy-paste process. This might take a while...')
    for inn_dir in beh_path.iterdir():
        if inn_dir.is_dir():
            new_beh_dir = source_path / inn_dir.name / 'beh'
            new_ima_dir = source_path / inn_dir.name / 'ima'
            print(f'Copying {(inn_dir.name)} files...')
            new_beh_dir.mkdir(parents=True, exist_ok=True)
            new_ima_dir.mkdir(exist_ok=True)
            copy_all(beh_path / inn_dir.name, new_beh_dir)
            copy_all(ima_path / inn_dir.name, new_ima_dir)

    print('Done!')

if __name__ == '__main__':
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    beh_path, ima_path = get_download_dirs()
    target_path = get_target_dirs()
    source_path = build_file_structure(target_path)
    copy_beh_ima_files(beh_path, ima_path, source_path)
