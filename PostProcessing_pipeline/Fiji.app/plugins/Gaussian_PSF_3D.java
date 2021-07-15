import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.plugin.filter.*;
import ij.plugin.*;
import ij.process.*;
import ij.gui.*;

/** This plugin calculates a three dimensional (3-D) gaussian lowpass filter using
     a 3-D Gaussian or Normal density function is defined in the literature.
     It was derived from Erik Lieng's Gaussian Filter plugin with several changes, including the width definition.

     Gaussian filters are important in many signal processing, image processing,
     and communication applications. These filters are characterized by narrow bandwidths and
     sharp cutoffs. A key feature of Gaussian filters is that the Fourier transform of a Gaussian is
     also a Gaussian, so the filter has the same response shape in both the time and frequency domains.

     The sigma parameters determine the peak width. The DC-level parameter defines the height of the dc center component.

     Erik Lieng 01/10/2002
     Bob Dougherty 4/28/05
     Version 0 4/28/05
     Version 1 4/28/2005.  Distinct first words of dialog parameters to help macro
*/
/*	License:
	Copyright (c) 2005, OptiNav, Inc.
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
public class Gaussian_PSF_3D implements PlugIn {
	int w,h,d;
	double sigmaX, sigmaY, sigmaZ, dcLevel;
    public void run(String arg) {
        if (!showDialog())
            return;
		int iCent = w/2;
		int jCent = h/2;
		int kCent = d/2;
		ImageStack stack = new ImageStack(w,h);
		for (int k = 0; k < d; k++){
			ImageProcessor ip = new FloatProcessor(w,h);
			float[] g = (float[])ip.getPixels();
			for (int j = 0; j < h; j++){
				for (int i = 0; i < w; i++){
					double rSq = sqr((i - iCent)/sigmaX) + sqr((j - jCent)/sigmaY) + sqr((k - kCent)/sigmaZ);
					g[i + w*j] = (float)(dcLevel*Math.exp(-rSq/2));
				}
			}
			stack.addSlice(null,ip);
		}
		ImagePlus imp = new ImagePlus("PSF",stack);
		imp.setSlice(kCent + 1);
		ImageProcessor ip = imp.getProcessor();
		ip.setMinAndMax(0,0);
		imp.show();
	}
	double sqr(double x){
		return x*x;
	}
	public boolean showDialog() {
		w = (int)Prefs.get("gaussianfilter3d.w", 64);
		h = (int)Prefs.get("gaussianfilter3d.h", 64);
		d = (int)Prefs.get("gaussianfilter3d.d", 64);
		dcLevel = Prefs.get("gaussianfilter3d.dclevel", 1);
		sigmaX = Prefs.get("gaussianfilter3d.sigmax", 10);
		sigmaY = Prefs.get("gaussianfilter3d.sigmay", 10);
		sigmaZ = Prefs.get("gaussianfilter3d.sigmaz", 10);
        GenericDialog gd = new GenericDialog("Parameters");
        gd.addNumericField("width of image", w, 0);
        gd.addNumericField("height of image", h, 0);
        gd.addNumericField("number of slices", d, 0);
        gd.addNumericField("DC-level (peak height):", dcLevel, 2);
        gd.addNumericField("horizontal peak width, sigma X (pixels)", sigmaX, 2);
        gd.addNumericField("vertical peak width, sigma Y (pixels)", sigmaY, 2);
        gd.addNumericField("depth peak width, sigma Z (slices)", sigmaZ, 2);
        gd.showDialog();
        if (gd.wasCanceled())
            return false;
        w = (int)gd.getNextNumber();
        h = (int)gd.getNextNumber();
        d = (int)gd.getNextNumber();
        dcLevel = gd.getNextNumber();
        sigmaX = gd.getNextNumber();
        sigmaY = gd.getNextNumber();
        sigmaZ = gd.getNextNumber();
        Prefs.set("gaussianfilter3d.w", w);
        Prefs.set("gaussianfilter3d.h", h);
        Prefs.set("gaussianfilter3d.d", d);
        Prefs.set("gaussianfilter3d.dclevel", dcLevel);
        Prefs.set("gaussianfilter3d.sigmax", sigmaX);
        Prefs.set("gaussianfilter3d.sigmay", sigmaY);
        Prefs.set("gaussianfilter3d.sigmaz", sigmaZ);
        return true;
    }
}
