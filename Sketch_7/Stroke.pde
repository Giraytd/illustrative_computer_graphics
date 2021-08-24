class Stroke {
  ArrayList<PVector> strokePoints;
  float strokeWidth;
  color strokeColor;
  PImage texi,_texi;
  PVector start;

  Stroke(PVector pp, float pw, color pc, PImage ptexi) {
    strokeColor = pc;
    strokeWidth = pw;
    texi = ptexi;
    start = pp;
    iniTexture();
    strokePoints = new ArrayList<PVector>();
  }

  void addPoint(PVector pp) {
    strokePoints.add(pp);
  }

  void addPoint(float px, float py) {
    strokePoints.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    strokeWidth = pr;
  }
  
  void setColor(color pcol) {
    strokeColor = pcol;
  }
  
  ArrayList<PVector> getPoints() {
    return strokePoints;
  }

  void draw() {

    if (strokePoints.size()<2) return;
    
    float len = getStrokeLength();
    float l=0,x=0,y=0;

    beginShape(QUAD_STRIP);
     texture(_texi); 
     normal(0,0,1); // only for lights
     for (int i = 0; i < strokePoints.size(); ++i) {
       // TODO: Compute the vertices of the quad strip as shown in the lecture. 
       // keep track of the lenght of the stroke drawn so far to map the proper 
       // texture coordinates. Use getOffsetNormal() here to calculate the
       // normal and then have exactly two calls to vertex(x, y, u ,v).
       PVector normal = getOffsetNormal(strokePoints, i);

       x = strokePoints.get(i).x + strokeWidth * normal.x;
       y = strokePoints.get(i).y + strokeWidth * normal.y;
       vertex(x, y, 0, _texi.height * l / (float)len);
       x = strokePoints.get(i).x - strokeWidth * normal.x;
       y = strokePoints.get(i).y - strokeWidth * normal.y;
       vertex(x, y, _texi.width, _texi.height * l / (float)len);
       
       if (i < strokePoints.size() - 1) {
         l += sqrt(sq(strokePoints.get(i).x - strokePoints.get(i+1).x)+sq(strokePoints.get(i).y - strokePoints.get(i+1).y));
       }

     }
    endShape();
  }
  

  float getStrokeLength() {
    float len = 0;
    for (int i = 1;i<strokePoints.size(); i++) {
       PVector p  = strokePoints.get(i);
       PVector pp = strokePoints.get(i-1);
       len += sqrt(sq(pp.x-p.x)+sq(pp.y-p.y));
    }
    return len;
  }
  
  int getSize() {
    return strokePoints.size();
  }
  

  PVector getOffsetNormal(ArrayList<PVector> pointList, int index) {
    
    // TODO: For the point in plist at position index, compute the
    // offset normal as discussed in the lecture. Handle the following cases:
    // 1) Index is out of bounds
    // 2) First or last point in the point list
    // 3) Indicated point has neighbors
    // You can use PVector.normalize() and PVector.cross() for your computations
    // Beware that the change the Pvector and you should create a new one in
    // each case.
    
    PVector np,vp,vs,ns;
    PVector z = new PVector(0f, 0f, 1f);
    PVector p,pp,ps;
    
    if (index == 0) {
    p = pointList.get(index);
    ps = pointList.get(index + 1);
    vs = new PVector(ps.x - p.x, ps.y - p.y);
    ns = vs.cross(z).normalize();
    }
    else if (index == pointList.size() - 1) {
    p = pointList.get(index);
    pp = pointList.get(index-1);
    vs = new PVector(p.x - pp.x, p.y - pp.y);
    ns = vs.cross(z).normalize();
    } 
    else {
    p = pointList.get(index);
    pp = pointList.get(index - 1);
    ps = pointList.get(index + 1);
    vs = new PVector(ps.x - pp.x, ps.y - pp.y);
    ns = vs.cross(z).normalize();
    }
    
    return ns;
  }
    
 
  
  void iniTexture() {
    
    if (texi == null) {
        texi = createImage(10, 10, RGB);
        for (int i=0;i<texi.width*texi.height;i++) 
            texi.pixels[i]=color(0, 0, 0, 255);
    }
    
    // _texi has the color of the stroke color c
    // and brightness values (inverse) are mapped to alpha
    
    float cred = red(strokeColor);
    float cgreen = green(strokeColor);
    float cblue = blue(strokeColor);
    
    _texi = createImage(texi.width,texi.height,ARGB);
    for (int i=0;i<texi.width*texi.height;i++) {
      float a = 255-brightness(texi.pixels[i]); 
      _texi.pixels[i]=color(cred,cgreen,cblue,a);
    }
  }
  
 
  public String toString() {
      String s = "Line [";
        for (int i = 1;i<strokePoints.size(); i++) 
           s += strokePoints.get(i).toString();
      s += "] ";
      return s;
  }
  
  
  void movePerpendicuarToGradient(int steps, PImage inp) {
    strokePoints.add(start); //<>//
    PVector current = start;
    color col = inp.get(round(current.x), round(current.y));
    PVector previous = start;

     
    
    for (int i = 0; i < steps; ++i) {
      PVector next = tracePosition(inp, current);
      
      if(next.x == 0.0 && next.y == 0.0) {
        // nowhere to go? Go to a random place!
        next.x = current.x + random(strokeWidth / 2);
        next.y = current.y + random(strokeWidth / 2);
      }
   
   
      color actC = inp.get(round(next.x), round(next.y));
      
      // if color changes too much along the stroke
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) + sq(blue(col)-blue(actC))) > 50) {
         break;
      }
      
      
      // TODO: 
      // a ----- b 
      //         /
      //        /
      //       c
      //
      // Calculate angle between the vectors b -> a and b -> (using a -> b would result in a blunt angle!)
      // a - b <- > c - b
      //
      // look at the previous, current and next point. If the angle is smaller than 45 degrees, 
      // then abort the stroke. You can use degrees() andradians() to convert between the two, most
      // functions work in radians (Check the documentation!). If he angle is ok move on to the
      // next point.

      if (previous != current) {
        PVector p1 = new PVector(previous.x - current.x, previous.y - current.y);
        PVector p2 = new PVector(next.x - current.x, next.y - current.y);
        
        if (PVector.angleBetween(p1, p2) < radians(45))
          break;
      }
      
      previous=current;
      current=next;
      strokePoints.add(next);
       //<>//
    }
  }
  

  PVector tracePosition(PImage inp, PVector pos) {
    int actX = round(pos.x);
    int actY = round(pos.y);
    int w = inp.width;
    
    actX = constrain(actX,1,inp.width-2);
    actY = constrain(actY,1,inp.height-2);
    
    // Gradient 
    float gx =   (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX+1 + (actY  )*w]) - brightness(inp.pixels[actX-1 + (actY  )*w])) +
                 (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w]));

    float gy =   (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX   + (actY+1)*w]) - brightness(inp.pixels[actX   + (actY-1)*w])) +
                 (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w]));
                 
    // Normalize 
    float len = sqrt(sq(gx) + sq(gy));    
    if (len == 0) {
      return new PVector(0,0);
    }
    
    gx /= len;
    gy /= len;

   // find new postion
    float stepSize = strokeWidth / 2;
    float dx = -gy*stepSize;
    float dy =  gx*stepSize;
    return new PVector(actX+dx ,actY+dy);
 }
}
