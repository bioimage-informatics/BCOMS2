## BCOMS2

### Biologically constrained optimization based cell membrane segmentation

The old version is available from the following link:
https://github.com/bcomsCelegans/BCOMS

The paper is [here](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-017-1717-6).


### Examples
<p>
  <img height="140px" src="/Pictures/6cells.png">
  <img height="140px" src="/Pictures/12cells.png">
  <img height="140px" src="/Pictures/24cells.png">
  <img height="140px" src="/Pictures/44cells.png">
</p>

### Usage
## File structure
The following files are required. The file must be exactly named as follows.
* Membrane_image.tif
* Nucleus_image.tif
* Nucleus_segmentation.tif
* Trained_model.mat

Trained_model is available at "/BCOMS2/Sample".

## GUI
GUI opens by running "/BCOMS2/MATLAB files/BCOMS2.m".

# 1. Read Image
Designate the input folder containing the input files described above.
Fill the image information: image resolutions and numbers of Z and T.
Check the box if you want to collect division timings between nucleus and membrane.
By pushing the "Read Images", reading the files starts.
The images are saved as Mat files at subfolders at ../Output folder.

# 2. Z Range Determination
The Z range is calculated or designated. If you want to determine it automatically, select "Estimate from the membrane image". If you want to manually give the range, select "Designate" and fill like "3-50".
By pushing the "Determine Z Range", Z range calculation or setting starts.
The result is saved at ../Output/ZRange

# 3. Embryonic Region Segmentation
The embryonic region is segmented. The objective function is the consistency with the membrane image. The biological constraints are nuclear enclosure and volume ratio.
The volume ratio is the ratio of the minimum and maximum volumes across the recording. It must be given according to your data.
After the setting, push the "Segment Emb. Reg.". The segmentation starts.
The result is saved at ../Output/Embryonic_region

# 4. Cell Membrane segmentation
The inter-cell membranes are segmented.
By pushing the "Segment membrane", the segmentation starts.
The result is saved at ../Output/Membrane_segmentation
This result is the finale segmentation result.

# 5. Morphological features extraction
The morphological features and cell-cell contact related features are computed.
By pushing the "Morphological features", the extraction starts.
Two excel files are creasted, one is the morphological features, and the other is the cell-cell contact related features.

### Installation on Windows

