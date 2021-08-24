// Sketch 1-4 Digital Screening
 
float [][] sourceIntensity;
float [][] outputIntensity;
float [][] ditherKernel;

PImage inputImage;  // Loaded input image, do not alter!
PImage outputImage; // Put your result image in here, so it gets displayed
PImage ditherKernelImage;

final int maskX = 8;       // Fixed values for characters
final int maskY = 14;

PFont font;
PImage letterArray[][];
final int letterIntensityLevels = 10;

/***************************************************************************
TASK:

This sketch consists of two independant parts: 

First, you should implement the "artistic" screening, for which you load a 
dither kernel from a file. For this you implement the function 
dither_screening (see below), associated with key 2.

Second, you will tackle text screening in dither_screening_characters, which 
is more tricky.

****************************************************************************/


/*
 * Converts an intensity array to a PImage (RGB)
 */
PImage convertIntensityToPImage(float [][] intensityArrayImg) {
  
    int w = intensityArrayImg.length;
    int h = intensityArrayImg[0].length;

    PImage convertedImage = createImage(w, h, RGB);
    for (int y = 0; y < h; ++y)
      for (int x = 0; x < w; ++x) {
        float val = 255.0 * intensityArrayImg[x][y]; //<>//
        convertedImage.pixels[x+y*w] = color(val,val,val);
    }
    
    return convertedImage;
}

/*
 * Initializes the passed float array with the corresponding intensity values of the source image.
 * intensityArray is passed BY REFERENCE so changes will be made to it.
 */

void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  // PImage.pixels is only filled with valid data after loadPixels() is called
  // After PImage pixels is changed, you must call updatePixels() for the changes
  // to have effect.
  sourceImage.loadPixels();
  for (int y = 0; y < sourceImage.height; ++y) {
    for (int x = 0; x < sourceImage.width; ++x) {
		  intensityArray[x][y] = brightness(sourceImage.pixels[x + y*sourceImage.width]) / 255.0;
    }
  }
}

/*
Computes the average intensity of a rectangle with the top left point (x1, y1) and lower right point (x2, y2)
*/
float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] source) {

  int w = source.length;
  int h = source[0].length;
  // ensure within image bounds
  x1 = max(0,min(w,x1));
  x2 = max(0,min(w,x2));
  y1 = max(0,min(h,y1));
  y2 = max(0,min(h,y2));
  float r = 0;
  
  // sum up pixels in rectangle 
  for (int y = y1; y < y2; ++y) {
    for (int x = x1; x < x2; ++x) { 
       r += source[x][y];
    }
  }
 
  // average is sum divided by area
  return r / ((x2 - x1) * (y2 - y1));
}

/*
Create an array of font images.
*/
void createFontImages() {
  
  PGraphics g = createGraphics(maskX, maskY); 
  letterArray = new PImage[10][26];
  font = loadFont("AbadiMT-CondensedExtraBold-20.vlw");
 
  g.beginDraw();
  for (int i = 0; i < letterIntensityLevels; ++i) {
    int mapSize = 5 + 2 * i;
    for (int k = 0; k < 26; ++k) {
      g.textFont(font, mapSize - 2); 
      g.background(255);
      g.stroke(0); 
      g.fill(0);
      g.textAlign(CENTER,CENTER);
      g.text((char)('A' + k), maskX / 2 - 1, maskY / 2 - 2);
      letterArray[i][k]=g.get(0, 0, maskX, maskY);
    }
  }
  g.endDraw();
}

///////////////////////////////////////////////////////////////////
// Your task below this line
///////////////////////////////////////////////////////////////////

void dither_screening(float[][] source, float[][] out, float [][] kernel) {
  
  // TODO: Iterate the image and apply the dither kernel to the image
  // For this purpose, determine a pixel of the dither kernel to be used as a threshold.
  // The dither kernel should be "tiled" over the image and repeat over and over.
  // Use 1-kernelValue as a threshold for S.
  
  int xmod, ymod;
  float s, threshold;
  
  for(int x = 0; x < source.length; x++){
    for(int y = 0; y < source[0].length; y++){
      
       xmod = x % kernel.length;
       ymod = y % kernel[0].length;
       s = source[x][y];
       threshold = 1 - kernel[xmod][ymod];

      if ((s < threshold))
        out[x][y] = 0;
      else
        out[x][y] = 1;
      
    }
  }

}

void dither_screening_characters(float[][] source, float[][] output) {

		// TODO: iterate the image in steps of maskX in x and maskY in y direction, dividing the image into rectangles.
		// Compute the average intensity of the current rectangle and select a random character from the letter array.
		// Map the intensity value you computed into the range [0, letterIntensityLevels - 1] and use this to pick the
		// appropriate letter. Finally, copy the selected letter into the output image, to fill the current rectangle.

		for (int x = 0; x < source.length; x += this.maskX) {
			for (int y = 0; y < source[0].length; y += this.maskY) {
				//print("x: " + x + " y: " + y + "\n");
				float avgIntensity = getAvgIntensity(x, y, x + maskX, y + maskY, source);
				int randomLetter =int(random(0, 25));
				int mappedIntensity =int((avgIntensity) * (letterIntensityLevels - 1));

				PImage lettersImage = letterArray[mappedIntensity][randomLetter];
				float[][] intensityArray = new float[lettersImage.width][lettersImage.height];

				createIntensityVal(lettersImage, intensityArray);

				for (int x1 = 0; x1 < intensityArray.length; x1++) {
					for (int y1 = 0; y1 < intensityArray[0].length; y1++) {
						if ((x1 + x) < output.length && (y1 + y) < output[0].length) {
							output[x1 + x][y1 + y] = intensityArray[x1][y1];
						}
					}
				}
			}
		}
}
  
/*
 * Setup gets called ONCE at the beginning of the sketch. Load images here, size your window etc.
 * If you want to size your window according to the input image size, use settings().
 */

void settings() {
  inputImage = loadImage("data/flower.png");
  ditherKernelImage = loadImage("data/kernels/4.png");
  size(inputImage.width, inputImage.height); // this is now the actual size
} 

void setup() {
  surface.setResizable(false);
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  outputIntensity = new float [inputImage.width][inputImage.height];
  
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
  
  int ditherKernelSize = 16;
  ditherKernel = new float [ditherKernelSize][ditherKernelSize];
  ditherKernelImage.resize(ditherKernelSize, ditherKernelSize);
  createIntensityVal(ditherKernelImage, ditherKernel);
  
  createFontImages();
}

/*
 * In this function, outputImage gets drawn to the window. Code in here gets executed EVERY FRAME
 * so be careful what you put here. You should only compute the dithering once, hence don't put
 * any calls to it here. 
 */
void draw() {

  // Displays the image at its actual size at point (0,0)
  image(outputImage, 0, 0); 
}

/*
 * This function gets called when a key is pressed. Use it to control your program and change parameters
 * via key input. 
 */

void keyPressed() {
  if (key=='1') {
    float rotate = 0.f;
    outputImage = inputImage;
  }
  if (key=='2') {
    createIntensityVal(inputImage, sourceIntensity);
    dither_screening(sourceIntensity, outputIntensity, ditherKernel);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='3') {
      createIntensityVal(inputImage, sourceIntensity);
      dither_screening_characters(sourceIntensity, outputIntensity);
      outputImage = convertIntensityToPImage(outputIntensity);
  }
  
  if (key == 's') save("output.png");
}
