import ij.*;
import ij.gui.*;
import ij.plugin.*;
import ij.process.*;

/*3D Image convolution.  Bob Dougherty.

Uses code from ImageJ and several plugins.

The following notice is from the FHT source code in ImageJ:

		This class contains a Java implementation of the Fast Hartley Transform.
		It is based on Pascal code in NIH Image contributed by Arlo Reeves
		(http://rsb.info.nih.gov/ij/docs/ImageFFT/). The Fast Hartley Transform was
		restricted by U.S. Patent No. 4,646,256, but was placed in the public domain
		by Stanford University in 1995 and is now freely available.


Version 0 4/28/2005.
Version 1 4/30/2005 Mirror and Periodic extension options; Title input
Version 1.1 5/2/2005 Improved 2D performance
Version 2 5/23/2006 Added correlation option
Version 3 8/4/2006 Added correlation coefficient option and ability to not antiAlias.
Version 3.1 8/4/2006 Fixed a bug that caused an exception with non-matching stack sizes.
Version 3.2 8/4/2006 Fixed a bug in when CC is output.  Option to apply Laplacian to CC.
Version 3.3 8/6/2006 Reversed sign and improved "wrapping" of CC peak report.

*/
/*	License:
	Copyright (c) 2005, 2006, OptiNav, Inc.
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

		Redistributions of source code must retain the above copyright
	notice, this list of conditions and the following disclaimer.
		Redistributions in binary form must reproduce the above copyright
	notice, this list of conditions and the following disclaimer in the
	documentation and/or other materials provided with the distribution.
		Neither the name of OptiNav, Inc. nor the names of its contributors
	may be used to endorse or promote products derived from this software
	without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
public class Convolve_3D implements PlugIn{
    private static final int ZERO_PAD=0, MIRROR=1, PERIODIC=2;
   	private static String[] exts = {"Zero Pad (usually best)", "Mirror (not recommnded for correlation)",
   							"Periodic (similar to built-in ImageJ)"};
 	public void run(String arg){
        if (arg.equalsIgnoreCase("about")){
            showAbout();
            return;
        }
		if (IJ.versionLessThan("1.32c"))
			return;
 		int[] wList = WindowManager.getIDList();
        if (wList == null){
            IJ.noImage();
            return;
        }
        String[] titles = new String[wList.length];
        for (int i = 0; i < wList.length; i++){
            ImagePlus imp = WindowManager.getImage(wList[i]);
            if (imp != null)
                titles[i] = imp.getTitle();
            else
                titles[i] = "";
        }
		String titleImage = Prefs.get("convolve3d.titleImage", titles[0]);
		int imageChoice = 0;
        for (int i = 0; i < wList.length; i++){
			if(titleImage.equals(titles[i])){
				imageChoice = i;
				break;
			}
		}
		String titlePSF = Prefs.get("convolve3d.titlePSF", titles[0]);
		int psfChoice = 0;
        for (int i = 0; i < wList.length; i++){
			if(titlePSF.equals(titles[i])){
				psfChoice = i;
				break;
			}
		}
		int extension = (int)Prefs.get("convolve3d.extension", ZERO_PAD);
		boolean correlate = Prefs.get("convolve3d.correlate", false);
		boolean normalize = Prefs.get("convolve3d.normalize", false);
		boolean antiAlias = Prefs.get("convolve3d.antiAlias", false);
		boolean correlationCoef = Prefs.get("convolve3d.correlationCoef", false);
		boolean laplacian = Prefs.get("convolve3d.laplacian", false);
		boolean dB = Prefs.get("convolve3d.dB", false);
		boolean output = Prefs.get("convolve3d.output", true);
		String[] labels = new String[]{"Correlate (instead of convolve)",
										"Normalize PSF",
										"AntiAlias padding. Increases time and memory.  Usually not recommended.",
										"Correlation Coefficient (overrides Correlate and Normalize.)",
										"Laplacian applied to result (usually CC) to highlight peaks.",
										"Data (image, psf and result) in dB",
										"Create output stack (not needed for correlation coefficient if only peak is required)"};
		boolean[] defaultValues = new boolean[]{correlate,normalize,antiAlias,correlationCoef,laplacian,dB,output};
		GenericDialog gd = new GenericDialog("Convolution 3D", IJ.getInstance());
        gd.addChoice("Image",titles,titles[imageChoice]);
        gd.addChoice("PSF (Kernel) or second image",titles,titles[psfChoice]);
		gd.addChoice("Extension method", exts, exts[extension]);
       	gd.addCheckboxGroup(labels.length,1,labels,defaultValues);
       	gd.addStringField("Output Title ","Output",20);
        gd.showDialog();
        if (gd.wasCanceled())
            return;
        ImagePlus impY = WindowManager.getImage(wList[gd.getNextChoiceIndex()]);
        ImagePlus impA = WindowManager.getImage(wList[gd.getNextChoiceIndex()]);
        extension = gd.getNextChoiceIndex();
        correlate = gd.getNextBoolean();
		normalize = gd.getNextBoolean();
		antiAlias = gd.getNextBoolean();
 		correlationCoef = gd.getNextBoolean();
 		laplacian = gd.getNextBoolean();
     	dB = gd.getNextBoolean();
      	output = gd.getNextBoolean();
        String titleOut = gd.getNextString();

 		if(correlationCoef){
			correlate = true;
			normalize = true; //Only purpose is to set the defalult next time to show
							  //the user that correlationCoef is controlling this issue
		}

		Prefs.set("convolve3d.titleImage", impY.getTitle());
		Prefs.set("convolve3d.titlePSF", impA.getTitle());
		Prefs.set("convolve3d.extension", extension);
		Prefs.set("convolve3d.correlate", correlate);
		Prefs.set("convolve3d.normalize", normalize);
		Prefs.set("convolve3d.antiAlias", antiAlias);
		Prefs.set("convolve3d.correlationCoef", correlationCoef);
		Prefs.set("convolve3d.laplacian", laplacian);
		Prefs.set("convolve3d.dB", dB);
		Prefs.set("convolve3d.output", output);

		if(!(output||correlationCoef)){
			IJ.error("Nothing to do: neither Correlation Coefficient nor Create output is selected.");
			return;
		}
		if(dB && (titleImage.equals(titlePSF))){
			IJ.error("PSF and image must be distinct with the dB option.");
		}
		ImageProcessor ipY = impY.getProcessor();
		ImageProcessor ipA = impA.getProcessor();
 		if(((ipY instanceof ColorProcessor)||(ipA instanceof ColorProcessor))){
			IJ.showMessage("RGB images are not currently supported.");
			return;
		}

		ImageStack stackY = impY.getStack();
		int bw = stackY.getWidth();
		int bh = stackY.getHeight();
		int bd = impY.getStackSize();
		float[][] dataYin = new float[bd][];
		if(ipY instanceof FloatProcessor){
			for (int i = 0; i < bd; i++){
 				dataYin[i] = (float[])stackY.getProcessor(i+1).getPixels();
			}
		}else{
			for (int i = 0; i < bd; i++){
 				dataYin[i] = (float[])stackY.getProcessor(i+1).convertToFloat().getPixels();
			}
		}

		ImageStack stackA = impA.getStack();
		int kw = stackA.getWidth();
		int kh = stackA.getHeight();
		int kd = impA.getStackSize();
		if((kw > bw)||(kh > bh)||(kd > bd)){
			IJ.error("The PSF cannot be larger than the image in any dimension.");
			return;
		}
		float[][] dataAin = new float[kd][];
		if(ipA instanceof FloatProcessor){
			for (int i = 0; i < kd; i++){
 				dataAin[i] = (float[])stackA.getProcessor(i+1).getPixels();
			}
		}else{
			for (int i = 0; i < kd; i++){
 				dataAin[i] = (float[])stackA.getProcessor(i+1).convertToFloat().getPixels();
			}
		}

		double minA = 0;
		double minY = 0;
		if(dB){
			minA = unDB(dataAin);
			minY = unDB(dataYin);
		}

		int bwE = expandedSize(bw,antiAlias);
		int bhE = expandedSize(bh,antiAlias);
		int bdE = (bd == 1) ? 1 : expandedSize(bd,antiAlias);
		int kwE = expandedSize(kw,antiAlias);
		int khE = expandedSize(kh,antiAlias);
		int kdE = (kd == 1) ? 1 : expandedSize(kd,antiAlias);
		//w and h will always be at least 4.  d can be 1 as a special case.
		int w = (int)Math.max(bwE,kwE);
		int h = (int)Math.max(bhE,khE);
		int d = (int)Math.max(bdE,kdE);

		float[][] result = new float[d][w*h];

		IJ.showStatus("Convolve 3D: creating expanded arrays");
		float[][] dataA = new float[d][w*h];
		float[][] dataY = new float[d][w*h];
		if(correlationCoef){
			//Use dataY as temporary storage to make Ain the same size as Yin,
			//justified at the top-left
			copyDataTopLeft(kw,kh,kd,dataAin,bw,bh,bd,dataY);
			if(extension == ZERO_PAD){
				copyDataMask(bw,bh,bd,dataY,w,h,d,dataA);
			}else if (extension == MIRROR){
				copyDataMirror(bw,bh,bd,dataY,w,h,d,dataA);
			}else{
				copyDataPeriodic(bw,bh,bd,dataY,w,h,d,dataA);
			}
			zeroData(bw,bh,bd,dataY);
		}else{
			copyDataMask(kw,kh,kd,dataAin,w,h,d,dataA);
		}
		if(extension == ZERO_PAD){
			copyDataMask(bw,bh,bd,dataYin,w,h,d,dataY);
		}else if (extension == MIRROR){
			copyDataMirror(bw,bh,bd,dataYin,w,h,d,dataY);
		}else{
			copyDataPeriodic(bw,bh,bd,dataYin,w,h,d,dataY);
		}

		float scalePSF = 1;
		if(normalize&(!correlationCoef)){
			float sum = 0;
			for (int k = 0; k < kd; k++){
				for (int ind = 0; ind < kh*kw; ind++){
					sum += dataAin[k][ind];
				}
			}
			if(sum != 0)scalePSF /= sum;
		}
		if(correlationCoef){
			double sumA = 0;
			double sumY = 0;
			for (int k = 0; k < d; k++){
				for (int ind = 0; ind < h*w; ind++){
					sumA += dataA[k][ind]*dataA[k][ind];
					sumY += dataY[k][ind]*dataY[k][ind];
				}
			}
			float sum = (float)Math.sqrt(sumA*sumY);
			if(sum != 0)scalePSF /= sum;
		}

		IJ.showStatus("Convolve 3D: swapping quadrants of the PSF");
		swapQuadrants(w,h,d,dataA);

		java.awt.image.ColorModel cmY = stackY.getProcessor(1).getColorModel();

		IJ.showStatus("Convolve 3D: transforming PSF");
		IJ.showStatus("Convolve 3D: transforming PSF");
		FHT3D(dataA,w,h,d,false);
		IJ.showStatus("Convolve 3D: transforming image");
		FHT3D(dataY,w,h,d,false);
		if(correlate)
			IJ.showStatus("Convolve 3D: correlate in frequency domain");
		else
			IJ.showStatus("Convolve 3D: convolve in frequency domain");
		if(correlate){
			correlateFD(w,h,d,dataA,dataY,result);
		}else{
			convolveFD(w,h,d,dataA,dataY,result);
		}
		IJ.showStatus("Convolve 3D: untransforming result");
		FHT3D(result,w,h,d,true);

		//Apply scale factors
		if(scalePSF != 1){
			IJ.showStatus("Convolve 3D: Normalizing");
			for (int k = 0; k < d; k++){
				for (int ind = 0; ind < h*w; ind++){
					result[k][ind] *= scalePSF;
				}
			}
		}
		if(dB){
			toDB(dataAin, minA);
			toDB(dataYin, minY);
			toDB(result, -90);
		}
		//Crop the output to the size of Yin
		int kOff = (d - bd + 1)/2;
		int jOff = (h - bh + 1)/2;
		int iOff = (w - bw + 1)/2;
		//float norm = (float)Math.sqrt(w*h*d)
		int peakSlice = 1;
		if(laplacian){
			if(d > 1){
				for (int k = 1; k < (d-1); k++){
					for (int j = 1; j < (h-1); j++){
						for (int i = 1; i < (w-1); i++){
							dataA[k][i + w*j] = 6*result[k][i+w*j] -
												result[k-1][i+w*j] -
												result[k+1][i+w*j] -
												result[k][i+1+w*j] -
												result[k][i-1+w*j] -
												result[k][i+w*(j+1)] -
												result[k][i+w*(j-1)];
						}
					}
				}
				for (int k = 0; k < d; k++){
					for (int j = 0; j < h; j++){
						for (int i = 0; i < w; i++){
							if((k==0)||(k==(d-1))||(j==0)||(j==(h-1))||(i==0)||(i==(w-1))){
								result[k][i+w*j] = 0;
							}else{
								result[k][i+w*j] = dataA[k][i + w*j];
							}
						}
					}
				}
			}else{
				for (int k = 0; k < d; k++){
					for (int j = 1; j < (h-1); j++){
						for (int i = 1; i < (w-1); i++){
							dataA[k][i + w*j] = 4*result[k][i+w*j] -
												result[k][i+1+w*j] -
												result[k][i-1+w*j] -
												result[k][i+w*(j+1)] -
												result[k][i+w*(j-1)];
						}
					}
					for (int j = 0; j < h; j++){
						for (int i = 0; i < w; i++){
							if((j==0)||(j==(h-1))||(i==0)||(i==(w-1))){
								result[k][i+w*j] = 0;
							}else{
								result[k][i+w*j] = dataA[0][i + w*j];
							}
						}
					}
				}
			}
		}
		if(correlationCoef){
			int iPeak = 0;
			int jPeak = 0;
			int kPeak = 0;
			float ccMax = -Float.MAX_VALUE;
			float cc;
			for (int k = 0; k < bd; k++){
				for (int j = 0; j < bh; j++){
					for (int i = 0; i < bw; i++){
						cc = result[k+kOff][i + iOff + w*(j+jOff)];
						if(cc > ccMax){
							ccMax = cc;
							iPeak = i;
							jPeak = j;
							kPeak = k;
						}
					}
				}
			}
			peakSlice = kPeak + 1;
			int iO = bw/2 - iPeak;
			int jO = bh/2 - jPeak;
			int kO = bd/2 - kPeak;
			iO = findWrap(iO,bw,kw,w);
			jO = findWrap(jO,bh,kh,h);
			kO = findWrap(kO,bd,kd,d);
			if(laplacian){
					IJ.showMessage("Peak Laplacian of result. = "+IJ.d2s(ccMax)+" Offset: "+iO+" "+jO+" "+kO);
			}else{
				if(dB){
					IJ.showMessage("Peak correlation coef. = "+IJ.d2s(ccMax)+" dB. Offset: "+iO+" "+jO+" "+kO);
				}else{
					IJ.showMessage("Peak correlation coef. = "+IJ.d2s(ccMax)+" Offset: "+iO+" "+jO+" "+kO);
				}
			}
		}
		if(output){
			ImageStack stackOut = new ImageStack(bw,bh);
			for (int k = 0; k < bd; k++){
				ImageProcessor ip = new FloatProcessor(bw,bh);
				float[] px = (float[])ip.getPixels();
				for (int j = 0; j < bh; j++){
					for (int i = 0; i < bw; i++){
						px[i + bw*j] = result[k+kOff][i + iOff + w*(j+jOff)];
					}
				}
				ip.setMinAndMax(0,0);
				ip.setColorModel(cmY);
				stackOut.addSlice(null,ip);
			}
			ImagePlus impOut = new ImagePlus(titleOut,stackOut);
			if(correlate)impOut.setSlice(peakSlice);
			ImageProcessor ipOut = impOut.getProcessor();
			ipOut.setMinAndMax(0,0);
			impOut.show();
		}
	}//run
	int findWrap(int delta,int bw, int kw, int w){
		double onPlus = Math.min(bw,delta+w+kw) - Math.max(0,delta+w);
		double on = Math.min(bw,delta+kw) - Math.max(0,delta);
		double onMinus = Math.min(bw,delta-w+kw) - Math.max(0,delta-w);
		if((on >= onPlus)&&(on >= onMinus)){
			return delta;
		}else if(onPlus >= onMinus){
			return delta + w;
		}
		return delta - w;
	}
	void copyDataTopLeft(int w, int h, int d,float[][] data,int wE,int hE,int dE,float[][] dataE){
		for(int k = 0; k < d; k++){
			for (int j = 0; j < h; j++){
				for (int i = 0; i < w; i++){
					dataE[k][i + wE*j] = data[k][i + w*j];
				}
			}
		}
	}
	void zeroData(int w, int h, int d,float[][] data){
		for(int k = 0; k < d; k++){
			for (int j = 0; j < h; j++){
				for (int i = 0; i < w; i++){
					data[k][i + w*j] = 0;
				}
			}
		}
	}
	void copyDataMask(int w, int h, int d,float[][] data,int wE,int hE,int dE,float[][] dataE){
		int kOff = (dE - d + 1)/2;
		int jOff = (hE - h + 1)/2;
		int iOff = (wE - w + 1)/2;
		for(int k = 0; k < d; k++){
			for (int j = 0; j < h; j++){
				for (int i = 0; i < w; i++){
					dataE[k+kOff][i+iOff + wE*(j+jOff)] = data[k][i + w*j];
				}
			}
		}
	}
	void copyDataPeriodic(int w, int h, int d,float[][] data,int wE,int hE,int dE,float[][] dataE){
		int kOff = (dE - d + 1)/2;
		int jOff = (hE - h + 1)/2;
		int iOff = (wE - w + 1)/2;
		int iIn,jIn,kIn,iOut,jOut,kOut;
		for(int k = -kOff; k < dE-kOff; k++){
			kOut = k + kOff;
			kIn = mod(k,d);
			for (int j = -jOff; j < hE-jOff; j++){
				jOut = j + jOff;
				jIn = mod(j,h);
				for (int i = -iOff; i < wE-iOff; i++){
					iOut = i + iOff;
					iIn = mod(i,w);
					dataE[kOut][iOut + wE*jOut] = data[kIn][iIn + w*jIn];
				}
			}
		}
	}
	void copyDataMirror(int w, int h, int d,float[][] data,int wE,int hE,int dE,float[][] dataE){
		int kOff = (dE - d + 1)/2;
		int jOff = (hE - h + 1)/2;
		int iOff = (wE - w + 1)/2;
		int iIn,jIn,kIn,iOut,jOut,kOut;
		for(int k = -kOff; k < dE-kOff; k++){
			kOut = k + kOff;
			kIn = mirror(k,d);
			for (int j = -jOff; j < hE-jOff; j++){
				jOut = j + jOff;
				jIn = mirror(j,h);
				for (int i = -iOff; i < wE-iOff; i++){
					iOut = i + iOff;
					iIn = mirror(i,w);
					dataE[kOut][iOut + wE*jOut] = data[kIn][iIn + w*jIn];
				}
			}
		}
	}
	int mirror(int i, int n){
		int ip = mod(i,2*n);
		if(ip < n){
			return ip;
		}else{
			return n - (ip % n) - 1;
		}
	}
	//A version of mod that is periodic for postive and negative i
	int mod(int i, int n){
		return ((i % n) + n) % n;
	}
	int expandedSize(int maxN,boolean antiAlias){
		//Expand this to a power of 2 that is at least 1.5* as large, to avoid wrap effects
		//Start with 4 to avoid apparent normalization problems with n = 2
		int iN=4;
		if(antiAlias){
			if(maxN > 1){
				while(iN<1.5 * maxN) iN *= 2;
			}
		}else{
			if(maxN > 1){
				while(iN<maxN) iN *= 2;
			}
		}
		return iN;
	}
	double unDB(float[][] x){
		double result = Float.MAX_VALUE;
		int n = x.length;
		for (int i = 0; i < n; i++){
			double ri = unDB(x[i]);
			if(ri < result) result = ri;
		}
		return result;
	}
	double unDB(float[] x){
		double SCALE = 10/Math.log(10);
		int n = x.length;
		double result = Float.MAX_VALUE;
		for (int i = 0; i < n; i++){
			if(x[i] < result) result = x[i];
			x[i] = (float)Math.exp(x[i]/SCALE);
		}
		return result;
	}
	void toDB(float[][] x, double minDB){
		double SCALE = 10/Math.log(10);
		int n = x.length;
		for (int i = 0; i < n; i++){
			toDB(x[i], minDB);
		}
	}
	void toDB(float[] x, double minDB){
		double SCALE = 10/Math.log(10);
		double minVal = Math.exp(minDB/SCALE);
		int n = x.length;
		for (int i = 0; i < n; i++){
			if(x[i] > minVal)
				x[i] = (float)(SCALE*Math.log(x[i]));
			else
				x[i] = (float)minDB;
		}
	}
	void swapQuadrants(int w,int h,int d,float[][] x){
		int k1P,k2P,k3P;
		float temp;
		int wHalf = w/2;
		int hHalf = h/2;
		int dHalf = d/2;
		//Shift by half of the grid, less one pixel, in each direction
		for(int k3 = 0; k3 < dHalf; k3++){
			k3P = k3 + dHalf;
			for (int k2 = 0; k2 < h; k2++){
				for (int k1 = 0; k1 < w; k1++){
					temp = x[k3][k1 + w*k2];
					x[k3][k1 + w*k2] = x[k3P][k1 + w*k2];
					x[k3P][k1 + w*k2] = temp;
				}
			}
		}
		for(int k2 = 0; k2 < hHalf; k2++){
			k2P = k2 + hHalf;
			for (int k3 = 0; k3 < d; k3++){
				for (int k1 = 0; k1 < w; k1++){
					temp = x[k3][k1 + w*k2];
					x[k3][k1 + w*k2] = x[k3][k1 + w*k2P];
					x[k3][k1 + w*k2P] = temp;
				}
			}
		}
		for(int k1 = 0; k1 < wHalf; k1++){
			k1P = k1 + wHalf;
			for (int k2 = 0; k2 < h; k2++){
				for (int k3 = 0; k3 < d; k3++){
					temp = x[k3][k1 + w*k2];
					x[k3][k1 + w*k2] = x[k3][k1P + w*k2];
					x[k3][k1P + w*k2] = temp;
				}
			}
		}
	}
	void convolveFD(int w,int h,int d,float[][] h1,float[][] h2, float[][] result){
		int k1C,k2C,k3C;
		double h2e,h2o;
		for(int k3 = 0; k3 < d; k3++){
			k3C = (d - k3) % d;
			for (int k2 = 0; k2 < h; k2++){
				k2C = (h - k2) % h;
				for (int k1 = 0; k1 < w; k1++){
					k1C = (w - k1) % w;
					h2e = (h2[k3][k1 + w*k2] + h2[k3C][k1C + w*k2C])/2;
					h2o = (h2[k3][k1 + w*k2] - h2[k3C][k1C + w*k2C])/2;
					result[k3][k1 + w*k2] = (float)(h1[k3][k1 + w*k2]*h2e + h1[k3C][k1C + w*k2C]*h2o);
				}
			}
		}
	}
	void correlateFD(int w,int h,int d,float[][] h1,float[][] h2, float[][] result){
		int k1C,k2C,k3C;
		double h2e,h2o;
		for(int k3 = 0; k3 < d; k3++){
			k3C = (d - k3) % d;
			for (int k2 = 0; k2 < h; k2++){
				k2C = (h - k2) % h;
				for (int k1 = 0; k1 < w; k1++){
					k1C = (w - k1) % w;
					h2e = (h2[k3][k1 + w*k2] + h2[k3C][k1C + w*k2C])/2;
					h2o = (h2[k3][k1 + w*k2] - h2[k3C][k1C + w*k2C])/2;
					result[k3][k1 + w*k2] = (float)(h1[k3][k1 + w*k2]*h2e - h1[k3C][k1C + w*k2C]*h2o);
				}
			}
		}
	}
    boolean powerOf2Size(int w) {
        int i=2;
        while(i<w) i *= 2;
        return i==w;
    }
	public void FHT3D(float[][] data,int w, int h, int d, boolean inverse) {
		float[] sw = new float[w/4];
		float[] cw = new float[w/4];
		float[] sh = new float[h/4];
		float[] ch = new float[h/4];
		makeSinCosTables(w,sw,cw);
		makeSinCosTables(h,sh,ch);
		for (int i = 0; i < d; i++){
	 		rc2DFHT(data[i], w, h, sw, cw, sh, ch);
		}
		float[] u = new float[d];
		//if(IJ.getNumber("0 for fast, 1 for slow",0)==0){
		if(powerOf2Size(d)){
			float[] s = new float[d/4];
			float[] c = new float[d/4];
			makeSinCosTables(d,s,c);
			for(int k2 = 0; k2 < h; k2++){
				for(int k1 = 0; k1 < w; k1++){
					int ind = k1 + k2*w;
					for(int k3 = 0; k3 < d; k3++){
						u[k3] = data[k3][ind];
					}
					dfht3(u, 0, d, s, c);
					for(int k3 = 0; k3 < d; k3++){
						data[k3][ind] = u[k3];
					}
				}
			}
		}else{
			float[] cas = hartleyCoefs(d);
			float[] work = new float[d];
			for(int k2 = 0; k2 < h; k2++){
				for(int k1 = 0; k1 < w; k1++){
					int ind = k1 + k2*w;
					for(int k3 = 0; k3 < d; k3++){
						u[k3] = data[k3][ind];
					}
					slowHT(u,cas,d,work);
					for(int k3 = 0; k3 < d; k3++){
						data[k3][ind] = u[k3];
					}
				}
			}
		}
		//Convert to actual Hartley transform
		float A,B,C,D,E,F,G,H;
		int k1C,k2C,k3C;
		for(int k3 = 0; k3 <= d/2; k3++){
			k3C = (d - k3) % d;
			for(int k2 = 0; k2 <= h/2; k2++){
				k2C = (h - k2) % h;
				for (int k1 = 0; k1 <= w/2; k1++){
					k1C = (w - k1) % w;
					A = data[k3][k1 + w*k2C];
					B = data[k3][k1C + w*k2];
					C = data[k3C][k1 + w*k2];
					D = data[k3C][k1C + w*k2C];
					E = data[k3C][k1 + w*k2C];
					F = data[k3C][k1C + w*k2];
					G = data[k3][k1 + w*k2];
					H = data[k3][k1C + w*k2C];
					data[k3][k1 + w*k2] = (A+B+C-D)/2;
					data[k3C][k1 + w*k2] = (E+F+G-H)/2;
					data[k3][k1 + w*k2C] = (G+H+E-F)/2;
					data[k3C][k1 + w*k2C] = (C+D+A-B)/2;
					data[k3][k1C + w*k2] = (H+G+F-E)/2;
					data[k3C][k1C + w*k2] = (D+C+B-A)/2;
					data[k3][k1C + w*k2C] = (B+A+D-C)/2;
					data[k3C][k1C + w*k2C] = (F+E+H-G)/2;
				}
			}
		}
		if(inverse){
			//float norm = (float)Math.sqrt(d*h*w);
			float norm = d*h*w;
			for(int k3 = 0; k3 < d; k3++){
				for(int k2 = 0; k2 < h; k2++){
					for (int k1 = 0; k1 < w; k1++){
					data[k3][k1 + w*k2] /= norm;
					}
				}
			}
		}
	}
	float[] hartleyCoefs(int max){
		float[] cas = new float[max*max];
		int ind = 0;
		for(int n = 0; n < max; n++){
			for (int k = 0; k < max; k++){
				double arg = (2*Math.PI*k*n)/max;
				cas[ind++] = (float)(Math.cos(arg) + Math.sin(arg));
			}
		}
		return cas;
	}
	void slowHT(float[] u, float[] cas, int max, float[] work){
		int ind = 0;
		for(int k = 0; k < max; k++){
			float sum = 0;
			for(int n = 0; n < max; n++){
				sum += u[n]*cas[ind++];
			}
			work[k] = sum;
		}
		for (int k = 0; k < max; k++){
			u[k] = work[k];
		}
	}
	void makeSinCosTables(int maxN, float[] s, float[] c) {
		int n = maxN/4;
		double theta = 0.0;
		double dTheta = 2.0 * Math.PI/maxN;
		for (int i=0; i<n; i++) {
			c[i] = (float)Math.cos(theta);
			s[i] = (float)Math.sin(theta);
			theta += dTheta;
		}
	}
	/** Row-column Fast Hartley Transform */
	void rc2DFHT(float[] x, int w, int h, float[] sw, float[] cw, float[] sh, float[] ch) {
		for (int row=0; row<h; row++)
			dfht3(x, row*w, w, sw, cw);
		float[] temp = new float[h];
		for(int col = 0; col < w; col++){
			for (int row = 0; row < h; row++){
				temp[row] = x[col + w*row];
			}
			dfht3(temp, 0, h, sh, ch);
			for (int row = 0; row < h; row++){
				x[col + w*row] = temp[row];
			}
		}
	}
	/* An optimized real FHT */
	void dfht3 (float[] x, int base, int maxN, float[] s, float[] c) {
		int i, stage, gpNum, gpIndex, gpSize, numGps, Nlog2;
		int bfNum, numBfs;
		int Ad0, Ad1, Ad2, Ad3, Ad4, CSAd;
		float rt1, rt2, rt3, rt4;

		Nlog2 = log2(maxN);
		BitRevRArr(x, base, Nlog2, maxN);	//bitReverse the input array
		gpSize = 2;     //first & second stages - do radix 4 butterflies once thru
		numGps = maxN / 4;
		for (gpNum=0; gpNum<numGps; gpNum++)  {
			Ad1 = gpNum * 4;
			Ad2 = Ad1 + 1;
			Ad3 = Ad1 + gpSize;
			Ad4 = Ad2 + gpSize;
			rt1 = x[base+Ad1] + x[base+Ad2];   // a + b
			rt2 = x[base+Ad1] - x[base+Ad2];   // a - b
			rt3 = x[base+Ad3] + x[base+Ad4];   // c + d
			rt4 = x[base+Ad3] - x[base+Ad4];   // c - d
			x[base+Ad1] = rt1 + rt3;      // a + b + (c + d)
			x[base+Ad2] = rt2 + rt4;      // a - b + (c - d)
			x[base+Ad3] = rt1 - rt3;      // a + b - (c + d)
			x[base+Ad4] = rt2 - rt4;      // a - b - (c - d)
		}
		if (Nlog2 > 2) {
			 // third + stages computed here
			gpSize = 4;
			numBfs = 2;
			numGps = numGps / 2;
			//IJ.write("FFT: dfht3 "+Nlog2+" "+numGps+" "+numBfs);
			for (stage=2; stage<Nlog2; stage++) {
				for (gpNum=0; gpNum<numGps; gpNum++) {
					Ad0 = gpNum * gpSize * 2;
					Ad1 = Ad0;     // 1st butterfly is different from others - no mults needed
					Ad2 = Ad1 + gpSize;
					Ad3 = Ad1 + gpSize / 2;
					Ad4 = Ad3 + gpSize;
					rt1 = x[base+Ad1];
					x[base+Ad1] = x[base+Ad1] + x[base+Ad2];
					x[base+Ad2] = rt1 - x[base+Ad2];
					rt1 = x[base+Ad3];
					x[base+Ad3] = x[base+Ad3] + x[base+Ad4];
					x[base+Ad4] = rt1 - x[base+Ad4];
					for (bfNum=1; bfNum<numBfs; bfNum++) {
					// subsequent BF's dealt with together
						Ad1 = bfNum + Ad0;
						Ad2 = Ad1 + gpSize;
						Ad3 = gpSize - bfNum + Ad0;
						Ad4 = Ad3 + gpSize;

						CSAd = bfNum * numGps;
						rt1 = x[base+Ad2] * c[CSAd] + x[base+Ad4] * s[CSAd];
						rt2 = x[base+Ad4] * c[CSAd] - x[base+Ad2] * s[CSAd];

						x[base+Ad2] = x[base+Ad1] - rt1;
						x[base+Ad1] = x[base+Ad1] + rt1;
						x[base+Ad4] = x[base+Ad3] + rt2;
						x[base+Ad3] = x[base+Ad3] - rt2;

					} /* end bfNum loop */
				} /* end gpNum loop */
				gpSize *= 2;
				numBfs *= 2;
				numGps = numGps / 2;
			} /* end for all stages */
		} /* end if Nlog2 > 2 */
	}
	int log2 (int x) {
		int count = 15;
		while (!btst(x, count))
			count--;
		return count;
	}
	private boolean btst (int  x, int bit) {
		//int mask = 1;
		return ((x & (1<<bit)) != 0);
	}
	void BitRevRArr (float[] x, int base, int bitlen, int maxN) {
		int    l;
		float[] tempArr = new float[maxN];
		for (int i=0; i<maxN; i++)  {
			l = BitRevX (i, bitlen);  //i=1, l=32767, bitlen=15
			tempArr[i] = x[base+l];
		}
		for (int i=0; i<maxN; i++)
			x[base+i] = tempArr[i];
	}
	private int BitRevX (int  x, int bitlen) {
		int  temp = 0;
		for (int i=0; i<=bitlen; i++)
			if ((x & (1<<i)) !=0)
				temp  |= (1<<(bitlen-i-1));
		return temp & 0x0000ffff;
	}
	private int bset (int x, int bit) {
		x |= (1<<bit);
		return x;
	}
    static public void showAbout(){
        IJ.showMessage( "About Iterative Decon 3D ...",
                        "Iterative convolution and positive deconvolution\n" +
                        "in 3D");
    }

 }//Convolve_3D