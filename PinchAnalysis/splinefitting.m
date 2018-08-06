countprofile=21;
x=-1.5:0.01:1.5;
green=zeros(length(x),countprofile);
red=zeros(length(x),countprofile);
blue=zeros(length(x),countprofile);
for i=1:countprofile
    num=xlsread('results_merged NEW MOCK.xls',i);
   % figure(1)
    %plot(num(:,1),num(:,2),'r-');
    %figure(2)
    %plot(num(:,1),num(:,3),'b-');
    %figure(3)
    %plot(num(:,1),num(:,4),'go');hold on,
    green(:,i)=interp1(num(:,1),num(:,4),x);
     %plot(x,green(:,i),'g-');hold off
    red(:,i)=interp1(num(:,1),num(:,2),x);
    blue(:,i)=interp1(num(:,1),num(:,3),x);
end

 bootfun= @(myx) mean(myx,1);
y=reshape(green,size(green,1)*size(green,2),1);
xnew=repmat(x,1,size(green,2));
 [curveg, goodness, output] = fit(xnew',y,'smoothingspline');
 figure, plot(curveg,'g'); hold on;
 
   cig = bootci(2000, bootfun,green');
   
   plot(x,cig,'g--');hold on;
   
 y=reshape(red,size(red,1)*size(red,2),1);
xnew=repmat(x,1,size(red,2));
 [curver, goodness, output] = fit(xnew',y,'smoothingspline');
  plot(curver,'r'); hold on;
   cir = bootci(2000, bootfun,red');
   
   plot(x,cir,'r--');hold on;
   y=reshape(blue,size(blue,1)*size(blue,2),1);
xnew=repmat(x,1,size(blue,2));
 [curveb, goodness, output] = fit(xnew',y,'smoothingspline');
  plot(curveb,'b'); hold on;
 
   cib = bootci(2000, bootfun,blue');
   
   plot(x,cib,'b--');hold on;
  
   
   figure
  
  color=[0.8 0.8 0.8];
   plot(x,green','color',color); hold on,
   plot(curveg,'g'); hold on;
    plot(x,cig,'g--');
    
    
     figure
  
  color=[0.8 0.8 0.8];
   plot(x,red','color',color); hold on,
   plot(curver,'r'); hold on;
    plot(x,cir,'r--');
    figure
  color=[0.8 0.8 0.8];
   plot(x,blue','color',color); hold on,
   plot(curveb,'b'); hold on;
    plot(x,cib,'b--');  
   
%   
%    plot([0 0],[-1 1],'k-','LineWidth',1); hold on;
%    subt=(-lagmax:0.001:lagmax);
%    [mymax,id]=max(feval(curve,-lagmax:0.001:lagmax)); %already in seconds
%    bootfun= @(x) mean(x,1);
%    ci = bootci(2000, bootfun,AutoCor);
