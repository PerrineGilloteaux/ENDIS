function [  majoraxe, minoraxe, orientation, centroid_x,centroid_y,speed,vectorspeed,index] = DrawandSaveMaskandaxesSpeedSCI( correctedmask,imagetest,PathName,FileName,formerposition_x,formerposition_y,dmax,speedmaxtobeconsidered, oldorientation)
%DrawandSaveMaskandaxesSpeedSCI Perform the association between nuclei
%based on nearest neighbors (tracking), deal with disappearance of a
%nuclei, and compute the displacement of the center of gravity of all
%tracked nuclei, as well as the vector of displacement, and orientation and
%axes from which the crop image will be rotated to normalize the endosome
%positioning.
% N.B : the method can also be used without tracking to define a coordinate
% system according to the nuclei or cell elongation through ellipse
% fitting, that is why we kept the naming minor/major axes but they are not
% used in ENDIS.
% Perrine.paul-Gilloteaux@curie.fr


correctedmask=logical(correctedmask);
%     Lrgb = label2rgb(correctedmask, 'jet', 'w', 'shuffle');
%     h=figure;
%     imshow(imagetest,[]), hold on
%     himage = imshow(Lrgb);
%     set(himage, 'AlphaData', 0.2);
%     title('Lrgb superimposed transparently on original image')
%
% We compute again the satistics of the mask
stats=regionprops(correctedmask,'Centroid');
centroids = cat(1, stats.Centroid);

majoraxe=[];
centroid_x=centroids(:,1);
centroid_y=centroids(:,2);
if length(formerposition_x)>length(centroid_x)
    % disappearance
    % We keep it same position, no speed
    ncentroid_x=[centroid_x;formerposition_x+sqrt(dmax)-1]; % duplicate but should be ok?
    ncentroid_y=[centroid_y;formerposition_y+sqrt(dmax)-1];
    [IDX,D] = knnsearch([ ncentroid_x,ncentroid_y] ,[formerposition_x,formerposition_y]);
    
else
    if ~isempty(formerposition_x)
        [IDX,D] = knnsearch([ centroid_x,centroid_y] ,[formerposition_x,formerposition_y]);
        
    end
end
% we display a few information on the image before saving it.
newcentroid_x=[];
newcentroid_y=[];
neworientation=[];
newspeed=[];
index=[];
newvectorspeed=[];
for i=1:length(formerposition_x)
    if D(i)<dmax
        text(centroid_x(IDX(i)),centroid_y(IDX(i)),num2str(i));hold on;
        % we display the major and minor axis (cosd=cosinus in degree)
        index=[index;i];
        coteadjacent=(centroid_x(IDX(i))-formerposition_x(i));
        coteopose=(centroid_y(IDX(i))-formerposition_y(i));
        speed=sqrt( coteadjacent^2+coteopose^2);
        vectorspeed=[coteadjacent, coteopose];
        if speed>speedmaxtobeconsidered
            majoraxex1=formerposition_x(i);
            majoraxey1=formerposition_y(i);
            majoraxex2=centroid_x(IDX(i))+coteadjacent*10;
            majoraxey2=centroid_y(IDX(i))+coteopose*10;
            
            orientation=atan2d(coteopose,coteadjacent);
            
            majoraxe=[majoraxe;majoraxex2, majoraxey2];
            
            
        else
            orientation=oldorientation(i); % we do not change it to avoid jump in orientation due to small movement, but we keep speed for indication
            majoraxex1=formerposition_x(i);
            majoraxey1=formerposition_y(i);
            coteadjacent=cos(orientation)*speed;
            coteopose=sin(orientation)*speed;
            majoraxex2=centroid_x(IDX(i))+coteadjacent*10;
            majoraxey2=centroid_y(IDX(i))+coteopose*10;
        end
        hold on;plot([majoraxex1  majoraxex2],[majoraxey1  majoraxey2],'r','LineWidth',1);
        plot(majoraxex2, majoraxey2,'rv'); hold on;
        plot(centroid_x(IDX(i)), centroid_y(IDX(i)),'g*'); hold on;
        newcentroid_x=[newcentroid_x;centroid_x(IDX(i))];
        newcentroid_y=[newcentroid_y;centroid_y(IDX(i))];
        newspeed=[newspeed;speed];
        neworientation=[neworientation;orientation];
        newvectorspeed=[newvectorspeed;vectorspeed];
    end
end
minoraxe=majoraxe;
% saveas(h, [PathName,FileName,'_mask.tif']);
centroid_x=newcentroid_x;
centroid_y=newcentroid_y;
speed=newspeed;
orientation=neworientation;
vectorspeed=newvectorspeed;
end

