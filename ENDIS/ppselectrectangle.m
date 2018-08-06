function BW2 = ppselectrectangle(BW,grayscale)
% BW is the mask used to discard cell, Grayscale is the actual image
% displayed.
% will discard cells when the user draw a rectangle
% perrine.paul-gilloteaux@curie.fr

n=4; %connectifity of 4

[r,c]=clickpixelspoints(grayscale);

sizebw=size(grayscale);
maskrect=poly2mask(r,c,sizebw(1),sizebw(2)); % we fill the manually define rectangle)

seed_indices = find(maskrect); % the source for removing the point is all the rectangle drawn.
BW2 = imfill(~BW, seed_indices, n); 

% all cells deleted ans bakground in white, kept cells in black.

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

rect = getrect;

xi(1)=rect(1);yi(1)=rect(2);
xi(2)=rect(1)+rect(3);yi(2)=rect(2);
xi(4)=rect(1);yi(4)=rect(2)+rect(4);
xi(3)=rect(1)+rect(3);yi(3)=rect(2)+rect(4);

c = round(axes2pix(size(image1,1), ydata, yi));
r = round(axes2pix(size(image1,2), xdata, xi));
    
end


