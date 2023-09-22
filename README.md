# Cell membrane buckling governs early-stage ridge formation in butterfly wing scales: code

 [![DOI](https://zenodo.org/badge/694977597.svg)](https://zenodo.org/badge/latestdoi/694977597)

This repository contains code, analysis, and processed data measurements for:
- JF Totz, AD McDougal, L Wagner, S Kang, PTC So, J Dunkel, BD Wilts, and M Kolle. Cell membrane buckling governs early-stage ridge formation in butterfly wing scales. (Forthcoming).

Additional details may be found in the Materials and Methods, as well as the SI, of the above publication.

The companion repository of raw data may be found on Zenodo: 
JF Totz, AD McDougal, L Wagner, S Kang, PTC So, J Dunkel, BD Wilts, and M Kolle. (Forthcoming). "Cell membrane buckling governs early-stage ridge formation in butterfly wing scales:data" (v1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.8369073

## Processing and analysis of empirical data 
### Requirements
Code was prepared for use in MATLAB R2022b. Various scripts or functions require: image_toolbox, signal_toolbox, and statistics_toolbox.

For 2D unwrapping, Python (prepared with v3.10) and the Python package 'scikit-image' are required.
For the reader's convenience, we share `samplePythonUnwrap.m` to provide installation tips and to demonstrate use in Matlab.

For scripts that require the raw data, the data must be downloaded from the data repository mentioned above and placed in the /RawData/ folder.

### Visualization and analysis of raw phase data
- `analyzePhaseProfile.m` integrates the analysis, visualization, and exploration of phase data. 
- This script was used to produce the measurement files in /Measured/.

### Analysis of specified scaled surfaces
- `Fig1ShowUnwrap.m`, `Fig3Empirical.m`, and `Suppl_protoridgeSegment.m` contain the analysis of processed data from /Measured/. 

### Supporting code
ACKNOWLEDGED: 
We thank the authors for making following code available, which contributed to our visualizations:
- B Bechtold, 2016. Violin Plots for Matlab, Github Project [https://github.com/bastibe/Violinplot-Matlab](https://github.com/bastibe/Violinplot-Matlab), DOI: 10.5281/zenodo.4559847
- B Bechtold, 2015. twilight: A Circular Color Map, Github Project [https://github.com/bastibe/twilight](https://github.com/bastibe/twilight)
- S Cobeldick, 2019. MatPlotLib Perceptually Uniform Colormaps, MATLAB Central File Exchange, https://www.mathworks.com/matlabcentral/fileexchange/62729-matplotlib-perceptually-uniform-colormaps

PREVIOUSLY RELEASED:
- AD McDougal, S Kang, Z Yaqoob, PTC So, and M Kolle, Data and analysis codes for “In vivo visualization of butterfly scale cell morphogenesis in Vanessa cardui.” Zenodo. https://doi.org/10.5281/zenodo.5532941.

OTHER:
Additional functions were developed for the present study.
