class Player {
  float moveAccel = 0.5;
  float moveSpeed = 2.4;
  float turnSpeed = 0.08;
  float radius = 16;

  float px, py, x, y, vx, vy, ax, ay, dir;
  float dirOffset = 0.0;

  float drunk = 0.0;
  float bladder = 0.5;
  
  float speed = 0;
  float friction = 0.08;

  Player(float xx, float yy) {
    px = x = xx;
    py = y = yy;
  }

  void update() {
    int delay = round(drunk*10); //<>//

    float realdirection = dir + drunk*0.4*PI*cos(dirOffset);
    
    
    ax = 0;
    ay = 0;
    
    if (getPastInput(delay).isPressed(UP)) {
      ax += cos(realdirection)*(moveAccel*(1.0-drunk*0.7));
      ay += sin(realdirection)*(moveAccel*(1.0-drunk*0.7));
    }
    if (getPastInput(delay).isPressed(DOWN)) {
      ax -= cos(realdirection)*(moveAccel*(1.0-drunk*0.7));
      ay -= sin(realdirection)*(moveAccel*(1.0-drunk*0.7));
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
    if(speed > moveSpeed){
      vx *= moveSpeed/speed;
      vy *= moveSpeed/speed;
      speed = moveSpeed;
    }
    
    x += vx;
    y += vy;

    //Drunken motion oscillation
    dirOffset += drunk*0.02*speed;
    if (dirOffset > PI*2) dirOffset -= PI*2;
  }

  void render() {
    float realdirection = dir + drunk*0.4*PI*cos(dirOffset);
    noFill();
    ellipse(x, y, radius, radius);

    line(x, y, x+cos(realdirection)*radius, y+sin(realdirection)*radius);
  }
}