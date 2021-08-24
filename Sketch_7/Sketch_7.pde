PImage inp, blurred, texture;
ArrayList<Stroke> strokes;
int mode = 0;
float lineWidth = 15;
float drawAlpha = 30;

boolean strokeDebug = false;
boolean startOnWhite = true;

float computeColorImpact(Stroke s, PImage ref) {
  // TODO: For a given stroke, acquire its points and sum the color error created at each point.
  // return the sum divided by the stroke length, to provide a measure o a strokes quality.
  // You only need to sample one pixel, not a region. Compute the error using the euclidian 
  // distance of the colors: sqrt((r_1 - r_2)^2 + (g_1 - g_2)^2 + (b_1 - b_2)^2)
  // you can use inp.get() for the reference color and get() alone to access the visible
  // canvas in the window.
  
  float error = 0;

  for(PVector p : s.strokePoints) {
    color c = ref.get((int)(p.x),(int)(p.y));
    error += sqrt(sq(red(s.strokeColor) - red(c)) + sq(green(s.strokeColor) - green(c)) + sq(blue(s.strokeColor) - blue(c)));
  }
  
  return error;

  }

////////////////////////////////////////////////////////

void createACoupleOfStrokes(int noStrokes) {
  int strokesPainted = 0;
  while (strokesPainted < noStrokes) {
    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];
    
    // TODO: Only continue with this stroke when starting on white background of the CANVAS
    // (not the input image!) you can use the function get() for this purpose.
    if(!startOnWhite && ((get(px,py)) != 255 || green(get(px,py)) != 255 || blue(get(px,py)) != 255)){
      break;
    }

    // END TODO
    
    Stroke s = new Stroke(new PVector(px, py), lineWidth, col, texture);
    s.movePerpendicuarToGradient(20, blurred); 

    if (s.getSize() > 3) {
      float strokeError = computeColorImpact(s, inp);
      
      if (strokeError > 50) {
        strokes.add(s);
        s.draw();
        ++strokesPainted;
      }
    }
  }
}

/////////////////////////////////////////////////////////
// draw the stroke at the position of the mouse
// for debugging, color is inverse to image
/////////////////////////////////////////////////////////

void createStrokeAtMousePosition() { 
  background(inp);
  int px = (int)mouseX;
  int py = (int)mouseY;
  color col = inp.pixels[px + py*inp.width];
  Stroke s = new Stroke(new PVector(px, py), lineWidth, 
                   color(255-red(col), 255-green(col), 255-blue(col)),texture);
  s.movePerpendicuarToGradient(20, blurred); 
  s.draw();
}

void createDebugStroke() {
  // HINT: Use this to debug your stroke rendering.
  background(255);
  Stroke s = new Stroke(new PVector(100, 100), 30, color(255, 0, 0), texture);
  s.addPoint(100, 100);
  s.addPoint(200, 100);
  s.addPoint(200, 200);
  s.addPoint(100, 200);
  
  s.draw();
}

/////////////////////////////////////////////////////////

void settings() {
  // inp = loadImage("rampe.png");
  inp = loadImage("data/rampe.png");
  inp.resize(1000,0);
  size(inp.width, inp.height, P3D);
}

void setup() {
  surface.setResizable(false);
  texture = loadImage("data/brush.png");

  strokes = new ArrayList<Stroke>(1000);
  
  blurred = inp.copy();
  blurred.filter(BLUR, lineWidth / 2);
  
  background(255);
  noFill();
  noStroke();
  textureMode(IMAGE);  
}

////////////////////////////////////////////////////////

void draw() {
  if (mode == 0) createACoupleOfStrokes(100);
  if (mode == 1) createStrokeAtMousePosition();
  if (mode == 2) createDebugStroke();
}

////////////////////////////////////////////////////////

void keyPressed() {
  if (key == '0') mode = 0; 
  if (key == '1') mode = 1;
  if (key == '2') mode = 2;
  if (key == 'd') { 
    strokeDebug = !strokeDebug;
    if (strokeDebug) {
      stroke(0);
    } else {
      noStroke();
    }
  }
  if (key == 's') {
    save("results/painting.png");
  }
  if (key == 'w') {
    startOnWhite = !startOnWhite;
  }
  if (key == '-') lineWidth /= 1.5;
  if (key == '+') lineWidth *= 1.5;
}
