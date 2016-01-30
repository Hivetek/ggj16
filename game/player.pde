class Player { //<>// //<>// //<>// //<>// //<>// //<>//
  int id = -1;

  //Physics parameters
  float moveAccel = 0.5;
  float moveSpeed = 3.4;
  float turnAccel = 0.5;
  float turnSpeed = 0.10;
  float friction = 0.08;
  float bounciness = 0.8;

  //Drunkenness parameters
  float drunkOscillationFreq = 0.02; //Swerving oscillation frequency when drunk
  float drunkOscillationAmpl = 0.20; //Swerving oscillation amplitude when drunk
  float drunkMoveDamp = 0.7; //Reduction of acceleration when drunk
  float drunkFriction = 0.5; //Reduction of friction when drunk, 50%
  float drunkTurnDamp = 0.9; //90% reduction in turn acceleration when drunk
  float drunkTurnSpeed = 0.75; //Extra turnspeed when drunk... Adds 75% extra turnspeed
  int drunkDelay = 8; //Amount of input lag/delay when drunk, in frames 
  float drunkReductionRate = 0.0;//0.00025;  //<>// //<>//

  float radius = 12;

  float px, py, x, y, vx, vy, ax, ay, dirVel, dir;
  float dirOffset = 0.0;

  // Stats 
  float drunk = 0.0; 
  float bladder = 0.0;

  float speed = 0.0;

  float realDirection; 

  boolean active = false;

  color playerColor = color(255);

  int drinkingTimestamp = millis();

  int drinkingTimeout = 600;
  
  boolean carryingBeer = false;


  Player(int id, float xx, float yy, boolean active) {
    this.id = id;
    this.active = active;
    px = x = xx;
    py = y = yy;
    dir = random(2*PI);
    ax = ay = vx = vy = dirVel = 0;
    realDirection = dir;

    switch(id) {
    case 0: 
      playerColor = color(255, 255, 0);
      break;
    case 1: 
      playerColor = color(128, 128, 255);
      break;
    case 2: 
      playerColor = color(255, 0, 255);
      break;
    case 3: 
      playerColor = color(64, 255, 64);
      break;
    default:
      playerColor = color(255);
      break;
    }
  }

  void update() {
    if (!this.active) return;

    int delay = 0;
    if (drunk >= 0.5) {
      delay = round(2*(drunk-0.5)*drunkDelay);
    }

    if (drunk > 0) {
      drunk -= drunkReductionRate;
    }

    px = x;
    py = y;

    //Add swerving to direction
    float swerving = 0.0;
    if (drunk > 0.5) {
      swerving = 1.0;
    } else {
      swerving = drunk*2.0;
    }
    realDirection = dir + swerving*drunkOscillationAmpl*PI*cos(dirOffset);

    ax = 0;
    ay = 0;

    //Movement & controls
    if (id == 0 && getPastInput(delay).isPressed(UP)  || id == 1 && getPastInput(delay).isPressed('w')
      || id == 2 && getPastInput(delay).isPressed('i') || id == 3 && getPastInput(delay).isPressed('8')) {
      ax += cos(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
      ay += sin(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
    }
    if (id == 0 && getPastInput(delay).isPressed(DOWN) || id == 1 && getPastInput(delay).isPressed('s')
      || id == 2 && getPastInput(delay).isPressed('k') || id == 3 && getPastInput(delay).isPressed('5')) {
      ax -= cos(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
      ay -= sin(realDirection)*(moveAccel*(1.0-drunk*drunkMoveDamp));
    }

    dirVel -= dirVel*turnAccel*(1.0-drunk*drunkTurnDamp);

    if (id == 0 && getPastInput(delay).isPressed(LEFT) || id == 1 && getPastInput(delay).isPressed('a')
      || id == 2 && getPastInput(delay).isPressed('j')  || id == 3 && getPastInput(delay).isPressed('4')) {
      dirVel += (-turnSpeed*(1.0+drunk*drunkTurnSpeed)-dirVel)*turnAccel*2*(1.0-drunk*drunkTurnDamp);
    }
    if (id == 0 && getPastInput(delay).isPressed(RIGHT) || id == 1 && getPastInput(delay).isPressed('d')
      || id == 2 && getPastInput(delay).isPressed('l')   || id == 3 && getPastInput(delay).isPressed('6')) {
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

    collisionHandling();

    //Drunken motion drunkOscillation
    dirOffset += drunkOscillationFreq*speed;
    if (dirOffset > PI*2) dirOffset -= PI*2;
  }

  void collisionHandling() {
    //boundaries
    float bounds = 55.0;
    if (x < radius+bounds || x > width-(radius+bounds))
      vx = -vx*bounciness;
    if (y < radius+bounds || y > height-(radius+bounds))
      vy = -vy*bounciness;

    x = min(max(bounds+radius, x), width-(radius+bounds));
    y = min(max(bounds+radius, y), height-(radius+bounds));

    //Player collision
    for (Player p : players) {
      if (p.id != id) {
        float dx = p.x-x;
        float dy = p.y-y;
        float dist = sqrt(dx*dx+dy*dy);
        //TODO: elastic collisions
        if (dist < p.radius + radius && dist > 0) {
          float mx = (dx/dist)*(dist-(p.radius + radius))*0.5;
          float my = (dy/dist)*(dist-(p.radius + radius))*0.5;
          
          p.vx += vx+(dx/dist)*100.0;
          p.vy += vy+(dy/dist)*100.0;
          vx -= p.vx+(dx/dist)*100.0;
          vy -= p.vy+(dy/dist)*100.0;

          x += mx;
          y += my;
          p.x -= mx;
          p.y -= my;
        }
      }
    }


    
    for (BeerStation beerstation : beerstations) {
      if (beerstation.assocObstacle.intersects(x, y, radius)) {
        carryingBeer = true;
      }
    }
    
    
    //Obstacles
    //TODO: Bounciness
    for (Obstacle obstacle : staticObstacles) {
      if (obstacle.type == 0) {
        if (obstacle.intersects(x, y, radius)) {
          float dx = x-obstacle.x; //TODO:Optimize with rectangle boundary test (broadphase)
          float dy = y-obstacle.y;
          float dist = sqrt(dx*dx+dy*dy);
          float rsum = radius + obstacle.r;
          if (dist > 0) {
            x += (dx*(rsum-dist))/dist;
            y += (dy*(rsum-dist))/dist;
          }
        }
      } else if (obstacle.type == 1) {
        if (obstacle.intersects(x, y, radius)) {
          for (int n = 0; n < 60; n++) {
            float a = n*2*PI/60;
            float rx = x + cos(a)*radius;
            float ry = y + sin(a)*radius;
            if (obstacle.intersects(rx, ry, 0)) {
              boolean collision = true;
              while (collision) {
                x -= cos(a);
                y -= sin(a);
                rx = x + cos(a)*radius;
                ry = y + sin(a)*radius;
                if (!obstacle.intersects(rx, ry, 0)) {
                  collision = false;
                }
              }
            }
          }
        }
      }
    }


    //TODO: NPC collision
  }

  void drink() {
    int now = millis();

    if (now - this.drinkingTimestamp >= this.drinkingTimeout) {
      this.drinkingTimestamp = millis();
      if (this.drunk < 1.0) {
        this.drunk += 0.1;
      }
      if (this.bladder < 1.0) {
        this.bladder += 0.05;
      }
    }
  }

  void render() {
    if (!this.active) return;

    image(shadow, x-32, y-32);
    translate(x, y);
    rotate(realDirection-PI*0.5);
    switch(id) {
    case 0:
      image(bunny1, -25, -25);
      break;
    case 1:
      image(bunny2, -25, -25);
      break;
    case 2:
      image(bunny3, -25, -25);
      break;
    default:
      image(bunny4, -25, -25);
      break;
    }
    resetMatrix();
    if (DEBUG) {
      noFill();
      stroke(playerColor);
      ellipse(x, y, radius, radius);
      line(x, y, x+cos(realDirection)*radius, y+sin(realDirection)*radius);
    }

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