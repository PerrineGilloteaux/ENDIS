//segment endosomes and keep th emask
//for each nuclei (= while user is asking)
//Track manually the pinch
// Create distance map
// Create an area of xx pixels around the pinch and get ROI of endosomes in this ROI
// for each time points
// write for each time points the distance to the pinch
requires("1.48h"); // for setbatchmode
setBatchMode(true);
run("Set Measurements...", "area centroid center redirect=None decimal=4");
run("Options...", "iterations=1 count=1 black edm=Overwrite"); 
run("Input/Output...", "jpeg=75 gif=-1 file=.txt use copy_column");
run("Close All");
run("Clear Results");
//open both GFP and mCherry stacks and merge colors

///////////////////////////////////// dialog for parameters

Dialog.create("File Naming");
Dialog.addString("mCherry specific naming used", "mCherry") ;
Dialog.addString("GFP specific naming used", "GFP") ;
Dialog.addNumber("Radius around pinch",60);
Dialog.addNumber("Threshold for wand tool to get nuclei",50);
Dialog.addNumber("Starting Slice (1 is first)",1);
Dialog.show();
mcherry=Dialog.getString();
gfp=Dialog.getString();

Radius=Dialog.getNumber();
thNuclei=Dialog.getNumber();
startingslice=Dialog.getNumber();
nuclei=0;
//////////////////////////////////////////////////
path=getDirectory("Please chose the directory to process. Cancel to stop.");
while(lengthOf(path)!=0){
	fileslist=getFileList(path);
	nbfiles=fileslist.length;
	for(i=0;i<nbfiles;i++){
		if((indexOf(fileslist[i],mcherry)>0)){
			filenamecherry=fileslist[i];
			filenamegfp=replace(fileslist[i],mcherry,gfp);
			
	
open(path+filenamecherry);
IDmCherry=getImageID();
run("8-bit");
titlecherry=getTitle();
open(path+filenamegfp);
IDGFP=getImageID();
titleGFP=getTitle();
run("8-bit");
run("Merge Channels...", "c1=["+titlecherry+"] c2=["+titleGFP+"] keep");
composite=getImageID();

selectImage(IDmCherry);
setAutoThreshold("Triangle dark stack");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Triangle background=Dark calculate black");
IDmask=getImageID();
selectImage(composite);
setBatchMode("show");
getCursorLoc(x, y, z, flags);
count=1;
setSlice(count+startingslice-1);
PinchX=newArray(nSlices);
PinchY=newArray(nSlices);
EndosomesX=newArray(nSlices);
EndosomesY=newArray(nSlices);
NucleusX=newArray(nSlices);
NucleusY=newArray(nSlices);
setTool("rectangle");
while (flags!=4){
	getCursorLoc(x, y, z, flags);
	if (flags==16){
		print(x,y,z,flags);
		
		wait(200);//time for user to click
		//makePoint(x, y);
		
		PinchX[count-1]=x;
		PinchY[count-1]=y;
		count++;
		setSlice(count+startingslice-1);
	}
		
}
count=count-1;
IJ.log("I understood track was finished. Processing now...");
/**
list="";
for (p=1;p<count-1;p++){
	list=list+PinchX[p]+","+PinchY[p]+",";
	//print(list);
}
**/	
//list=list+PinchX[p]+","+PinchY[p];
//command="makeLine("+list+")";
//doCommand(command);
getDimensions(width, height, channels, slices, frames);


for (p=1;p<=count;p++){
	
	newImage("pinch", "8-bit black", width, height, 1);
	IDpinchimage=getImageID();
	setPixel(PinchX[p-1],PinchY[p-1],255);
	/*run("Duplicate...", "title=pinch-1");
	run("Invert");
	run("Distance Map");
	selectImage(IDpinchimage);*/
	
	makeOval(PinchX[p]-Radius, PinchY[p]-Radius,Radius*2, Radius*2);

	selectImage(IDmask);

	
	setSlice(p+startingslice-1);
	
	run("Restore Selection");
	run("Dilate", "slice");
	
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display slice");
	
	//roiManager("Reset");
	maxarea=0;
	rowmax=0;
	for (row=0;row<nResults;row++){
		area=getResult("Area", row);
		if (area>maxarea)
		{
			rowmax=row;
			maxarea=area;
		}
	}
if ( nResults>0){
	EndosomesX[p-1]=getResult("X",rowmax);
	EndosomesY[p-1]=getResult("Y",rowmax);
}
	run("Clear Results");
	selectImage(IDpinchimage);
  	close();

  	
  	
}
selectImage(IDGFP);
// Get the center of gravity of the nuclei
for (p=1;p<=count;p++){
	
	setSlice(p+startingslice-1);
	doWand(PinchX[p],PinchY[p],thNuclei, "Legacy");
	run("Measure");
	NucleusX[p-1]=getResult("X",nResults-1);
	NucleusY[p-1]=getResult("Y",nResults-1);
	
}
run("Clear Results");
// create new result table to be saved with 
// pinchx,pinchy,endosomex,endomoe y, nucleus x, nucleus y,and euclidean distance between them for each time point and save it.
for (i=0; i<count-1;i++) {
     setResult("t", i,i+startingslice);
     setResult("pinch X", i, PinchX[i]);
     setResult("pinch Y", i, PinchY[i]);
     setResult("Endosomes center X", i, EndosomesX[i]);
     setResult("Endosomes center Y", i, EndosomesY[i]);
     setResult("Nucleus center X", i, NucleusX[i]);
     setResult("Nucleus center Y", i, NucleusY[i]);
      setResult("distance pinch", i,  sqrt(pow(PinchX[i]-EndosomesX[i],2)+pow(PinchY[i]-EndosomesY[i],2)));
     setResult("distance ensosome", i,  sqrt(pow(NucleusX[i]-EndosomesX[i],2)+pow(NucleusY[i]-EndosomesY[i],2)));
	
  }
  setOption("ShowRowNumbers", false);
  updateResults;
nuclei++;
saveAs("Results",path+filenamecherry+"nuclei_"+nuclei+"_Results.txt");
//create a backupped image to show results
newImage("pinch", "RGB black", width, height, nSlices);
for (i=0;i<count-1;i++){
setSlice(i+startingslice);
setColor(0, 255, 0); //green
fillOval( PinchX[i]-5,  PinchY[i]-5, 10, 10);
setColor(255, 0, 0); //red
fillOval( EndosomesX[i]-5, EndosomesY[i]-5, 10, 10);
setColor(0, 0,255); //blue
fillOval( NucleusX[i]-5, NucleusY[i]-5, 10, 10);
}

setBatchMode("show");
saveAs("Tiff",path+filenamecherry+"nuclei_"+nuclei+"_Pinchview.tif");
run("Close All");
path=getDirectory("Please chose the directory to process. Cancel to stop.");
Dialog.create("File Naming");
Dialog.addString("mCherry specific naming used", "mCherry") ;
Dialog.addString("GFP specific naming used", "GFP") ;
Dialog.addNumber("Radius around pinch",60);
Dialog.addNumber("Threshold for wand tool to get nuclei",50);
Dialog.addNumber("Starting Slice (1 is first)",1);
Dialog.show();
mcherry=Dialog.getString();
gfp=Dialog.getString();

Radius=Dialog.getNumber();
thNuclei=Dialog.getNumber();
startingslice=Dialog.getNumber();
}
}
}


