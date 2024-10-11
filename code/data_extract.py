import nibabel as nib

FILE_NAME = 'ima_REP1_150BR_32_sl_20080130101823_23.nii'

img = nib.load('../data/rawdata/young/y01/' + FILE_NAME)

voxel_dims = img.header.get_zooms()
print("Voxel dimensions:", voxel_dims)

data = img.get_fdata()
matrix_size = data.shape[:2]  # Taking the first two dimensions
print("Matrix size:", matrix_size)

slice_thickness = voxel_dims[2]
print("Slice thickness:", slice_thickness)

tr = img.header['pixdim'][4]
print("Repetition Time (TR):", tr)

