function BW2 = ppselect(BW,grayscale)
%% ppselect used to discard cells
% BW is the m,ask used to discar cell, Grayscale is the actual image
% displayed.
%perrine.paul-gilloteaux@curie.fr

n=4; %connectifity of 4

[r,c]=clickpixelspoints(grayscale);

seed_indices = sub2ind(size(BW), r(:), c(:));
BW2 = imfill(~BW, seed_indices, n);


 

end

%%%
%%% Subfunction ParseInputs
%%%
function [r,c] = clickpixelspoints(image1)


xdata = [];
ydata = [];

xi=[];
yi = [];
r = [];
c = [];
    
xdata = [1 size(image1,2)];
ydata = [1 size(image1,1)];

%imshow(image1,'XData',xdata,'YData',ydata,'DisplayRange',[0 255]);

[xi,yi] = getpts;

r = round(axes2pix(size(image1,1), ydata, yi));
c = round(axes2pix(size(image1,2), xdata, xi));

end


