class Stroke {
  ArrayList<PVector> pointList;
  float strokeWidth;
  color strokeColor;
  final int colorMaxDiff = 50;

  // Strokes cannot be default constructed (no arguments): A position is always present!
  Stroke(PVector pp, float pwid, color pcol) {
    strokeColor = pcol; 
    strokeWidth = pwid;
    pointList = new ArrayList<PVector>();
    pointList.add(pp);
  }

  void addPoint(PVector pp) {
    pointList.add(pp);
  }

  void addPoint(float px, float py) {
    pointList.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    strokeWidth = pr;
  }

  void setColor(color pcol) {
    strokeColor = pcol;
  }


  void draw() {
    stroke(strokeColor);
    strokeWeight(strokeWidth); 
    // TODO; Draw all points in pointList using the line() function of processing.
    // You should connect adjacent points with a line so you get a pattern like this:
    // o---o---o---o- ... -o
    // where each "o" is a control point and --- the line between them.
    for(int i = 0; i < pointList.size() - 1 ; i++)
    {
      line(pointList.get(i).x, pointList.get(i).y, pointList.get(i+1).x, pointList.get(i+1).y);
    }

  }

  void movePerpendicuarToGradient(int steps, PImage inp) {
    // TODO: call growStroke exactly step times in order to enlarge the stroke.
    // If growStroke returns (-1, -1), i.e. it has found no gradient, abort the stroke.
    // Keep track of the color at the start of the stroke and if the error exceeds 
    // colorMaxDiff, also abort the stroke.
    
    // OPTIONAL: Check the angle between the last movement and the new gradient. If it
    // is less than 45° or 90° (try both) you should stop the stroke here.
    // (This was mentioned too early in the exercise, controlling the angle will
    // only be required in sketch 7.)
    
    int c = 0;
    boolean abort = false;
    PVector pos_start = pointList.get(0);
    color clr = inp.get(int(pos_start.x),int(pos_start.y));

    while(c < steps && abort == false)
    {
      PVector res = growStroke(inp);
      if(res.x == -1 && res.y == -1)
      {
        abort=true;
      }
      else
      {
        color current_color=inp.get(int(res.x),int(res.y));
        float dif_c = sqrt(pow(red(clr)-red(current_color),2)+
                           pow(blue(clr)-blue(current_color),2)+
                           pow(green(clr)-green(current_color),2));
        
        // Check max color difference for abort
        if(dif_c >= colorMaxDiff)
        {
          abort=true;
        }
      }
      c++;
    }
    
    // Abort the stroke
    if(abort){
      pointList.clear();
    }


  }


  PVector growStroke(PImage inp) {
    // TODO: Extend te stroke by figuring out where the next point shall be located
    // 1) get the last point of this stroke from pointList
    // 2) Compute the local gradient at the curent location. Implement a sobel operator for this. You can use 
    //    brightness(inp.pixels[x + y * w]) to get the brightness easily at a point x, y.
    // 3) Move orthogonally to the gradient and movy by stepSize to a new position. Add this to the point list.
    // 4) Return the location you find or (-1, -1) if you have gradient of magnitude 0. 

    int pl_size = pointList.size();
    PVector last = pointList.get(pl_size - 1);

    int w = inp.width;
    int h = inp.height;
    
    int x = int(last.x);
    int y = int(last.y);
    
    if(x < 0 || x >= w - 1 || y < 0 || y >= h - 1){
      return new PVector(-1, -1);
    }
    
    float gx = 0, gy = 0;
    // Gradients
    float[] grad_x = new float[]{-1, 0, 1, -2, 0, 2, -1, 0, 1};
    float[] grad_y = new float[]{-1, -2, -1, 0, 0, 0, 1, 2, 1};
    
    if(x > 0 && x < w - 1 && y > 0 && y < h - 1){
      gx = grad_x[0] * brightness( inp.pixels[x - 1 + (y - 1) * w] ) +
            grad_x[1] * brightness( inp.pixels[x + (y - 1) * w] ) +
            grad_x[2] * brightness( inp.pixels[x + 1 + (y - 1) * w] ) +
            grad_x[3] * brightness( inp.pixels[x - 1 + y * w] ) +
            grad_x[4] * brightness( inp.pixels[x + y * w] ) +
            grad_x[5] * brightness( inp.pixels[x + 1 + y * w] ) +
            grad_x[6] * brightness( inp.pixels[x - 1 + (y + 1) * w] ) +
            grad_x[7] * brightness( inp.pixels[x + (y + 1) * w] ) +
            grad_x[8] * brightness( inp.pixels[x + 1 + (y + 1) * w] );
      
    }
    
    if(x > 0 && x < w - 1 && y > 0 && y < h - 1){
      gy = grad_y[0] * brightness( inp.pixels[x - 1 + (y - 1) * w] ) +
            grad_y[1] * brightness( inp.pixels[x + (y - 1) * w] ) +
            grad_y[2] * brightness( inp.pixels[x + 1 + (y - 1) * w] ) +
            grad_y[3] * brightness( inp.pixels[x - 1 + y * w] ) +
            grad_y[4] * brightness( inp.pixels[x + y * w] ) +
            grad_y[5] * brightness( inp.pixels[x + 1 + y * w] ) +
            grad_y[6] * brightness( inp.pixels[x - 1 + (y + 1) * w] ) +
            grad_y[7] * brightness( inp.pixels[x + (y + 1) * w] ) +
            grad_y[8] * brightness( inp.pixels[x + 1 + (y + 1) * w] );
    }

    float dx = x + ((gy * 2) / sqrt(gx * gx + gy * gy));
    float dy = y - ((gx * 2) / sqrt(gx * gx + gy * gy));
    PVector res = new PVector(dx,dy);
    pointList.add(res);

  return res;
  }
}
