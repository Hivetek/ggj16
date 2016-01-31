class Player { //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  int id = -1;

  float animationSpeed = 0.07;
  float walkAnim = 0.0;
  float visualBladder = 0.0;
  float visualDrunk = 0.0;

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
  float drunkMoveDamp = 0.7; //Reduction of acceleration when drunk  //<>//
  float drunkFriction = 0.5; //Reduction of friction when drunk, 50%
  float drunkTurnDamp = 0.9; //90% reduction in turn acceleration when drunk
  float drunkTurnSpeed = 0.75; //Extra turnspeed when drunk... Adds 75% extra turnspeed
  int drunkDelay = 8; //Amount of input lag/delay when drunk, in frames 
  float drunkReductionRate = 0.0002;//0.00025 

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

  int drinkingTimestamp = -1000;
  int drinkingTimeout = 1000;
  int givingTimestamp = -1000;

  boolean carryingBeer = false;

  boolean dead = false;

  String name;

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
      name = "Yellow";
      break;
    case 1: 
      playerColor = color(64, 64, 255);
      name = "Blue";
      break;
    case 2: 
      playerColor = color(255, 0, 255);
      name = "Pink";
      break;
    case 3: 
      playerColor = color(64, 255, 64);
      name = "Green";
      break;
    default:
      playerColor = color(255);
      name = "Default";
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
      drunk -= drunkReductionRate+drunk/900.0;
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
    if (id == 0 && getPastInput(delay).isPressed(UP)   || id == 1 && getPastInput(delay).isPressed('w')
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
      || id == 2 && getPastInput(delay).isPressed('j') || id == 3 && getPastInput(delay).isPressed('4')) {
      dirVel += (-turnSpeed*(1.0+drunk*drunkTurnSpeed)-dirVel)*turnAccel*2*(1.0-drunk*drunkTurnDamp);
    }
    if (id == 0 && getPastInput(delay).isPressed(RIGHT) || id == 1 && getPastInput(delay).isPressed('d')
      || id == 2 && getPastInput(delay).isPressed('l')  || id == 3 && getPastInput(delay).isPressed('6')) {
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

    walkAnim += speed*animationSpeed;
    //Drunken motion drunkOscillation
    dirOffset += drunkOscillationFreq*speed;
    if (dirOffset > PI*2) dirOffset -= PI*2;
  }

  void collisionHandling() {
    //boundaries
    float bounds = 70.0;
    if (x < radius+bounds || x > width-(radius+bounds))
      vx = -vx*bounciness;
    if (y < radius+bounds || y > height-(radius+bounds))
      vy = -vy*bounciness;

    x = min(max(bounds+radius, x), width-(radius+bounds));
    y = min(max(bounds+radius, y), height-(radius+bounds));

    //Player collision
    for (Player p : players) {
      if (p.id != id && p.active) {
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
  }

  void drink() {
    if (!this.immune() && this.active && !this.dead) {
      this.drinkingTimestamp = millis();
      if (this.drunk < 1.0) {
        this.drunk += 0.20;
      }
      if (this.bladder < 1.0) {
        this.bladder += 0.05;
        if (this.bladder >= 1.0) {
          this.die();
        }
      }
    }
  }

  boolean immune() {
    return ((millis() - this.drinkingTimestamp) < this.drinkingTimeout || (millis() - this.givingTimestamp) < this.drinkingTimeout);
  }

  void die() {
    active = false;
    dead = true;

    spawnNPC += 10;
    //death_sound.play();

    //TODO: EXPLOSION HERE!

    decideWinning();
  }

  void renderHUD() {
    if (!active || dead)
      return;

    visualBladder += (bladder-visualBladder)*0.05;
    visualDrunk += (drunk-visualDrunk)*0.05;

    //Draw bladder lvl
    color bladderCol = color(180+min(75, abs(visualBladder-bladder)*8000.0), 180+min(75, abs(visualBladder-bladder)*8000.0), 0, 100+min(100, abs(visualBladder-bladder)*8000.0));
    int w = 6;
    int d = 40;
    float startAngle = PI;
    float angle = PI*0.45;
    fill(bladderCol);
    noStroke();
    beginShape();

    int i;
    for (i = 0; i <= round(bladder*100); i++) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*d, py+sin(angle*(i/100.0)+startAngle)*d);
    }
    for (; i >= 0; i--) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*(d-w), py+sin(angle*(i/100.0)+startAngle)*(d-w));
    }
    endShape(CLOSE);

    noFill();
    stroke(bladderCol);
    beginShape();

    for (i = 0; i <= 100; i++) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*d, py+sin(angle*(i/100.0)+startAngle)*d);
    }
    for (; i >= 0; i--) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*(d-w), py+sin(angle*(i/100.0)+startAngle)*(d-w));
    }
    endShape(CLOSE);

    //Draw drunk lvl
    color drunkCol = color(48+min(60, abs(visualBladder-bladder)*8000.0), 48+min(60, abs(visualBladder-bladder)*8000.0), 180+min(255-180, abs(visualBladder-bladder)*8000.0), 100+min(100, abs(visualBladder-bladder)*8000.0));
    startAngle = 0;
    angle =- PI*0.45;
    fill(drunkCol);
    noStroke();
    beginShape();

    for (i = 0; i <= round(drunk*100); i++) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*d, py+sin(angle*(i/100.0)+startAngle)*d);
    }
    for (; i >= 0; i--) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*(d-w), py+sin(angle*(i/100.0)+startAngle)*(d-w));
    }
    endShape(CLOSE);

    noFill();
    stroke(drunkCol);
    beginShape();

    for (i = 0; i <= 100; i++) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*d, py+sin(angle*(i/100.0)+startAngle)*d);
    }
    for (; i >= 0; i--) {
      vertex(x+cos(angle*(i/100.0)+startAngle)*(d-w), py+sin(angle*(i/100.0)+startAngle)*(d-w));
    }
    endShape(CLOSE);

    if (immune()) {
      if (millis()-this.givingTimestamp < this.drinkingTimeout) {
        float oy = 35.0*(millis()-this.givingTimestamp)/this.drinkingTimeout;
        int alpha = round(255.0*sin(PI*(millis()-this.givingTimestamp)/this.drinkingTimeout));
        fill(red(playerColor), green(playerColor), blue(playerColor), alpha);
        textFont(talkFont);
        //drawText("C", x-28, y-45, 0.0, 1.0);
        textFont(emojiFont);
        drawText("D", x, y-20-oy, 0.0, 1.0);
      } else if (millis()-this.drinkingTimestamp < this.drinkingTimeout) {
        /*float oy = 35.0*(millis()-this.drinkingTimestamp)/this.drinkingTimeout;
        int alpha = round(255.0*sin(PI*(millis()-this.drinkingTimestamp)/this.drinkingTimeout));
        fill(red(playerColor), green(playerColor), blue(playerColor), alpha);
        textFont(talkFont);
        //drawText("C", x-28, y-45, 0.0, 1.0);
        textFont(emojiFont);
        drawText("S", x, y-55+oy, 0.0, 1.0);*/
      }
    }
  }

  void render() {
    if (this.dead) {
      translate(x, y);
      rotate(realDirection-PI*0.5);
      switch(id) {
      case 0:
        image(bunny1dead, -25, -25);
        break;
      case 1:
        image(bunny2dead, -25, -25);
        break;
      case 2:
        image(bunny3dead, -25, -25);
        break;
      default:
        image(bunny4dead, -25, -25);
        break;
      }
      resetMatrix();
    }

    if (!this.active) return;

    image(shadow, x-32, y-32);

    //Draw feet
    translate(x, y);
    rotate(realDirection-PI*0.5);
    image(shoeImage, -3-6, sin(walkAnim)*12-4);
    resetMatrix();
    translate(x, y);
    rotate(realDirection-PI*0.5);
    image(shoeImage, 6-3, cos(walkAnim)*12-4);
    resetMatrix();

    //Draw player
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
    if (carryingBeer) {
      image(beerImage, -18, -18);
    }
    resetMatrix();
    if (DEBUG) {
      noFill();
      stroke(playerColor);
      ellipse(x, y, radius, radius);
      line(x, y, x+cos(realDirection)*radius, y+sin(realDirection)*radius);
    }
  }
}