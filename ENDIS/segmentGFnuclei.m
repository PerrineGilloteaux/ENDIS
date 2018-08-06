function  mask=segmentGFnuclei(imagetest)
% segmentGFnuclei.m: Segment nuclei on GFP images for Endosomes relative
% positioning
%   After a Gaussian filtering for smoothing, the image is simply
%   thresholded using half of the automatic threshold find by Otsu Method.
% Then all connected areas containing less than 100 pixels are removed.

% Perrine.paul-gilloteaux@curie.fr
h=fspecial('gaussian');
imagetest=mat2gray(imfilter(imagetest,h));
BWfinal=im2bw(imagetest,graythresh(imagetest)*0.5);

minArea=100;
CC = bwconncomp(BWfinal,4);
numPixels = cellfun(@numel,CC.PixelIdxList);
idx= find(numPixels<minArea);
for i=1:length(idx)
    BWfinal(CC.PixelIdxList{idx(i)}) = 0;
end
mask=BWfinal;

end

