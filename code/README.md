# Coding part of the project

## Instructions for running the pipeline

### Converting DICOM to NIFTI

Execute `convert.py [sourcedata_directory] [mricrogl_directory]`. It takes around 10 minutes.

### Preprocessing

With matlab execute `motionCorrection y01_individual_prepro_desktop.mat`. It'll do the following:

* Realign
* Slice timing
* Coregister t2 to REP1
* Coregister T2 to t2 (from previous step)
* Segmentation

Then, within SPM, execute the batch `dartel_create_template_desk.mat`. This is a manual step.

Finally, execute `applyTemplate o01_norm_to_mni.mat`. This will create `swa` files