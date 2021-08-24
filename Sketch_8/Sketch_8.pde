float [][] sourceArray, outputArray;
int inputHeight = 500; // What we rescale loaded images to
float clow = 2; // parameters for CannyEdge detection
float chigh = 6;
float sigma = 15;

PImage inputImage, outputImage, depthImage, normalMapImage;
boolean colorMapping = true;

float[][] differenceImage;

/*
* Extract the selected color channel (1 = red, 2 = green, 3 = blue) from the given image.
*/
PImage selectChannel(PImage img, int channelNumber) {

  PImage res = createImage(img.width, img.height, RGB);
  img.loadPixels();

  for (int y = 0; y < img.height; ++y){ 
    for (int x = 0; x < img.width; ++x) {
      float r = red(img.pixels[x+y*img.width]);
      float g = green(img.pixels[x+y*img.width]);
      float b = blue(img.pixels[x+y*img.width]);
      switch (channelNumber) {
      case 0: 
        res.pixels[x+y*img.width] = color(r, r, r);
        break;
      case 1: 
        res.pixels[x+y*img.width] = color(g, g, g);
        break;
      case 2: 
        res.pixels[x+y*img.width] = color(b, b, b);
        break;
      }
    }
  }
  res.updatePixels();

  return res;
}

/*
* Given a depth image, return a new image with all spots where the depth value is equal
* to the target depth. The depth value in the depth image is coded as the pixel brightness.
* Found locations are marked in red.
*/
PImage markDepth(PImage depth, int targetDepth) {

  // TODO: Create a new image with the same size as depth. Then iterate depth and check the
  // brightness. If it matches the targetDepth, mark it red, otherwise put a black pixel.
  // HINT: remember PImage.loadPixels() and PImage.updatePixels().
  
  int h = depth.height;
  int w = depth.width;
  PImage outp = new PImage(w,h);
  
  for(int i = 0; i < outp.pixels.length; i++){
    if(int(brightness(outp.pixels[i])) == targetDepth){
      outp.pixels[i] = color(255,0,0);
    }
    else{
      outp.pixels[i] = color(0,0,0);
    }
  }
  outp.updatePixels();
  return outp;
}

/*
* Maps the given original color to an orange/blue hue. 
*/
color colorMap(color originalColor, float thresholdBrightness)
{
  // TODO: Coompare the brightness of the original color to the given threshold brightness.
  // If it's smaller, return an orange-ish hue by adding the threshold to the red and green channel.
  // Otherwise, subtract from the green and blue channel. For the green channel use half the 
  // threshold brightness.
  
  if(thresholdBrightness < 0){
    return color(red(originalColor) + thresholdBrightness, green(originalColor) + thresholdBrightness, blue(originalColor));
  }
  else{
    return color(red(originalColor) - thresholdBrightness, green(originalColor) - 0.5 * thresholdBrightness, blue(originalColor));
  }
}

/*
* Returns the difference of an image with its blurred version
*/
float[][] createBlurDiff(PImage depth)
{
  // TODO: Copy the depth image, and filter it using the BLUR filter with sigma as a parameter.
  // Then compute the difference between the depth image and the blurred depth image in each pixel.
  // Do not do a channel-wise difference bust subtract brightnesses. Write the result to a new
  // float[][] array of appropriate size and return it.
  
  float[][] resultDifference = new float[depthImage.width][depthImage.height];
  PImage blurred = depth.copy();
  blurred.filter(BLUR, sigma);
  
  for (int i=0; i<depthImage.width; i++) {
    for (int k=0; k<depthImage.height; k++) {
      float blur_brightness = brightness( blurred.get(i, k));
      float depth_brightness = brightness( depth.get(i, k));
      resultDifference[i][k] = depth_brightness - blur_brightness;
    }
  }
  return resultDifference;
}

/*
* Expects a difference image out of createBlurDiff and the original image
*/
PImage unsharpMask(float[][] blurredDiff, PImage originalImage, PImage depthImage) {
  // TODO: Create an empty resultImage with the same size as the depthImage.
  // Iterate the original image and modulate the color from the original image using colorMap()
  // if the flag colorMapping is true. Otherwise, subtract the difference from each channel and
  // write the result back to the image for a grey shadow effect.
  
  PImage result = new PImage(depthImage.width, depthImage.height);
  
  for (int i=0; i < depthImage.width; i++) {
    for (int k=0; k < depthImage.height; k++) {
      color original_pixel = originalImage.get(i,k);
      if (colorMapping){
        result.set(i, k, colorMap(originalImage.get(i,k), blurredDiff[i][k]));
      } 
      else{          
        result.set(i, k, color(red(original_pixel) - blurredDiff[i][k], green(original_pixel) - blurredDiff[i][k], blue(original_pixel) - blurredDiff[i][k]));
      }
    }
  }
  return result;

}

/*
*
*/
PImage markDiscontinuities(PImage img, PImage depth, PImage nmap) {
  
  // TODO: In this function you shall determine discontinuities in the normal and
  // depth images. 
  // 1) Use canny edge detection on the depth image with the parameters clow and chigh
  // 2) Use selectChannel on the normal map to extract the red, green and blue channel separately.
  // 3) Detect edges in the individual channel images of the previous step to find discontinuities
  // 4) Create an empty result image with the same size as the input and iterate it:
  //    * find the minimum value from the three edge detected images
  //    * Get the brightness of the depth image at the location
  //    * Mark the depth discontinuties in red and the normal discontinuities in blue.
  
  PImage edges = createEdgesCanny(depth, clow,chigh);
  PImage red = selectChannel(nmap, 0);
  PImage green = selectChannel(nmap, 1);
  PImage blue = selectChannel(nmap, 2);
  PImage red_edge = createEdgesCanny(red, clow, chigh);
  PImage green_edge = createEdgesCanny(green, clow, chigh);
  PImage blue_edge = createEdgesCanny(blue, clow, chigh);
  PImage result = new PImage(img.width, img.height);

  for (int i = 0; i < img.width; i++) {
    for (int k = 0; k < img.height; k++) {
      float min = min(min(red_edge.get(i, k), green_edge.get(i, k)), blue_edge.get(i, k));
      result.set(i, k, color(255, 255, 255));
      if (edges.get(i, k) < -1) // red
        result.set(i, k, color(255, 0, 0));
      if (min < -1) //blue
        result.set(i, k, color(0, 0, 255));
    }
  }
  return result;

}

/////////////////////////////////////////////////////////////////////////////

PImage createEdgesCanny(PImage img, float low, float high) {

  //create the detector CannyEdgeDetector 
  CannyEdgeDetector detector = new CannyEdgeDetector(); 

  //adjust its parameters as desired 
  detector.setLowThreshold(low); 
  detector.setHighThreshold(high); 

  //apply it to an image 
  detector.setSourceImage(img);
  detector.process(); 
  return detector.getEdgesImage();
}

void setup() { 
  inputImage = loadImage("data/3_dragon.png");
  inputImage.resize(0, inputHeight); // proportional scale to height

  size(500,500);
  surface.setResizable(true);
  surface.setSize(inputImage.width, inputImage.height); 
  frameRate(3);
  
  depthImage = loadImage("data/3_dragon_depth.png");
  depthImage.resize(0, inputHeight); 

  normalMapImage = loadImage("data/3_dragon_normal.png");
  normalMapImage.resize(0, inputHeight); 


  differenceImage = createBlurDiff(depthImage);

  outputImage = inputImage;
}


void draw() {
  image(outputImage, 0, 0);
}

void keyPressed() {
  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {
    outputImage = depthImage;
  }
  if (key=='3') {
    outputImage = normalMapImage;
  }

  if (key=='4') { 
    outputImage = createEdgesCanny(inputImage, clow, chigh);
  }

  if (key=='5') { 
    outputImage = createEdgesCanny(depthImage, clow, chigh);
  }

  if (key=='6') {
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }

  if (key=='7') {

    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
  }

  if (key=='a') {
    chigh -= 0.2;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='s') {
    chigh += 0.2;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='q') {
    clow -= 0.1;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='w') {
    clow += 0.1;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='+') {

    sigma += 1; 
    differenceImage = createBlurDiff(depthImage);
    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
    println("Blur sigma: " + sigma);
  }
  if (key=='-') {

    sigma -= 1; 
    differenceImage = createBlurDiff(depthImage);
    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
    println("Blur sigma: " + sigma);
  }
   if (key=='m') {

    colorMapping = !colorMapping;   
    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
   
  }
  if (key == 'x') {
    save("results/result.png");
  }
  println("Low: " + clow + " High: " + chigh);
}
