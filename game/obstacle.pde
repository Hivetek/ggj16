class Obstacle {
  float x, y;
  float w, h, r;
  int type; //0 = circle, 1 = rect

  Obstacle(float xx, float yy, int t) {
    x = xx;
    y = yy;
    type = t;
    w = h = 32;
    r = 16;
  }

  void render() {
    pushStyle();
    noFill();
    stroke(255);
    if (type == 0) {
      ellipse(x, y, r, r);
    } else if (type == 1) {
      rect(x-w/2, y-h/2, w, h);
    }
    popStyle();
  }

  boolean intersects(float ix, float iy, float radius) {
    if (type == 0) {
      float dx = ix-x;
      float dy = iy-y;
      float dist = sqrt(dx*dx+dy*dy);
      if (dist < radius+r) {
        return true;
      } else {
        return false;
      }
    } else if (type == 1) {
      if (ix + radius > x-w/2 &&
        ix - radius < x+w/2 &&
        iy + radius > y-h/2 &&
        iy - radius < y+h/2) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }
}