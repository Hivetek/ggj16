class Player {
  int id = -1;
  
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

  // Stats
  float drunk = 0.0;
  float bladder = 0.5;
  
  float speed = 0;

  float realDirection; 

  Player(int id, float xx, float yy) {
    this.id = id;
    px = x = xx;
    py = y = yy;
    dir = random(2*PI);
    ax = ay = vx = vy = 0;
    realDirection = dir;
  }

  void update() {
    int delay = round(drunk*15); //<>//

    realDirection = dir + drunk*oscillationAmpl*PI*cos(dirOffset);

    ax = 0;
    ay = 0;

    if (id == 0 && getPastInput(delay).isPressed(UP) || id == 1 && getPastInput(delay).isPressed('w')) {
      ax += cos(realDirection)*(moveAccel*(1.0-drunk*0.7));
      ay += sin(realDirection)*(moveAccel*(1.0-drunk*0.7));
    }
    if (getPastInput(delay).isPressed(DOWN) || id == 1 && getPastInput(delay).isPressed('s')) {
      ax -= cos(realDirection)*(moveAccel*(1.0-drunk*0.7));
      ay -= sin(realDirection)*(moveAccel*(1.0-drunk*0.7));
    }

    if (getPastInput(delay).isPressed(LEFT) || id == 1 && getPastInput(delay).isPressed('a')) {
      dir -= turnSpeed;
    }
    if (getPastInput(delay).isPressed(RIGHT) || id == 1 && getPastInput(delay).isPressed('d')) {
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