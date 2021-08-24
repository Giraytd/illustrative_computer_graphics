int iheight = 500;

boolean variableOutput = true;

PImage inp, outp, depth, nmap, contourImg; 

color black = color(0);
color white = color(255);

void setup() { 
  
  inp = loadImage(sketchPath("data/sphere.png"));
  depth = loadImage(sketchPath("data/sphere_depth.png"));
  nmap = loadImage(sketchPath("data/sphere_normals.png"));

  inp.resize(0, iheight); // proportional scale to height=500
  depth.resize(0, iheight); // proportional scale to height=500
  nmap.resize(0, iheight); // proportional scale to height=500

  size(10,10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);
  frameRate(3);
}

void draw() {
  contourImg = computeContourLines(nmap);
  image(contourImg, 0, 0);
} //<>//

PVector rgbToNormal(color c) {
  // TODO: Extract the normal vector from the given color by mapping
  // RGB to XYZ components of the vector. Since the normal can point
  // into a negative direction but color components are only in 
  // [0; 255], you should subtract from 127.
  // Normalize the vector too.
  PVector r = new PVector(127 - red(c), 127 - green(c), 127 - blue(c));
  return r.normalize();
}

PImage computeContourLines(PImage img) {
  // TODO: Create a new image, and set up a view vecor (0, 0, 1). compute epison from the 
  // mouse position in the window, using mouseX and width. Remember that these are 
  // integers and division should yield a float! Then iterate the entire image and extract
  // the normal in each pixel. Compute the dot product with the view vector and compare
  // it to epsilon. Set the output color to white or black, depending on the result.   
  int w = img.width;
  int h = img.height;
  
  PImage rim = new PImage(w, h);
  PVector viewVector = new PVector(0, 0, 1);
  // float epsilon = float(mouseX) / w;
  float epsilon = 0.75f;  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int pos = x + y * w;
      float nv = viewVector.dot(rgbToNormal(img.pixels[pos]));
      if (abs(nv) < epsilon) {
        rim.pixels[pos] = black;
      } else {
        rim.pixels[pos] = white;
      }
    }
  }
  return rim;
}
