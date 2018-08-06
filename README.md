# ENDIS ENDosomes positioning relatively to nuclei DISplacement vector.
Companion software of "LINC complex-Lis1 interplay controls MT1-MMP matrix digest-on-demand response for confined tumor cell migration."

https://www.nature.com/articles/s41467-018-04865-7 


- analysis of the position of endosomes according to the nucleus displacement (ENDIS) (example Figure 2) 
The software can be run from Matlab, with the Image Processing Toolbox. An .exe version is available on demand (precompiled).

The main matlab file to be launched is PipelileENDIS.m, but depends on all files 

To analyze nuclei speed and corresponding endosomes positioning for each frame, the software starts by segmenting all nuclei. At the first frame only, it let the user select the nuclei to track by removing the other ones. Several nuclei can be followed at the same time. For each pair of frame, perform the nuclei association, dealing with disappearance or loss of the nuclei, and return the associated speed vector to give an orientation to a new system of coordinates. Nuclei are processed only if they are moving, i.e. have a speed superior to min speed parameter. Image is cropped around the center of the nuclei by 2x Search radius pixels for memory purposes. This system of coordinate is oriented such that the center is the center of gravity of the nuclei, and the ordinate axis is parallel to the speed vector of the processed nuclei. For each nuclei, in addition to its speed, an index called SCI gives the changes of orientation. It should be 1 for a perfect line, -1 is the nuclei changed its direction collinearly, and 0 for a 90 degree turn. The endosomes images are smoothed by median filtering, and then transformed in the same coordinate system that nuclei image. The transform is also applied to the nuclei mask. 
This mask is dilated by the search radius and applied to the endosomes movie frame, to segment the endosomes: After applying a Laplacian of Gaussian filter of sigma 0.5 pixels, all regional maxima not touching the border of the mask above a predefined intensity threshold of 40% of the max value of the image are defined as watershed seeds. A marker-control watershed segmentation based on these seeds is then applied, using a structuring element disk of radius 1 . The coordinates of endosomes are then converted to the Cartesian coordinate system as defined by the centroid of the nuclei and its vector of displacement, to polar coordinate system (where 0 degree means in the direction of the nuclei displacement).



- Plus some utilities for profile analysis (example supplementary figure 2e)

It is based on a imageJ macro to indicate 3 points, then normalized the value of intensity according to these position. 
The spline fitting (Matlab) then merges all generated data from this macro.
