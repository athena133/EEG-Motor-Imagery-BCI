# Review notes

These findings come from static inspection, not execution in MATLAB.

## Exercise 1
- `D` is used without being loaded and `apply_bandpass_filter.m` is absent.
- Several FFT plots use mismatched full-spectrum and half-length frequency vectors.
- The resampling ratio is inverted; processing dimensions and use of the filtered input also require correction.
- The 50 Hz notch design uses `fs/2 + 1` as its normalization denominator at a 100 Hz sampling rate; the design must be reconsidered.
- Laplacian weights do not consistently match the number of neighbors. The three-neighbor call supplies four rows to a five-element weight vector; four neighbors require -1/4 weights for a simple neighbor-average subtraction.

## Exercise 2
- `loc.m` uses undefined `num_channels` and `nfo` variables despite defining local coordinate arrays, assigns all labels to each channel, and assumes planar Z coordinates.
- T7/T8 referencing must not be described as mastoid referencing.
- Saved histories provide evidence of CAR, filtering, channel rejection, SOBI and JADE processing, but signal data were missing. The PDF also describes Infomax.
- Some saved datasets change the sampling-rate metadata without demonstrating actual resampling. The history with `pop_resample(EEG,60)` is distinct from importing unchanged samples at 60 Hz.
- Artifact removal decisions require physiological justification, rather than assuming all large components are artifacts.

## Exercise 3
- `D` is undefined and `apply_CSP.m` is missing.
- The trial window extends from each marker to the next rather than explicitly selecting the intended motor-imagery interval.
- Six channels are selected although some comments say seven.
- FBCSP filtering defaults to the channel dimension for channel-by-time matrices; filtering must run along time.
- CSP/FBCSP is computed before validation splitting. Fit spatial filters on training trials only and apply fixed filters to held-out trials.
- Standardization currently uses the complete feature matrix. Fit normalization on training data within each fold.
- PLV phase indexing confuses time and channel dimensions after transposition.
- FastICA QR output dimensions are inconsistent with the subsequent matrix products; rank handling after CAR also needs attention.
- The subsequent normalization uses `eeg_filter`, not the reconstructed `EEG_clean`.
- Theta summary plots accidentally use beta features.
- Feature dimensions and label-column indices are hard-coded; the KNN display prints the SVM accuracy variable.
- Reproducible evaluation needs fixed random seeds and an appropriate split strategy. Comparing many feature combinations on the same validation set also requires independent evaluation of the selected configuration.
