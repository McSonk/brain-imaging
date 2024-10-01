
import os
import tkinter as tk
from pathlib import Path
from tkinter import filedialog


if __name__ == '__main__':
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    print('Hi!')
    print()
    print('Please, hit "enter" to select the sourcedata directory')
    input()

    download_dir = filedialog.askdirectory(title="Where is the downloaded data?")
    raw_dir = Path(download_dir).parent / 'rawdata'
    print(f"Selected directory: {download_dir}")
    print(f'rawdata location: {raw_dir}')

    print('Thank you! Now, please tell me the MRIcroGL directory')
    input('(Hit "enter" to continue)')
    mricrogl_dir = filedialog.askdirectory(title="Where is the MRIcroGL directory?")
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
