%%
% File Name: ppManualModifoncolorImage.m
% Author: Perrine PAUL perrine.paul@gmail.com
% Institution: Hamilton Institute, National University of Ireland Maynooth
% Date: 23/10/2008
% Copyright (C) 2008-2009  Perrine Paul
% 2014: Use for ENDIS: Perrine.paul-gilloteaux@curie.fr
%%




function newLabelledMask = ppManualModifoncolorImage(labelledmask, DIC)
% newLabelledMask = ppManualDiscard(labelledmask)
% INPUT a mask ort labelled mask
%Output: a new mask witout the cells to discard
% A new figure is created and the user select one point with the mouse
% inside the cell(s) that he wants to discard.  To finish selection,
% double-click on the last cell to discard or simply hit return key. 

ScrMargin       = 0.15; % Screen margin for the whole figure
                        % in NORMALIZED units
% in order to transform the labelled image in a binary mask
mask = im2bw(labelledmask,0); 
%% init gui
GP.hmyfig         = figure(...
    'Name','Correct the cells mask',...
    'NumberTitle','off',...
    'Color',[1 1 1],...
    'WindowStyle','modal',...{normal} | 
    'Pointer','crosshair',... fullcrosshair crosshair
    'Resize','on',...{on} | off
    'Toolbar','none',...
    'Menubar','none');
set(GP.hmyfig,...
    'Units','normalized',...
    'Position',[ ScrMargin ScrMargin 1-4*ScrMargin 1-2*ScrMargin ]);
GP.newmask=mask;
maskperim=bwperim(mask,8);
DICmask=zeros(size(DIC,1),size(DIC,2),3);
DICmask(:,:,1)=DIC;
DICmask(:,:,2)=DIC;
DICmask(:,:,3)=DIC;
GP.DIC=DICmask;
guidata(gcf,GP);


DICmask(maskperim==1)=1;






GP.hDoneBtn     = uicontrol( 'Style','pushbutton',  'Parent',gcf, ...
    'FontWeight','bold',                'units','normalized',  ...
    'position',[0.70 0 0.15 0.1], 'string','Done');
GP.hClearBorderBtn     = uicontrol( 'Style','pushbutton',  'Parent',gcf,...
    'FontWeight','bold',                'units','normalized', ...
    'position',[0.36 0 0.15 0.1], 'string','Clear Border Cell');
GP.hPanArea =uicontrol( 'Style','pushbutton',  'Parent',gcf,  ...
    'FontWeight','bold',                'units','normalized',  ...
    'position',[0.19 0 0.15 0.1], 'string','Clear Area');
GP.hPerCellArea =uicontrol( 'Style','pushbutton',  'Parent',gcf, ...
    'FontWeight','bold', 'units','normalized',  ...
    'position',[0.02 0 0.15 0.1], 'string',' Cell by Cell');
GP.hUndo =uicontrol( 'Style','pushbutton',  'Parent',gcf, ...
    'FontWeight','bold', 'units','normalized',  ...
    'position',[0.87 0 0.1 0.1], 'string','Undo');

GP.hAddCell = uicontrol( 'Style','pushbutton',  'Parent',gcf, ...
    'FontWeight','bold', 'units','normalized',  ...
    'position',[0.53 0 0.15 0.1], 'string','Add a new cell'); 


GP.himg=imshow(DICmask,[]);
GP.XLim         = xlim;
GP.YLim         = ylim;
GP.hAxes        = gca;

axes(GP.hAxes);
axis image; axis off;
guidata(gcf,GP);

% attribute callback to buttons
set( GP.hDoneBtn,   'CallBack',             @SelectionDone);

set( GP.hClearBorderBtn,   'CallBack',             @SelectionBorder);


set( GP.hPanArea,   'CallBack',             @SelectionRectangle);

set( GP.hPerCellArea,   'CallBack',             @SelectionCell);

set( GP.hUndo,   'CallBack',             @SelectionUndo);

set( GP.hAddCell,   'CallBack',             @SelectionAddCell);
zoom('on');
%% wait dor done button pressed
uiwait;
if ishandle(GP.hmyfig)
    GP = guidata(gcf);
    delete(gcf);
    newLabelledMask=GP.newLabelledMask ;
end

return;
%% when done
function SelectionDone(src,evt)
GP = guidata(gcf);
GP.newLabelledMask = bwlabel(GP.newmask>0,4);

guidata(gcf,GP);
uiresume;
return;
%% remove cell touchin border
function SelectionBorder(src,evt)
GP = guidata(gcf);
GP.newmask=imclearborder(GP.newmask,4);


maskperim=bwperim(GP.newmask,8);
DICmask=GP.DIC;

DICmask(maskperim==1)=1;

axes(GP.hAxes); 
GP.himg=imshow(DICmask,[]);
guidata(gcf,GP);
zoom('on');
return;


%% remove cell per cell
function SelectionCell(src,evt)
GP = guidata(gcf);
warndlg('Click inside the cells you want to discard. When finished, double click on any cell to discard');
uiwait;
DICmask=GP.DIC;
maskperim=bwperim(GP.newmask,8);

DICmask(maskperim==1)=1;

axes(GP.hAxes); 
cellstodiscard=ppselect(GP.newmask, DICmask);
% The results is the cells which were NOT selected

GP.newmask=and(GP.newmask,~cellstodiscard);



maskperim=bwperim(GP.newmask,8);
DICmask=GP.DIC;

DICmask(maskperim==1)=1;

axes(GP.hAxes); 

GP.himg=imshow(DICmask,[]);

guidata(gcf,GP);
zoom('on');

return;
%% Remove an area in rectangle
function SelectionRectangle(src,evt)
GP = guidata(gcf);
warndlg('Select  a corner of the rectangle area in which you want to discard cells, and maintain the mouse left button down until you have selected the opposite corner. All cells with a part in this area will be deleted');
uiwait;
DICmask=GP.DIC;
maskperim=bwperim(GP.newmask,8);

DICmask(maskperim==1)=1;

axes(GP.hAxes); 

% bg and cell to discard: 1; cell to keep 0;
cellstodiscard=ppselectrectangle(GP.newmask, DICmask);
% The results is the cells which were NOT selected

GP.newmask=and(GP.newmask,~cellstodiscard);


maskperim=bwperim(GP.newmask,8);
DICmask=GP.DIC;

DICmask(maskperim==1)=1;

axes(GP.hAxes); 
 
GP.himg=imshow(DICmask,[]);
guidata(gcf,GP);
zoom('on');
return;

function SelectionAddCell(src,evt)
GP = guidata(gcf);
warndlg('Draw the contour of the cell you want to add to the study. Click on the mouse left button to add a point, and click right to add the last point.');
uiwait;
DICmask=GP.DIC;
maskperim=bwperim(GP.newmask,8);

DICmask(maskperim==1)=1;

axes(GP.hAxes); 
fini = 0;
x=NaN(50,1);
y=NaN(50,1);
index=1;
while fini ~= 3, %(right button of the mouse was clicked)
  [x(index),y(index),fini] = ginput(1);
  hold on,plot(x,y,'ro-');
  index=index+1;
end;
x=[x(not(isnan(x)));x(1)]; % we close the shape by the first point
y=[y(not(isnan(y)));y(1)];
sizebw=size(DICmask);
celltoadd=poly2mask(x,y,sizebw(1),sizebw(2)); % we fill the manually define rectangle)
GP.newmask = or(GP.newmask,celltoadd); % pb: to do; now if the cell are touching 
%each other they could be considered as only one cell in the final labelled mask...
maskperim=bwperim(GP.newmask,8);
DICmask=GP.DIC;

DICmask(maskperim==1)=1;

axes(GP.hAxes); 
 
GP.himg=imshow(DICmask,[]);
guidata(gcf,GP);
zoom('on');
return;

function SelectionUndo(src,evt)
warndlg('Not Implemented Yet');
return;

