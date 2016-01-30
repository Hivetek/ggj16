class Path {

  ArrayList<PVector> points;
  float radius;
 
  Path() {
    radius = 20;
    points = new ArrayList<PVector>();
  }
 

  void addPoint(float x, float y) {
    PVector point = new PVector(x,y);
    points.add(point);
  }


  void render() {
    pushStyle();
    stroke(255);
    noFill();
    beginShape();
    for (PVector v : points) {
      vertex(v.x,v.y);
    }
    endShape();
    popStyle();
  }

}



PVector getNormalPoint(PVector p, PVector a, PVector b) {
  PVector ap = PVector.sub(p, a);
  PVector ab = PVector.sub(b, a);
  
  ab.normalize();
  ab.mult(ap.dot(ab));
  
  PVector normalPoint = PVector.add(a, ab);
   
  return normalPoint;
}