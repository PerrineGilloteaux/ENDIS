

ENDIS: ENDosomes positioning relatively to nuclei DISplacement vector.
Perrine.Paul-gilloteaux@curie.fr 2013-2015

The software can be run from Matlab, with the Image Processing Toolbox. It has been tested on 2013a to 2014a.
The main matlab file to be launched is PipelileENDIS.m, but depends on all files in this directory.
It takes as input 2D + time tif stack, one for each channel (nuclei and endosomes).
Several nuclei can be studied at the same time.
List of parameters:
FirstFrame(included), LastFrame,
To let the user define a subsequence of the movie showing nuclei 
%(since division or appearance are not handled). Disappearance is well handled.
Cut off speed (min) (pixel per frame)
While a nuclei is not moving, i.e having a displacement vector below the cut off speed defined in this parameter, the endosomes positioning is ignored.
Search Radius
This parameter defines the bandwidth of around the nuclei perimeter in which endosomes are looked for and associated to this nuclei (this is obtained by a dilation of the nuclei with a disk structuring element of radius Search Radius)
Warning: The code as it is requires the naming of the files to be: ‘1 GFP','1 mCherry’
This can be changed 
