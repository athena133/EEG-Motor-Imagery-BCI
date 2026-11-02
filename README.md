# EEG Motor Imagery BCI Coursework

MATLAB and EEGLAB coursework by Athena Sheydaei exploring EEG signal processing, preprocessing, feature extraction, and offline motor-imagery classification.

## Status

This is an educational archive, not a validated, end-to-end runnable benchmark. Original MATLAB analyses are retained, apart from replacing a machine-specific path in `loc.m`. Known missing dependencies and methodological issues are documented in [KNOWN_ISSUES.md](KNOWN_ISSUES.md). MATLAB execution and numerical reproduction have not been performed for this repository preparation. No corrected accuracy is claimed.

## Contents

| Directory | Scope |
| --- | --- |
| `coursework/01_signal_processing` | FIR filtering, FFT inspection, frequency-band decomposition, resampling experiments, and small Laplacian filtering |
| `coursework/02_eeglab_preprocessing` | Electrode-location script; accompanying coursework explored referencing, filtering, channel rejection, and component separation in EEGLAB |
| `coursework/03_motor_imagery_classification` | Statistical and band-power features, correlation and PLV experiments, CSP/FBCSP calls, SVM and 7-neighbor KNN, holdout and 10-fold validation |

## Data and dependencies

The first and third exercises reference `BCICIV_calib_ds1a_100Hz.mat` and `BCICIV_calib_ds1b_100Hz.mat`, respectively, from BCI Competition IV Dataset 1. Obtain the source dataset separately from its official provider and observe its use conditions. Data are not redistributed here.

Dependencies include MATLAB, Signal Processing Toolbox, Statistics and Machine Learning Toolbox, and EEGLAB for the second exercise. Exact compatible versions have not been validated; saved EEGLAB histories referenced version 2024.0.

Before running, restore missing helper functions, resolve the issues listed below, and configure local data paths. These scripts are not currently a one-command pipeline.

## Results and interpretation

The original coursework report described 67.5% SVM accuracy with alpha/theta features. This historical value has not been reproduced and must not be interpreted as an independently validated performance estimate. Preprocessing, feature learning, and normalization need correct train/test separation before new performance claims are made.

## Excluded materials

The original RAR archives and PDFs are not published in this initial selection. PDFs contain a student identifier and methodological descriptions requiring review. Ten EEGLAB `.set` files are also omitted because their referenced `.fdt` signal files were absent. The unused `bandpower.m` helper is omitted because it contains an extra `end` and shadows MATLAB's function name.

## Provenance

Source analyses originated in three BCI course assignments. Repository organization and review notes were prepared with AI assistance. This packaging does not establish independent authorship of every helper or validate their algorithms.
