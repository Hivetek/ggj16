class Player {
  //Physics parameters
  float moveAccel = 0.5;
  float moveSpeed = 3.4;
  float turnSpeed = 0.08;
  float friction = 0.08;
  float oscillationFreq = 0.03;
  float oscillationAmpl = 0.18;
  float bounciness = 0.8;

  float radius = 16;

  float px, py, x, y, vx, vy, ax, ay, dir;
  float dirOffset = 0.0;

  float drunk = 0.0;
  float speed = 0;

  float realDirection; 
 //<>//
  Player(float xx, float yy) {
    px = x = xx;
    py = y = yy;
    dir = random(2*PI);
    ax = ay = vx = vy = 0;
    realDirection = dir;
  }

  void update() {
    int delay = round(drunk*15); 

    px = x;
    py = y;

    realDirection = dir + drunk*oscillationAmpl*PI*cos(dirOffset);

    ax = 0;
    ay = 0;

    if (getPastInput(delay).isPressed(UP)) {
      ax += cos(realDirection)*(moveAccel*(1.0-drunk*0.7));
      ay += sin(realDirection)*(moveAccel*(1.0-drunk*0.7));
    }
    if (getPastInput(delay).isPressed(DOWN)) {
      ax -= cos(realDirection)*(moveAccel*(1.0-drunk*0.7));
      ay -= sin(realDirection)*(moveAccel*(1.0-drunk*0.7));
    }

    if (getPastInput(delay).isPressed(LEFT)) {
      dir -= turnSpeed;
    }
    if (getPastInput(delay).isPressed(RIGHT)) {
      dir += turnSpeed;
    }

    vx += ax;
    vy += ay;

    //friction
    vx *= 1.0-friction*(1.0-drunk*0.5);
    vy *= 1.0-friction*(1.0-drunk*0.5);

    //speed limit
    float speed = sqrt(vx*vx + vy*vy);
    if (speed > moveSpeed) {
      vx *= moveSpeed/speed;
      vy *= moveSpeed/speed;
      speed = moveSpeed;
    }

    x += vx;
    y += vy;

    //boundaries
    if (x < radius || x > width-radius)
      vx = -vx*bounciness;
    if (y < radius || y > height-radius)
      vy = -vy*bounciness;

    x = min(max(radius, x), width-radius);
    y = min(max(radius, y), height-radius);

    //Obstacles
    for (int i = 0; i < obstacles.length; i++) {
      if (obstacles[i].type == 0) {
        if (obstacles[i].intersects(x, y, radius)) {
          float dx = x-obstacles[i].x; //TODO:Optimize with rectangle boundary test (broadphase)
          float dy = y-obstacles[i].y;
          float dist = sqrt(dx*dx+dy*dy);
          float rsum = radius + obstacles[i].r;
          x += (dx*(rsum-dist))/dist;
          y += (dy*(rsum-dist))/dist;
        }
      } else if (obstacles[i].type == 1) {
        if (obstacles[i].intersects(x, y, radius)) {
          for (int n = 0; n < 60; n++) {
            float a = n*2*PI/60;
            float rx = x + cos(a)*radius;
            float ry = y + sin(a)*radius;
            if (obstacles[i].intersects(rx, ry, 0)) {
              boolean collision = true;
              while (collision) {
                x -= cos(a);
                y -= sin(a);
                rx = x + cos(a)*radius;
                ry = y + sin(a)*radius;
                if(!obstacles[i].intersects(rx, ry, 0)){
                  collision = false;
                }
              }
            }
          }
        }
      }
    }

    //Drunken motion oscillation
    dirOffset += drunk*oscillationFreq*speed;
    if (dirOffset > PI*2) dirOffset -= PI*2;
  }

  void render() {
    noFill();
    ellipse(x, y, radius, radius);

    line(x, y, x+cos(realDirection)*radius, y+sin(realDirection)*radius);
  }
}