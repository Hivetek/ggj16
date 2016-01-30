class Player {
  int id = -1;

  //Physics parameters
  float moveAccel = 0.5;
  float moveSpeed = 3.4;
  float turnAccel = 0.5;
  float turnSpeed = 0.10;
  float friction = 0.08;
  float bounciness = 0.8;
  
  //Drunkenness parameters
  float drunkOscillationFreq = 0.03; //Swerving oscillation frequency when drunk
  float drunkOscillationAmpl = 0.20; //Swerving oscillation amplitude when drunk
  float drunkMoveDamp = 0.7; //Reduction of acceleration when drunk
  float drunkFriction = 0.5; //Reduction of friction when drunk, 50%
  float drunkTurnDamp = 0.9; //90% reduction in turn acceleration when drunk
  float drunkTurnSpeed = 0.75; //Extra turnspeed when drunk... Adds 75% extra turnspeed
  float drunkReductionRate = 0.0018;

  float radius = 16;

  float px, py, x, y, vx, vy, ax, ay, dirVel, dir;
  float dirOffset = 0.0;

  // Stats
  float drunk = 0.0; //<>//
  float bladder = 0.5;

  float speed = 0.0;

  float realDirection; 

  Player(int id, float xx, float yy) {
    this.id = id;
    px = x = xx;
    py = y = yy;
    dir = random(2*PI);
    ax = ay = vx = vy = dirVel = 0;
    realDirection = dir;
  }

  void update() {
    int delay = round(drunk*10);
    //int delay = 0; 

    if (drunk > 0) {
      drunk -= drunkReductionRate;
    }

    px = x;
    py = y;

    realDirection = dir + drunk*drunkOscillationAmpl*PI*cos(dirOffset);

    ax = 0;
    ay = 0;
    
    //Movement & controls
    if (id == 0 && getPastInput(delay).isPressed(UP) || id == 1 && getPastInput(delay).isPressed('w')) {
      ax += cos(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
      ay += sin(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
    }
    if (id == 0 && getPastInput(delay).isPressed(DOWN) || id == 1 && getPastInput(delay).isPressed('s')) {
      ax -= cos(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
      ay -= sin(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
    }

    dirVel -= dirVel*turnAccel*(1.0-drunk*drunkTurnDamp);

    if (id == 0 && getPastInput(delay).isPressed(LEFT) || id == 1 && getPastInput(delay).isPressed('a')) {
      dirVel += (-turnSpeed*(1.0+drunk*drunkTurnSpeed)-dirVel)*turnAccel*2*(1.0-drunk*drunkTurnDamp);
    }
    if (id == 0 && getPastInput(delay).isPressed(RIGHT) || id == 1 && getPastInput(delay).isPressed('d')) {
      dirVel += (turnSpeed*(1.0+drunk*drunkTurnSpeed)-dirVel)*turnAccel*2*(1.0-drunk*drunkTurnDamp);
    }

    vx += ax;
    vy += ay;

    //friction
    vx *= 1.0-friction*(1.0-drunk*drunkFriction);
    vy *= 1.0-friction*(1.0-drunk*drunkFriction);

    //speed limit
    float speed = sqrt(vx*vx + vy*vy);
    if (speed > moveSpeed) {
      vx *= moveSpeed/speed;
      vy *= moveSpeed/speed;
      speed = moveSpeed;
    }

    x += vx;
    y += vy;
    dir += dirVel;

    //boundaries
    if (x < radius || x > width-radius)
      vx = -vx*bounciness;
    if (y < radius || y > height-radius)
      vy = -vy*bounciness;

    x = min(max(radius, x), width-radius);
    y = min(max(radius, y), height-radius);

    //Player collision
    for (Player p : players) {
      if (p.id != id) {
        float dx = p.x-x;
        float dy = p.y-y;
        float dist = sqrt(dx*dx+dy*dy);
        //TODO: elastic collisions
        if (dist < p.radius + radius) {
          float mx = (dx/dist)*(dist-(p.radius + radius))*0.5;
          float my = (dy/dist)*(dist-(p.radius + radius))*0.5;
          
          x += mx;
          y += my;
          p.x -= mx;
          p.y -= my;
        }
      }
    }


    //Obstacles
    //TODO: Bounciness
    for (int i = 0; i < obstacles.length; i++) {
      if (obstacles[i].type == 0) {
        if (obstacles[i].intersects(x, y, radius)) {
          float dx = x-obstacles[i].x; //TODO:Optimize with rectangle boundary test (broadphase)
          float dy = y-obstacles[i].y;
          float dist = sqrt(dx*dx+dy*dy);
          float rsum = radius + obstacles[i].r;
          x += (dx*(rsum-dist))/dist;
          y += (dy*(rsum-dist))/dist;
          drunk = 1.0; //TODO: REMOVE!
        }
      } else if (obstacles[i].type == 1) {
        if (obstacles[i].intersects(x, y, radius)) {
          drunk = 1.0; //TODO: REMOVE!

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
                if (!obstacles[i].intersects(rx, ry, 0)) {
                  collision = false;
                }
              }
            }
          }
        }
      }
    }

    //Drunken motion drunkOscillation
    dirOffset += drunk*drunkOscillationFreq*speed;
    if (dirOffset > PI*2) dirOffset -= PI*2;
  }

  void render() {
    noFill();
    ellipse(x, y, radius, radius);

    line(x, y, x+cos(realDirection)*radius, y+sin(realDirection)*radius);
  }
}