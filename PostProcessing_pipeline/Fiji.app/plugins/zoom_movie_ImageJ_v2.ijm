//ImageJ macro making a movie (stack) of zooming on selected rectangle (ROI)
//Eugene Katrukha katpyxa at gmail.com
requires("1.48h");

//check if there is rectangular selection
if(selectionType() ==0)
{
	sTitle=getTitle();
	sMovieTitle=sTitle+"_zoom_movie";
	setBatchMode(true);
	
	//ROI parameters
	Roi.getBounds(nX, nY, nW, nH);
	//print(nX);
	//print(nY);
	//print(nW);
	//print(nH);
	
	//Dialog
	Dialog.create("Zoom-in parameters:");
	Dialog.addNumber("Number of frames for zoom-in:", 10);
	Dialog.addNumber("Add static number of frames in the end:", 10); 
	minMax=newArray("min","max");
	Dialog.addChoice("Zoom to min/max ROI size:", minMax); 
	sScaleChoice=newArray("same as ROI","Specified below");
	Dialog.addChoice("Final movie dimensions (px):", sScaleChoice); 
	Dialog.addNumber("Final movie width:", nW); 
	Dialog.addNumber("Final movie width:", nH); 
	Dialog.show();
	nFrames=Dialog.getNumber();
	nFramesLast=Dialog.getNumber();
	sChoice=Dialog.getChoice();
	sSizeChoice=Dialog.getChoice();
	nFinalW=Dialog.getNumber();
	nFinalH=Dialog.getNumber();
	
	//print(nFinalW);
	//print(nFinalH);
	
	imageH=getHeight();
	imageW=getWidth();
	rawID=getImageID();


	nCenterX=nX+0.5*nW;
	//print("CenterX");
	//print(nCenterX);
	nCenterY=nY+0.5*nH;
	//print("CenterY");
	//print(nCenterY);

	nScaleX=nW/imageW;
	nScaleY=nH/imageH;
	
		
	//adjust roi x/y ratio to image x/y ratio
	//depending on user choice
	if(startsWith(sChoice, "min"))
		nScaleFin=minOf(nScaleX,nScaleY);
	else
		nScaleFin=maxOf(nScaleX,nScaleY);
	
	nW=nScaleFin*imageW;
	nH=nScaleFin*imageH;
	//print("New nW");
	//print(nW);
	//print("New nH");
	//print(nH);
	nX=nCenterX-(nW*0.5);
	nY=nCenterY-(nH*0.5);
	//print(nX);
	//print(nY);
	
	//distance from (0,0) to left top corner of selsction
	length=sqrt(nX*nX+nY*nY);
	//print("length");
	//print(length);
	if(nX==0)
		angle=3.14/2;
	else
		angle=atan(nY/nX);
	//print("angle");
	//print(angle);	

	//final movie size
	if(startsWith(sSizeChoice,"same as"))
	{
		nFinalW=nW;
		nFinalH=nH;
	}
	else
	{
		nMovieScaleX=nW/nFinalW;
		nMovieScaleY=nH/nFinalH;
		nMovieFinalScale = minOf(nMovieScaleX,nMovieScaleY);
		nFinalW=nW/nMovieFinalScale;
		nFinalH=nH/nMovieFinalScale;
	}
	//print(nFinalW);
	//print(nFinalH);
	
	nScaleStep=(1-nScaleFin)/nFrames;
	bNotFirstIt=false;

	dCount =0;
	//for(nScale=1;nScale>=nScaleFin;nScale=nScale-nScaleStep)
	nScale=1;
	for(dCount =0;dCount<=nFrames;dCount++)
	{		
		selectImage(rawID);	
		//change viewport position/scale	
		dLen=length*dCount/nFrames;
		//print("dlen");
		//print(dLen);

		offsetX=dLen*cos(angle);
		offsetY=dLen*sin(angle);
		
		newW=imageW*nScale;
		newH=imageH*nScale;
		run("Specify...", "width="+toString(newW)+" height="+toString(newH)+" x="+toString(offsetX)+" y="+toString(offsetY));
		run("Duplicate...", "title="+sTitle+toString(nScale));
		unscaledID=getImageID();
		run("Scale...", "x=- y=- width="+toString(nFinalW)+" height="+toString(nFinalH)+" interpolation=Bicubic average create");
		scaledID=getImageID();
		selectImage(unscaledID);
		close();
		selectImage(scaledID);
		//not a first frame, let's add to existing movie stack
		if(bNotFirstIt)
		{
			sCurrTitle=sTitle+"x"+toString(nScale);
			rename(sCurrTitle);
			run("Concatenate...", "  title=["+sMovieTitle+"] image1=["+sMovieTitle+"] image2=["+sCurrTitle+"]");
		}
		//first frame, let's make accumulating stack out of it
		else
		{
			rename(sMovieTitle);
			sMovieID=getImageID();
			bNotFirstIt=true;
		}
		nScale=nScale-nScaleStep;
	}

	//adding static frames part
	nScale=nScaleFin;
	for(nAddFrames=1;nAddFrames<=nFramesLast;nAddFrames++)
	{
		selectImage(rawID);	
		offsetX=dLen*cos(angle);
		offsetY=dLen*sin(angle);
		newW=imageW*nScale;
		newH=imageH*nScale;
		run("Specify...", "width="+toString(newW)+" height="+toString(newH)+" x="+toString(offsetX)+" y="+toString(offsetY));
		run("Duplicate...", "title="+sTitle+toString(nScale));
		unscaledID=getImageID();
		run("Scale...", "x=- y=- width="+toString(nFinalW)+" height="+toString(nFinalH)+" interpolation=Bilinear average create");
		scaledID=getImageID();
		selectImage(unscaledID);
		close();
		selectImage(scaledID);
		sCurrTitle=sTitle+"x"+toString(nScale);
		rename(sCurrTitle);
		run("Concatenate...", "  title=["+sMovieTitle+"] image1=["+sMovieTitle+"] image2=["+sCurrTitle+"]");
			
	}
	setBatchMode(false);
}
//no rectangular ROI selection, error
else
{
	exit("Please choose rectangular selection (ROI) first.");
}