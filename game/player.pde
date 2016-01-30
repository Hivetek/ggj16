class Player {
  int id = -1;

  //Physics parameters
  float moveAccel = 0.5;
  float moveSpeed = 3.4;
  float turnAccel = 0.5;
  float turnSpeed = 0.08;
  float friction = 0.08;
  float oscillationFreq = 0.03;
  float oscillationAmpl = 0.20;
  float bounciness = 0.8;

  float radius = 16;

  float px, py, x, y, vx, vy, ax, ay, dirVel, dir;
  float dirOffset = 0.0;

  // Stats
  float drunk = 0.0; //<>//
  float bladder = 0.5;

  float speed = 0;

  float realDirection; 
  
  boolean active = false;

  Player(int id, float xx, float yy, boolean active) {
    this.id = id;
    this.active = active;
    px = x = xx;
    py = y = yy;
    dir = random(2*PI);
    ax = ay = vx = vy = dirVel = 0;
    realDirection = dir;
  }

  void update() {
    if (!this.active) return;
    
    int delay = round(drunk*10);
    //int delay = 0; 

    if (drunk > 0) {
      drunk -= 0.0018;
    }

    px = x;
    py = y;

    realDirection = dir + drunk*oscillationAmpl*PI*cos(dirOffset);

    ax = 0;
    ay = 0;

    if (id == 0 && getPastInput(delay).isPressed(UP)  || id == 1 && getPastInput(delay).isPressed('w')
     || id == 2 && getPastInput(delay).isPressed('i') || id == 3 && getPastInput(delay).isPressed('8')) {
      ax += cos(realDirection)*(moveAccel*(1.0-drunk*0.7));
      ay += sin(realDirection)*(moveAccel*(1.0-drunk*0.7));
    }
    if (id == 0 && getPastInput(delay).isPressed(DOWN) || id == 1 && getPastInput(delay).isPressed('s')
     || id == 2 && getPastInput(delay).isPressed('k') || id == 3 && getPastInput(delay).isPressed('5')) {
      ax -= cos(realDirection)*(moveAccel*(1.0-drunk*0.7));
      ay -= sin(realDirection)*(moveAccel*(1.0-drunk*0.7));
    }

    dirVel -= dirVel*turnAccel*(1.0-drunk*0.9);

    if (id == 0 && getPastInput(delay).isPressed(LEFT) || id == 1 && getPastInput(delay).isPressed('a')
     || id == 2 && getPastInput(delay).isPressed('j')  || id == 3 && getPastInput(delay).isPressed('4')) {
      dirVel += (-turnSpeed*(1.0+drunk*0.75)-dirVel)*turnAccel*2*(1.0-drunk*0.9);
    }
    if (id == 0 && getPastInput(delay).isPressed(RIGHT) || id == 1 && getPastInput(delay).isPressed('d')
     || id == 2 && getPastInput(delay).isPressed('l')   || id == 3 && getPastInput(delay).isPressed('6')) {
      dirVel += (turnSpeed*(1.0+drunk*0.75)-dirVel)*turnAccel*2*(1.0-drunk*0.9);
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
          
          if (p.speed > speed) {
            vx += (dx/dist)*1000.0+p.vx;
            vy += (dy/dist)*1000.0+p.vy;
          } else if (p.speed < speed) {
            p.vx += (dx/dist)*1000.0+vx;
            p.vy += (dy/dist)*1000.0+vy;
          } else {
            vx += (dx/dist)*1000.0+p.vx;
            vy += (dy/dist)*1000.0+p.vy;
            p.vx += (dx/dist)*1000.0+vx;
            p.vy += (dy/dist)*1000.0+vy;
          }
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

    //Drunken motion oscillation
    dirOffset += drunk*oscillationFreq*speed;
    if (dirOffset > PI*2) dirOffset -= PI*2;
  }

  void render() {
    if (!this.active) return;
    
    noFill();
    ellipse(x, y, radius, radius);

    line(x, y, x+cos(realDirection)*radius, y+sin(realDirection)*radius);
    
    // --- HUD ---
     
    pushStyle();

    // Drunk-meter
    int drunk_meter_width = 100;
    int drunk_meter_height = 10;
    float drunk_meter_x = this.x - drunk_meter_width / 2;
    float drunk_meter_y = this.y - this.radius*2 - drunk_meter_height;

    stroke(59.2, 2.7, 0.8);
    noFill();
    rect(drunk_meter_x, drunk_meter_y, drunk_meter_width, drunk_meter_height);
    fill(59.2, 2.7, 0.8);
    rect(drunk_meter_x, drunk_meter_y, min(this.drunk*drunk_meter_width, drunk_meter_width), drunk_meter_height);

    popStyle();

    pushStyle();

    // Drunk-meter
    int bladder_meter_width = 100;
    int bladder_meter_height = 10;
    float bladder_meter_x = this.x - bladder_meter_width / 2;
    float bladder_meter_y = this.y - this.radius*2 - drunk_meter_height - 5 - bladder_meter_height;
    stroke(90.2, 90.2, 0);
    noFill();
    rect(bladder_meter_x, bladder_meter_y, bladder_meter_width, bladder_meter_height);
    fill(90.2, 90.2, 0);
    rect(bladder_meter_x, bladder_meter_y, min(this.bladder*bladder_meter_width, bladder_meter_width), bladder_meter_height);

    popStyle();
  }
}