%% pipelineENDIS
% Workflow:
% 1)segmentation of the nuclei
% 2)if not happy, segment yourself and discard nuclei you do not want to
% follow
% 3) grow the nuclei mask to define a search area for endosomes
% 4)automatic segmentation vesicles from mcherry (only on the mask of nuclei)
% 5)autmatic change of the coordinate system according according to the center of the nuclei(star on the
% cell mask)and the speed vector 
% main axe (the 2)and center of gravity

% Do it for one image:
% 31/03/2014: added nuclei position and speed in a separate excel file,
% save in a another directory.
% Perrine.Paul-Gilloteaux@curie.fr

clear all, close all;
%% get files names of the two stacks 
% (2D + time tif stack, one for each channel and read info from files
[FileName,PathName,FilterIndex] = uigetfile('*GFP*.tif');

imageGFP=[PathName,FileName];
folder_name = uigetdir(PathName,'Where to save Results for Endosomes');
folder_namenuclei = uigetdir(PathName,'Where to save Results for Nuclei');
imageEndosomes= regexprep(imageGFP,'1 GFP','1 mCherry');




info=imfinfo(imageGFP);
info2=imfinfo(imageEndosomes);

nbframes=length(info);


%% Let the user select a subsequence of the movie showing a nuclei 
%(since division or appearance are not handled)
% Search 
prompt = {'FirstFrame(included):','LastFrame:','Cut off speed (min) (pixel per frame)','Search Radius'};
dlg_title = 'Input';
num_lines = 1;
def = {'1',num2str(nbframes),'1','60'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

init=str2double( answer{1});
nbframes=str2double( answer{2});
minspeed=str2double( answer{3});
searchradius=str2double( answer{4});

%% initialisation
hlog = fspecial('log', 9,0.5); % createfilter for segmenting vesigles only once;


AllThetaVesicles=[];
AllRhoVesicles=[];

FrameNumber=[];
CellNumber=[];
SpeedNuclei=[];
NucleiCentroidX=[];
NucleiCentroidY=[];
NucleiSpeed=[];
NucleiTag=[];
NucleiFrame=[];
NucleiSCI=[];
vectorspeed=[];
sci=[];
%% Analyse one nuclei and corresponding endosomes positioning
% for each frame, start by segmenting all nudlei. At the first frame only,
% let the user select the nuclei to track by removing the other ones.
% Several nuclei can be followed at the same time.
% For each pair of frame, perform the nuclei association, dealing with
% disappearance or loss of the nuclei, and return the associated speed
% vector to give an orientation to a new system of coordinates. Nuclei are aprocessed only if they are moving, i.e. have a speed superior to minspeed parameter.
% Image is cropped around the center of the nuclei by 2x Searach radius for memory
% purposes.
% This system of coordiante is oriented such that the center is the center of gravity of the nuclei, 
% and the ordinate axis is parallel to the speed vector of the processed nuclei. 
% For ecah nuclei, in addition to its speed, an index called SCI gives the
% changes of orientation. It should be 1 for a perfect line, -1 is the
% nuceli changed its direction colinearly, and 0 for a 90 ndegree turn.
% The endosomes images are smoothed by median filetering, and then
% trafnsormed in the same coordiante system that nuclei images. 
% The transform is also applied to the nuclei mask. 
% This mask is dilated by the search radius and applied to theEndosomes are then segmented:
% after applying a laplacian of gaussian filter of sigma 0.5 pixels, all
% regional maxima not touching the border of the mask above a predifined intensity 
% threshold of 40% of the max value of % the image are defined as watershed seeds.
% A marker-control watershed segmentation based on these seeds is
% applied, using a struscturing element disk of radius 1 .
%The coordinates of endosomes are then converted to the cartesian coordinate system 
%as defined by the cenroid of the nuclei and its vector of displacement, to
%polar coordiante (where 0 degrees means in the direction of the nuclei
%displacement.
% Some movie are generated for check, with the outlines of the nuclei and
% the speed vector x30. 
for i=init:nbframes
    
    currentframe=imread(imageGFP,'Info',info,'index',i);
    mask=segmentGFnuclei(currentframe);
    DIC=mat2gray(currentframe);
    maskperim=bwperim(mask,8);
    image_input=mat2gray(imread(imageEndosomes,'Info',info2,'index',i));
    DICmask=zeros(size(DIC,1),size(DIC,2),3);
    DICmask(:,:,1)=DIC;
    DICmask(:,:,2)=image_input;
    DICmask(:,:,3)=DIC;
    
    
    
    DICmask(maskperim==1)=1;
    imshow(DICmask);
  
    
    if i==init
        
        h=msgbox(['Select the nuclei to track by removing cells ( ', num2str(max(max(bwlabel(mask)))),' cells found) or drawing new ones, when finished press done. Undo is not implemented.'],'Manual Correction','help');
        uiwait(h);
        mask = ppManualModifoncolorImage(mask, mat2gray(currentframe));
        stats=regionprops(mask,'Centroid');
        centroids = cat(1, stats.Centroid);
        centroid_x=centroids(:,1);
        centroid_y=centroids(:,2);
        orientation=zeros(length(centroid_x),1);
        sci=nan(length(centroid_x),1);
    end
    %% display it with axes and save it
    if i>=init+1
        PathName2='';
        FileName2='';
        if ~isempty(centroid_x) % to deal with disapeariance
            bucentroid_x=centroid_x;
            bucentroid_y=centroid_y;
        else
            centroid_x=bucentroid_x;
            centroid_y=bucentroid_y;
        end
        vectorspeedold=vectorspeed;
        [  majoraxe, minoraxe, orientation, centroid_x,centroid_y,speed,vectorspeed,index]=DrawandSaveMaskandaxesSpeedSCI( mask,currentframe,PathName2,FileName2,centroid_x,centroid_y,30,minspeed,orientation);
        for n=1:size(vectorspeedold,1)
            sci(n)=dot(vectorspeed(n,:),vectorspeedold(n,:))/(norm(vectorspeed(n,:))*norm(vectorspeedold(n,:)));
        end
        
        %% same thing with the vesicles:
        % open the mCherry image
        
        title(['Frame ',num2str(i)]);
        
        saveas(gcf,[folder_name,'/axes_',num2str(i),'.jpg']);
        
        for j=1:length(centroid_x)
            cell=j;
            if (speed(cell)>minspeed)
                image_input_med=imcrop(image_input,[centroid_x(cell)-searchradius centroid_y(cell)-searchradius searchradius*2 searchradius*2]);
                mask_crop=imcrop(mask,[centroid_x(cell)-searchradius centroid_y(cell)-searchradius searchradius*2 searchradius*2]);
                % create the mask just for this cell
                image_input_med=medfilt2( image_input_med);
                
                %% Creation of the new coordinates system first rotation, then translation and xcel output file
                if orientation(cell)<0
                    orientation(cell)=180+(180+orientation(cell)); 
                    % because in matlab angle can be expressed as negative: meaning they will go once in one way, another another way.
                end
                
                rotation=createMatrixRotation(270-orientation(cell));
                
                T = affine2d(rotation);
                %
                image_input_c=imwarp(image_input_med,T);
                clear image_input_med;
                
                SE= strel('disk', searchradius, 0);
                L = bwlabel(mask_crop, 4);
                indexNuclei=L(round(size(mask_crop,1)/2),round(size(mask_crop,2)/2));
                mask_crop=(L==indexNuclei);
                correctedmask_c=imwarp(imdilate( mask_crop,SE),T);
                masknuclei=imwarp(mask_crop,T);
                Vesiclesmasque=segment_vesicles(mat2gray(image_input_c),correctedmask_c, hlog);
                statsv=regionprops(Vesiclesmasque,'Centroid');
                rgb=zeros(size(masknuclei,1),size(masknuclei,2),3);
                rgb(:,:,2)=image_input_c;
                rgb(:,:,1)=Vesiclesmasque;
                rgb(:,:,3)= correctedmask_c;
                figure,
                imshow(rgb,[]);
                centroidsv = cat(1, statsv.Centroid);
                [theta,rho] = cart2pol(centroidsv(:,2)-size(masknuclei,2)/2,centroidsv(:,1)-size(masknuclei,1)/2);
                
                B = bwboundaries(masknuclei);
                B=B{:};
                [thetan,rhon]=cart2pol(B(:,1)-size(masknuclei,1)/2,B(:,2)-size(masknuclei,2)/2);
                figure
                polar(theta-pi/2,rho,'*r');hold on;
                polar(pi/2,speed(cell),'vk');hold on;
                % -pi/2 in order to get the endosomes in the direction of
                % displacement on the top of the polar plot (by default in
                % Matlab it would be to the right)
                polar(thetan-pi/2,rhon);hold off;
                saveas(gcf,[folder_name,'/thetaplot_nuclei',num2str(cell),'_frame',num2str(i),'.jpg']);
               
                AllThetaVesicles=[ AllThetaVesicles;theta-pi/2];
                AllRhoVesicles=[ AllRhoVesicles;rho];
                ActualFrameNumber=repmat(i,1,length(theta));
                ActualCellNumber=repmat(cell,1,length(theta));
                ActualSpeedNuclei=repmat(speed(cell),1,length(theta));
                NucleiCentroidX=[NucleiCentroidX;centroid_x(cell)];
                NucleiCentroidY=[NucleiCentroidY; centroid_y(cell)];
                NucleiSpeed=[NucleiSpeed;speed(cell)];
                NucleiFrame=[NucleiFrame;i];
                NucleiTag=[NucleiTag;cell];
                NucleiSCI=[NucleiSCI;sci];
                
                FrameNumber=[FrameNumber,ActualFrameNumber];
                CellNumber=[CellNumber,ActualCellNumber];
                % we apply the threshold on the cell mask afterwards, in order not to
                SpeedNuclei=[SpeedNuclei,ActualSpeedNuclei];
                
            end
            close all;
        end
    end
end

%% display and save results:
% For all endosomes: their 
rose( AllThetaVesicles);
FrameNumber=FrameNumber';
CellNumber =CellNumber';
SpeedNuclei= SpeedNuclei';
DS=dataset( FrameNumber,CellNumber,AllThetaVesicles,AllRhoVesicles,SpeedNuclei );
excelname= regexprep(FileName,'.tif',['init_',num2str(init),'end_',num2str(nbframes),'ms_',num2str(minspeed),'rs_',num2str(searchradius),'.xls']);
export(DS,'XLSfile',[folder_name,'\',excelname]) ;
DSnuclei=dataset(NucleiTag,NucleiFrame,NucleiCentroidX, NucleiCentroidY, NucleiSpeed , NucleiSCI );
excelname= regexprep(FileName,'.tif',['init_',num2str(init),'end_',num2str(nbframes),'ms_',num2str(minspeed),'rs_',num2str(searchradius),'Nuclei.xls']);
export(DSnuclei,'XLSfile',[folder_namenuclei,'\',excelname]) ;
%ROSE HOSTOGRAME AT THE END