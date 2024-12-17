# Coding part of the project

## Instructions for running the pipeline

### Converting DICOM to NIFTI

Execute `convert.py [sourcedata_directory] [mricrogl_directory]`. It takes around 10 minutes.

### Preprocessing

With matlab execute `motionCorrection ../../data/rawdata ../y01_individual_prepro_desktop.mat`. It'll do the following:

* Realign -- Corrects for head motion by realigning all the images in the time series to a reference image.
* Slice timing -- Corrects for differences in acquisition time between slices.
* Coregister t2 to REP1 -- Aligns the T2-weighted image to the reference image (REP1) from the same subject.
* Coregister T2 to t2 (from previous step)
* Segmentation -- Separates the different tissue types within the MRI images (e.g., gray matter, white matter, cerebrospinal fluid).

#### Dartel template creation

Then, **within SPM**, execute the batch `dartel_create_template_desk.mat`. This is a manual step.

> The DARTEL (Diffeomorphic Anatomical Registration Through Exponentiated Lie Algebra) template is a tool used in neuroimaging for more accurate inter-subject registration of brain images. As a result, this will create Template_1.nii, Template_2.nii, ..., Template_6.nii files

#### Normalise to MNI Space

Finally, execute `applyTemplate ../../data/rawdata ../o01_norm_to_mni.mat`. This will create `swa` files

> Normalization to MNI space is a crucial step in MRI preprocessing that ensures that brain images from different subjects are aligned to a common template. MNI refers to the Montreal Neurological Institute, which provides a standardized brain template widely used in neuroimaging.

## 1st level analysis

The fMRI model specification function in SPM is used to define the experimental design and specify the statistical model for analysing functional MRI (fMRI) data

This step is crucial for setting up the General Linear Model (GLM) that will be used to estimate the effects of different experimental conditions or regressors on the fMRI data

### Model Specification

First, be sure the behavioural files are correctly organised. For that, execute
`python organise_beh.py ../../data/sourcedata ../../data/rawdata/`

Then, execute the following function: 
`first_lvl_spec('/home/sonk/Devel/master/brain-imaging/data/rawdata', '/home/sonk/Devel/master/brain-imaging/code/first_level_specification.mat')`

This code will execute SPM for all subjects. SPM will:

1. Design matrix definition -- Specify the conditions or events (e.g., different
tasks or stimuli) that will be included in the model. Also define the function
(HRF) and time parameters (TR, etc)
2. Prepare data -- Load the preprocessed fMRI data, ensuring it has undergone
necessary steps like realignment, slice-timing correction, and normalization
3. Specify model -- Construct a design matrix that includes columns for each
condition or regressor, convolved with the basis functions to model the expected BOLD response.


### Model Estimation

*Purpose*:

>  Estimate the parameters of the model, specifically the beta weights that
represent the relationship between the experimental conditions and the fMRI signal.
This step involves fitting the model to the data using techniques like General
Linear Modeling (GLM). The result is a set of beta weights for each condition,
which indicate how strongly each condition is represented in the fMRI data

Run `first_lvl_estim('/home/sonk/Devel/master/brain-imaging/data/rawdata', '/home/sonk/Devel/master/brain-imaging/code/first_level_model_estimation.mat')`

### Model contrast

*Purpose*:

>  Test specific hypotheses by comparing different conditions or groups within
the data. This involves creating contrasts, which are linear combinations of the
beta weights, to test for differences between conditions

Execute
`first_lvl_contrast('/home/sonk/Devel/master/brain-imaging/data/rawdata', '/home/sonk/Devel/master/brain-imaging/code/first_level_contrast.mat')`

## Second level analysis

 The second-level analysis in fMRI using SPM involves group-level analyses.
 This helps to generalize findings across subjects, rather than just within an
 individual subject.

 ### Model Specification

Involves defining the statistical model that will be used to analyze group-level
effects. This step is crucial as it sets the framework for how the data from
individual subjects will be combined and tested.

1. Define the design matrix
2. Specify the hypothesis
3. Model structure

This is a manual step. Execute `second_level_spec.mat`

### Model estimation

Estimate the group-level effects by combining data from multiple subjects.
This involves creating a statistical model that represents the group. The inputs
to this model are typically the contrast images (e.g., t-maps or beta maps) from
the first-level analysis of each subject. The estimation step calculates the
average effect and variance across subjects, taking into account the
between-subject variability.

This is a manual step. Execute `second_level_estimate.mat`

## Region of interest

For this point onwards the options are in the **Results** button inside SPM
