int iheight = 500;
float clow = 4;
float chigh = 14;

PImage input, output, depth, nmap, background;  

PImage selectChannel(PImage img, int no) {

  PImage res = createImage(img.width, img.height, RGB); 
  for (int y = 0; y < img.height; ++y) 
    for (int x = 0; x < img.width; ++x) {
      float r = red(img.pixels[x+y*img.width]);
      float g = green(img.pixels[x+y*img.width]);
      float b = blue(img.pixels[x+y*img.width]);
      switch (no) {
      case 0: 
        res.pixels[x+y*img.width] = color(r);
        break;
      case 1: 
        res.pixels[x+y*img.width] = color(g);
        break;
      case 2: 
        res.pixels[x+y*img.width] = color(b);
        break;
      }
    }  
  return res;
}

color quantizeColor(color c) {
  // TODO: Quantize the given color based on brightness 
  // HINT: have four colors and map more colors to dark then bright.
  // HINT: Use most of your color space for black and grey, very little for white.
  float b = brightness(c);
  if (b == 255) {
    return color(255, 0);
  }
  if (b > 210) {
    return color(255, 255);
  } else if (b > 150 && b <= 210) {
    return color(200, 0);
  } else {
    return color(0, 50);
  }
}

PImage toonShade(PImage img, PImage depth, PImage nmap) {

  // TODO:
  // 1) Create a result image
  // 2) Quantize the input image to a temporary image
  // 3) Blend the temporary image onto the background using PImage.blend(...) with mode BLEND
  // 4) Generate an outline from the depth image and use PImage.filter(ERODE) to thicken it
  // 5) Determine the normal discontinuities as in the previous sketch and paint them onto the image.
  // 6) Paint the lines onto the blended image from step 3 by iterating over the image and checking
  //    for black pixels.
  int w = img.width;
  int h = img.height;
  
  PImage tmp =  createImage(w, h, ARGB); 
  img.loadPixels();
  tmp.loadPixels();
  for (int i=0; i < w * h; i++) {
    tmp.pixels[i] = quantizeColor(img.pixels[i]);
  }
  tmp.updatePixels();
  background.blend(tmp, 0, 0, w, h, 0, 0, w, h, BLEND);

  PImage outlines = createEdgesCanny(depth, 4, 15);
  outlines.filter(ERODE);
  PImage edges = createEdgesCanny(selectChannel(nmap, 0), 4, 15);
  PImage greenEdges = createEdgesCanny(selectChannel(nmap, 1), 4, 15);
  PImage blueEdges = createEdgesCanny(selectChannel(nmap, 2), 4, 15);
  edges.blend(greenEdges, 0, 0, w, h, 0, 0, w, h, DARKEST);
  edges.blend(blueEdges, 0, 0, w, h, 0, 0, w, h, DARKEST);
  outlines.blend(edges, 0, 0, w, h, 0, 0, w, h, DARKEST);

  for (int i=0; i < w * h; i++) {
    if(outlines.pixels[i] == color(0)) {
           background.pixels[i] = color(0);
    }
  }
  return background;
}

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

  input = loadImage("dragon.png");
  depth = loadImage("dragon_depth.png");
  nmap = loadImage("dragon_normal.png");
  background = loadImage("background.png");

  input.resize(0, iheight);
  depth.resize(0, iheight);
  nmap.resize(0, iheight);
  background.resize(input.width, input.height);
  size(500, 500);
  surface.setResizable(true);
  surface.setSize(input.width, input.height);
  frameRate(3);

  output = toonShade(input, depth, nmap);
}

void draw() {
  image(output, 0, 0);
}

void keyPressed() {
  if (key=='1') output = input;
  if (key=='2') output = depth;
  if (key=='3') output = nmap;   
  if (key=='4') output = createEdgesCanny(input, 4, 14);
  if (key=='5') output = createEdgesCanny(depth, 4, 14);
  if (key=='6') output = toonShade(input, depth, nmap);

  if (key=='a') {
    chigh -= 0.2;
    output = toonShade(input, depth, nmap);
  }
  if (key=='s') {
    chigh += 0.2;
    output = toonShade(input, depth, nmap);
  }
  if (key=='q') {
    clow -= 0.1;
    output = toonShade(input, depth, nmap);
  }
  if (key=='w') {
    clow += 0.1;
    output = toonShade(input, depth, nmap);
  }
  if (key=='x') {
    save("results/toon.png");
  }
  println("Low: " + clow + " High: " + chigh);
}
