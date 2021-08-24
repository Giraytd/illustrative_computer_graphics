PImage inputImage;
PImage outputImage;

float [][] sourceIntensity;

float pointRadius = 2;
int maxPoints = 10000; 
int maxAttempts = 1000000;

boolean computed = false;
ArrayList<Point> computedPoints;

/** TASK
 Your taks is to implement the following functions:
 1) nearestPoint: This function should look at the passed list of points and 
    determine which is closes to the indicated x/y location. Use the naive,
    slow algorithm.
 2) movePointsUnweighted: Here you implement the slow voronoi method which does
    not look at the input image at all, the goal is to see the even distribution
 3) movePoints: Make this an extended version of movePointsUnweighted, in which 
    you implement getting weights for points based on the image intensity.
 5) renderVoronoi: In this function we will render the view onto the 3D cones.
    Test this individually before moving on to nr. 6! The result should be a Voronoi
    diagram of the given point set.
 6) movePointsAccelerated: This function uses renderVoronoi() to quickly get an
    image of the voronoi diagram. Then it uses that information for quick movement. 
 
 HINT: The goal is to compute a list of points, rendering it to an image is done by
       createOutputImage, which is already implemented.
       
 HINT: Do not forget to call voronoiInitialize() before moving points, to clear the
       previous movement information. use Point.voronoiMove() after computing everything.
*/


// The Point class provides basic storage of 2D points and 3D points with a radius  

class Point {
  float x, y, r; // R is used for the radius of a point
  float tx, ty, n;

  Point(float px, float py) {
    x = px; 
    y = py; 
    r = 1; //2D case: Default radius to 1, so all are uniform
  }

  Point(float px, float py, float pr) {
    x = px; 
    y = py; 
    r = pr;
  }

  Point (Point p) {
    x = p.x; 
    y = p.y;
    r = p.r;
  }

  // Computes euclidian distance between this point and another coordinate pair in the XY plane
  float distXY(float px, float py) {
    return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }

  void voronoiInitialize() { 
    tx = ty = n = 0;
  }
  void voronoiMove() { 
    x = tx/n; 
    y = ty/n;
    x = constrain(x, 20, width-20);
    y = constrain(y, 20, height-20);
  }
}


/*
 * Creates an Pimage form a 2D array of float intensity values. 
 */
PImage createOutputImage(float [][] outputIntensity) {

  int w = outputIntensity.length;
  int h = outputIntensity[0].length;

  outputImage = createImage(w, h, RGB);
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      float val = 255.0 * (1.0 - outputIntensity[x][y]);
      outputImage.pixels[x+y*w] = color(val, val, val);
    }
  }

  return outputImage;
}


/*
 * Takes a PImage sourceImage and converts it to greyscale intensity array with values in [0.0 - 1.0]
 */
void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  sourceImage.loadPixels();
  for (int y=0; y<sourceImage.height; y++)
    for (int x = 0; x < sourceImage.width; x++) 
      intensityArray[x][y] = brightness(sourceImage.pixels[x+y*sourceImage.width]) / 255.0;
}

/*
 * Computes the intensity in the rectangle given by (x1, y1) and (x2, y2), reading data from intensityArray
 * The average intensity is the sum of all intensity values, divided by the area visited
 */

float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] intensityArray) {

  int w = intensityArray.length;
  int h = intensityArray[0].length;
  x1 = max(0, min(w, x1));
  x2 = max(0, min(w, x2));
  y1 = max(0, min(h, y1));
  y2 = max(0, min(h, y2));

  float intensitySum = 0;

  for (int y = y1; y < y2; ++y) {
    for (int x = x1; x < x2; ++x) { 
      intensitySum += intensityArray[x][y];
    }
  }

  return intensitySum / ((x2-x1)*(y2-y1));
}

/*
 * Insert a point into the point List, checking in the intensityArray if the average intensity around the selected area is ok 
 */
boolean insertPoint(float [][] intensityArray, ArrayList pointList, float x, float y) {

  int px = (int)round(x);
  int py = (int)round(y);

  float avgIntensity = getAvgIntensity(px-2, py-2, px+2, py+2, intensityArray);
  if (random(0, 1) > avgIntensity) {
    pointList.add(new Point(x, y, pointRadius));
    return true;
  }

  return false;
}


/*
 * Attempts to place numPoints many points into the picture and adds them to pointList
 */
ArrayList createPoints() {

  ArrayList<Point> pointList = new ArrayList(maxPoints);

  int points = 0;
  int attempts = 0;
  do {
    float positionX = random(0, width - 1);
    float positionY = random(0, height-1);
    boolean accepted = insertPoint(sourceIntensity, pointList, positionX, positionY);
    if (accepted) {
      points++;
    }
    attempts++;
  } while ((points < maxPoints) && (attempts < maxAttempts));

  return pointList;
}

int nearestPoint(float x, float y, ArrayList<Point> pointList) {

  int ind = -1;
  
  // TODO: return the index of the nearest point to (x,y) in pointList.
  
  float minDist = 99999999.9;
  float dist = 0.0;
  
  for(int i = 0; i < pointList.size();i++){
    dist = pointList.get(i).distXY(x,y);
    if(dist < minDist){
      minDist = dist;
      ind = i;
    }
  }

  return ind;
}

void movePointsUnweighted(ArrayList<Point> pointList) {

  float dx = 3;
  float dy = 3;

  for (Point p : pointList) {
    p.voronoiInitialize();
  }

  // TODO iterate the image in x and y direction, stepping by dx and dy respectively.
  // for each location, get the nearest point and add the voronoi information to it,
  // as shown in the slides (tx, ty and n). Finally move all points according to the 
  // information.

  int i_width = inputImage.width;
  int i_height = inputImage.height;
  int loc = 0;
  
  for(int y = 0; y < i_height; y += dy){
    for(int x = 0; x < i_width; x += dx){
      loc = nearestPoint(x,y,pointList);
      pointList.get(loc).tx += x;
      pointList.get(loc).ty += y;
      pointList.get(loc).n++;


    }
  }

  for(Point p : pointList){
    p.voronoiMove();
  }



  // End TODO

  println(" ... Moved");
}


void movePoints(ArrayList<Point> pointList) {

  float dx = 3;
  float dy = 3;

  for (Point p : pointList) {
    p.voronoiInitialize();
  }

  // TODO: As in movePointsUnweighted, iterate the image but this time use the
  // formula for weighted voronoi. I.e include the image intensity in the movement.

  int i_width = inputImage.width;
  int i_height = inputImage.height;
  int loc = 0;
  float vweight;
  
  for(int y = 0; y < i_height; y += dy){
    for(int x = 0; x < i_width; x += dx){
      //vweight = 1.0 - map(brightness(inputImage.get(x,y)), 0,255,0,1);
      vweight = 1.0 - sourceIntensity[x][y];
      loc = nearestPoint(x,y,pointList);
      pointList.get(loc).tx += x*vweight;
      pointList.get(loc).ty += y*vweight;
      pointList.get(loc).n += vweight;


    }
  }
  
  for(Point p : pointList){
    p.voronoiMove();
  }




  println(" ... Moved");
}

/*
 * Gets a list of points and renders them into a PImage
 */
PImage createOutputImage(ArrayList<Point> pointList) {

  PGraphics pointGraphics = createGraphics(width, height);

  pointGraphics.beginDraw();
  pointGraphics.background(255);
  pointGraphics.fill(0);
  for (int i=0; i < pointList.size(); i++) {
    Point p = pointList.get(i);
    pointGraphics.ellipse(p.x, p.y, 2*p.r, 2*p.r); // Draw an ellipse with the major axes being twice the radius
  }
  pointGraphics.endDraw();

  return pointGraphics; // PGraphics is a PImage with extra drawing stuff tacked on.
}

PImage createOutputImageFiltered(ArrayList<Point> pointList) {

  PGraphics pg = createGraphics(width, height);

  pg.beginDraw();
  pg.background(255);
  pg.fill(0);
  for (int i=0; i<pointList.size(); i++) {
    Point p = (Point)pointList.get(i);
    if (sourceIntensity[(int)p.x][(int)p.y] < 0.95) { // remove points which are on a totally white area
      pg.ellipse(p.x, p.y, 2*p.r, 2*p.r);
    }
  }
  pg.endDraw();

  return pg;
}

////////////////// FAST VORONOI ///////////////////////////

color intToColor(int i) {  // convert integer to color values
  int r =  (i % 64);
  int g = ((i>>6) % 64);
  int b = ((i>>12) % 64);
  return color(r, g, b);
}

int colorToInt(color c) {  // convert color to an integer value 
  int r = (int)(c>> 16 & 0xFF);
  int g = (int)(c>> 8  & 0xFF);
  int b = (int)(c      & 0xFF);
  return r + (g<<6) + (b<<12);
}

void cone(PGraphics canvas, float x, float y, float radius, float depth, int nodes, color cone_color) {
  canvas.beginShape(TRIANGLE_FAN);
  canvas.fill(cone_color);
  canvas.vertex(x, y, 1);
  for (float angle = 0.0; angle <= 2.0 * PI + 0.1; angle += (2.0 * PI) / float(nodes)) {
    float cx = (float)(radius * cos(angle)) + x;
    float cy = (float)(radius * sin(angle)) + y;
    canvas.vertex(cx, cy, -depth);
  }
  canvas.endShape();
}

PImage renderVoronoi(ArrayList<Point> points, boolean drawCentroids, boolean indexColors) { //<>//
  PGraphics canvas = createGraphics(width, height, P3D);
  canvas.beginDraw();
  canvas.noStroke();
  canvas.background(127);
  canvas.ortho(-width/2, width/2, -height/2, height/2, -1, 1000);
  canvas.camera(width/2, height/2, 300, width/2, height/2, 0, 0, 1, 0);
  
  // TODO: 
  // Iterate all points in the list and generate a color from its index in the list if
  // indexColors is true. Use a random color otherwise. Place a cone with 32 nodes and the
  // generated color. WHat is a reasonable value for the cone's radius and depth?
  // For debugging purposes, if the flag drawCentroids is true, draw small points on top of
  // the voronoi diagram in the location of the generating points. Finally, return the
  // rendered image. 
  // HINT: For some reason, the bug that PGraphics.get() clears the PGraphics object
  // occurs here on my machine. If you get nothing out of this function, try this:
  //
  // PImage result = canvas.get();
  // canvas.endDraw();
  // return result;
  
  color cur_color;

  for(int i = 0; i < points.size(); i++){
    
    Point p = points.get(i);
    
    if(indexColors){
      cur_color = intToColor(i);
    }
    else{
      cur_color = color(random(0,255), random(0,255),random(0,255));
    }
        
    // Size of the cones should be large enough so that entire image is covered and partitined
    cone(canvas, p.x, p.y, 500, 500, 32, cur_color);
  }
    if(drawCentroids){
      for(int i = 0; i < points.size(); i++){
        Point p = points.get(i);
        canvas.stroke(0);
        canvas.fill(0);
        canvas.ellipse(p.x,p.y,p.r,p.r);
    }
  }
   //<>//
  
  return canvas;
}

void movePointsAccelerated(ArrayList<Point> pointList) {
  // TODO: Implement fast Voronoi point movement, with weights using a rendered
  // voronoi diagram. Beware not to draw the generating points here! Iterate 
  // over the voronoi diagram image and inspect each pixel. Use colorToInt 
  // to recover the points index from the image, then update the corresponding 
  // point in the list. 
 
 PImage img = renderVoronoi(pointList,false,true);
 float wght;
 
 for (Point p : pointList) {
    p.voronoiInitialize();
  }

  for(int y = 0; y < inputImage.height; y++){
      for(int x = 0; x < inputImage.width; x++){
              int i = colorToInt(img.get(x,y));
        Point p = pointList.get(i);
        wght = 1.0 - sourceIntensity[x][y];
        
        p.tx += x * wght;
        p.ty += y * wght;
        p.n += wght;

        
    }
  }

   for(Point p : pointList){
    p.voronoiMove();
  }

}

void settings() {
  inputImage = loadImage("data/stone_figure.png");
  inputImage.resize(0, 1000);
  size(inputImage.width, inputImage.height, P3D); // this is now the actual size
  noSmooth();
}

void setup() {
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
}

void draw() {
  image(outputImage, 0, 0);
}

// HINT: First, use key 2 to compute points, then have key 3 for unweighted and 4 for weighted voronoi movement.

void keyPressed() {
  if (key=='s') save("results/result.png");

  if (key=='1') {
    computedPoints.clear();
    outputImage = inputImage;
  }
  if (key=='2') {
    computedPoints = createPoints();
    computed = true;
    outputImage = createOutputImage(computedPoints);
  }
  if (key=='3') {
    if (!computed) {
      computedPoints = createPoints();
      computed = true;
    }
    movePointsUnweighted(computedPoints);
    outputImage = createOutputImage(computedPoints);
  }
  if (key=='4') {
    if (!computed) {
      computedPoints = createPoints();
      computed = true;
    }
    movePoints(computedPoints);
    outputImage = createOutputImageFiltered(computedPoints);
  }
  
  if (key=='5') {
    if (!computed) {
      computedPoints = createPoints();
      computed = true;
    }
    movePointsAccelerated(computedPoints);
    outputImage = createOutputImageFiltered(computedPoints);
  }
  
  if (key=='v') {
    if (!computed) {
      computedPoints = createPoints();
      computed = true;
    }
    PImage voronoi_img = renderVoronoi(computedPoints, true, false);
    outputImage = voronoi_img;
  }

  if (key=='+') {
    maxPoints *= 1.3;
    ArrayList pointList = createPoints();
    outputImage = createOutputImage(pointList);
  } 
  if (key=='-') {
    maxPoints /= 1.3;
    ArrayList pointList = createPoints();
    outputImage = createOutputImage(pointList);
  }
}
