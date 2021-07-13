# 3dCellShape
3dCellShape implements measurement and analysis of geometric features on extracted 3D volumes of single cells from fluorescent imaging data.

![Alt Text](doc/readme_pic.jpg?raw=true)

## Related paper
- This repository is for initial distribution of the 3D shape analysis pipeline associated with the manuscript [**"In vivo profiling of site-specific human cancer cell states in zebrafish"**](https://doi.org/10.1101/2021.06.09.447621), on BioRxiv. 

## Accessing the codes and example output
- The pipeline consists of three Matlab scripts – (1) for post-processing and (2) segmentation of data, adapted from [Driscoll, et al, 2019](https://www.nature.com/articles/s41592-019-0539-z), and (3) for geometric feature extraction and analysis from extracted 3D volumes. 
- Example input data is provided in the folder **exampleCroppedCells**. These are cropped regions of interest from raw data containing a single fluorescently labeled cell. Using cropped regions rather than entire raw data files as input enables a more time-efficient data processing, as the file sizes are significantly smaller. The folder also includes an example “index” file detailing the relevant parameters of the experiment.  For proper segmentation, the fluorescently labeled cell must not be in contact with any other cell or image boundary, in order to properly capture cell boundaries. 
- Corresponding example output files are provided in the folder **exampleOutput**. 
- Workflow:
	- i.	(Part 1) Run image registration and deconvolution of cropped raw data by running **imageProcessing3D.m**
	- ii.	(Part 2) and segmentation of cell volumes by running **runMorphology3D.m**. The subfunctions for this script is under the software folder. 
	- iii.	(Part 3) Run **runGlobalFeatureAnalysis.m** to measure geometric features of cells from 3D segmented data, create an indexed table of geometric features, and create some basic visualizations of data. 
- Pipeline built on MATLAB R2020a version