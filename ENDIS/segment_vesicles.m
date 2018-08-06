function Vesiclesmasque=segment_vesicles(image_input,masquecell, hlog)
%% segement_vesicles segment_vesicles segment the vesicles from an image image_input
% in 2D only in the mask given in maskcell.
% Perrine.paul-gilloteaux@curie.fr

%   Laplacian of gaussian,
logimage=imfilter(double(image_input),hlog)*-1;
% seeds for markercontrolled watershed.
%then regional max,
test=imhmax(logimage,0.4);
BWmax = imregionalmax(double(test));
BWmax(masquecell==0)=0; % remove false maxima on border


se = strel('disk', 1);
Ie = imerode(image_input, se);
Iobr = imreconstruct(Ie, image_input);
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

bw = im2bw(Iobrcbr,graythresh(Iobrcbr));

D = ~bw;
BWmax(bw==0)=0;
forwatershed=imimposemin(uint8(D),BWmax);
L=watershed(forwatershed);

bw(L==0)=0;

Vesiclesmasque=bw;
Vesiclesmasque(masquecell==0)=0;

end

