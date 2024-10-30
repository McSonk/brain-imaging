from pathlib import Path

import nibabel as nib

POPULATION = 'young'
SUBJECT = 'y03'
FILE_NAME = 'ima_T1_MPRAGE_sag_1.25_hippo_20080312142213_13.nii'

def extract_data(file_name):
    img = nib.load(file_name)
    voxel_dims = img.header.get_zooms()
    data = img.get_fdata()
    matrix_size = data.shape[:2]
    slice_thickness = voxel_dims[2]
    tr = img.header['pixdim'][4]
    print("Voxel dimensions:", voxel_dims)
    print("Matrix size:", matrix_size)
    print("Slice thickness:", slice_thickness)
    print("Repetition Time (TR):", tr)

if __name__ == '__main__':
    print('Data for subject', SUBJECT, 'in population', POPULATION)
    extract_data(Path('../data/rawdata') / POPULATION / SUBJECT /  FILE_NAME)
