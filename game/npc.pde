ArrayList<NPC> npcs = new ArrayList<NPC>();

enum NPCState {
  ENTERING, 
    LEAVING, 
    GONE, 
    WAITING, 
    REQUESTING, 
    AGGRESSIVE, 
    ANGRYLEAVING
};

  class NPC {
  int type = 0; //0 = fratbro, 1 = guard
  float x;
  float y;
  float vx;
  float vy;
  float dir = random(2*PI);
  int img = round(random(2));

  Player target;

  float animationSpeed = 0.07;
  float walkAnim = 0.0;

  float radius = 12;

  float bounciness = 0.8;
  float speed = 2.0;

  int waitTime = 0;
  int maxRequestTime = 600;
  int aggroTimeout = 150;

  float requestChanceBase = 0.10; //15% for beer request
  float requestChanceAddition =  0.06; //6% higher chance per player
  float spawnChance = 0.4; //40% chance that a new NPC will spawn

  boolean carryingBeer = false;

  float lookFreq = 0.0002+random(0.001);
  float lookSpeed = 0.006+random(0.008);

  float maxTargetDist = height/2;

  Seat seat;

  NPCState state;

  NPC(Seat seat, boolean startAtDoor, int type) {
    this.type = type;
    this.seat = seat;
    if (startAtDoor) {
      this.x = seat.door.x;
      this.y = seat.door.y;
      state = NPCState.ENTERING;
    } else {
      this.x = seat.x;
      this.y = seat.y;
      state = NPCState.ENTERING;
    }
    if (type == 0) {
      speed = 2.0;
    } else {
      speed = 3.4;
    }
  }

  void guardAI() {
    float dx, dy, dist;
    switch(state) {
    case ENTERING:
      if (abs(vx) > 0.1 && abs(vy) > 0.1) { 
        dir += (atan2(vy, vx)-dir)*0.15;
      }

      for (Player p : players) {
        if (p.targeted && p.active && !p.dead) {
          state = NPCState.AGGRESSIVE;
          waitTime = 0;
          break;
        }
      }

      dx = seat.x - x;
      dy = seat.y - y;
      dist = sqrt(dx*dx + dy*dy);
      if (dist > speed*0.5) {
        vx = (dx/dist)*speed*0.5;
        vy = (dy/dist)*speed*0.5;
      } else {
        vx = dx;
        vy = dy;
      }

      if (dist < speed) {
        state = NPCState.WAITING;
        vx = 0;
        vy = 0;
      }
      break;
    case WAITING:
      dir += cos(2*PI*millis()*lookFreq*0.3)*lookSpeed*4;

      for (Player p : players) {
        if (p.targeted && p.active && !p.dead) {
          state = NPCState.AGGRESSIVE;
          waitTime = 0;
          break;
        }
      }

      dx = seat.x - x;
      dy = seat.y - y;
      dist = sqrt(dx*dx + dy*dy);
      if (dist > speed) {
        vx = (dx/dist)*speed;
        vy = (dy/dist)*speed;
      } else {
        vx = dx;
        vy = dy;
      }
      break;
    case AGGRESSIVE:
      waitTime++;
      if (waitTime > aggroTimeout) {
        state = NPCState.ENTERING;
        for (Player p : players) {
          if (p.targeted && p.active && !p.dead) {
            p.targeted = false;
          }
        }
        break;
      }

      int ntargets = 0;
      for (Player p : players) {
        if (p.targeted && p.active && !p.dead) {
          ntargets++;
        }
      }
      if (ntargets == 0) {
        state = NPCState.ENTERING;
        break;
      } else {
        float targetDist = 99999.9;
        dx = 0;
        dy = 0;
        for (Player p : players) {
          if (p.targeted && p.active && !p.dead) {
            float tx, ty;
            tx = p.x - x;
            ty = p.y - y;
            float newDist = sqrt(tx*tx+ty*ty);
            if (newDist < targetDist) {
              target = p;
              targetDist = newDist;
              dx = tx;
              dy = ty;
            }
          }
        }
        if (targetDist < maxTargetDist) {
          dir += cos(2*PI*millis()*lookFreq*6.5)*lookSpeed*10; //Add angry wobble!
          if (targetDist > speed) {
            vx = (dx/targetDist)*speed;
            vy = (dy/targetDist)*speed;
          } else {
            vx = dx;
            vy = dy;
          }
        }
      }

      if (abs(vx) > 0.1 && abs(vy) > 0.1) { 
        dir += (atan2(vy, vx)-dir)*0.15;
      }
      break;
    default:
      break;
    }
  }

  void fratBroAI() {
    float dx, dy, dist;

    switch(state) {
    case ENTERING:
      if (abs(vx) > 0.1 && abs(vy) > 0.1) { 
        dir += (atan2(vy, vx)-dir)*0.15;
      }
      dx = seat.x - x;
      dy = seat.y - y;
      dist = sqrt(dx*dx + dy*dy);
      if (dist > speed) {
        vx = (dx/dist)*speed;
        vy = (dy/dist)*speed;
      } else {
        vx = dx;
        vy = dy;
      }

      if (dist < speed) {
        state = NPCState.WAITING;
        vx = 0;
        vy = 0;
        waitTime = 60*3 + round(random(60*20));
      }
      break;
    case REQUESTING:
      dir += cos(2*PI*millis()*lookFreq*1.5)*lookSpeed*(4+random(6.0*waitTime/maxRequestTime));
      waitTime++;
      if (waitTime > maxRequestTime) {
        waitTime = 0;
        state = NPCState.LEAVING;
        activeRequests--;
        for (Player p : players) {
          p.targeted = true;
        }
      }
      break;
    case WAITING:
      dir += cos(2*PI*millis()*lookFreq)*lookSpeed;

      if (waitTime > 0) {
        dx = seat.x - x;
        dy = seat.y - y;
        dist = sqrt(dx*dx + dy*dy);
        if (dist > speed) {
          vx = (dx/dist)*speed;
          vy = (dy/dist)*speed;
        } else {
          vx = dx;
          vy = dy;
        }

        waitTime--;
      } else {
        waitTime = 0;
        float rand = random(1.0);
        if ((activeRequests == 0 || rand <= requestChanceBase + requestChanceAddition*activePlayers) && !carryingBeer) {
          state = NPCState.REQUESTING;
          activeRequests++;
          vx = 0;
          vy = 0;
        } else {
          state = NPCState.LEAVING;
        }
      }
      break;
    case LEAVING:
      if (abs(vx) > 0.1 && abs(vy) > 0.1) { 
        dir += (atan2(vy, vx)-dir)*0.15;
      }

      dx = seat.door.x - x;
      dy = seat.door.y - y;
      dist = sqrt(dx*dx + dy*dy);
      if (dist > 0) {
        vx = (dx/dist)*speed;
        vy = (dy/dist)*speed;
      }

      if (dist <= radius+30) {
        state = NPCState.GONE;
        carryingBeer = false;
        vx = 0;
        vy = 0;
        waitTime = 60+round(random(60*10));
      }
      break;
    case GONE:
      if (waitTime > 0) {
        waitTime--;
      } else {
        int s = seats.size();
        int sid = floor(random(s));
        seat = seats.get(sid);
        while (seatIsOccupied(seat)) {
          sid++;
          if (sid >= seats.size()) sid = 0;
          seat = seats.get(sid);
        }
        x = seat.door.x;
        y = seat.door.y;
        state = NPCState.ENTERING;

        if (npcs.size() < seats.size()-1) {
          float rand = random(1.0);
          if (rand < 0.35) { //35% chance to spawn another NPC
            spawnNPC++;
          }
        }
      }
      break;
    default:
      break;
    }
  }

  void update() {
    if (type == 0) {
      fratBroAI();
    } else {
      guardAI();
    }

    x += vx;
    y += vy;

    collisionHandling();

    float moveSpeed = sqrt(vx*vx+vy*vy);
    walkAnim += moveSpeed*animationSpeed;
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
    if (state != NPCState.GONE) {
      for (Player p : players) {
        if (!p.active)
          continue;
        float dx = p.x-x;
        float dy = p.y-y;
        float dist = sqrt(dx*dx+dy*dy);
        //TODO: elastic collisions
        if (dist < p.radius + radius && dist > 0) {
          if (state == NPCState.REQUESTING && p.carryingBeer) {
            carryingBeer = true;

            state = NPCState.WAITING;
            activeRequests--;
            waitTime = 60*3 + round(random(60*20));

            p.carryingBeer = false;
            p.givingTimestamp = millis();
            for (Player otherPlayer : players) {
              if (otherPlayer != p) {
                otherPlayer.targeted = true;
                p.targeted = false;
              }
            }
          } else {
            if (type == 1) {
              if (p.targeted || state == NPCState.WAITING) {
                p.drink();
                p.targeted = false;
              }
            } else {
              int r = round(random(2.0));
              angry_bro_sound[r].play(0);

              p.drink();
            }
          }

          float mx = (dx/dist)*(dist-(p.radius + radius))*0.5;
          float my = (dy/dist)*(dist-(p.radius + radius))*0.5;

          p.vx += vx+(dx/dist)*100.0;
          p.vy += vy+(dy/dist)*100.0;

          x += mx;
          y += my;
          p.x -= mx;
          p.y -= my;
        }
      }
    }

    //NPC collision
    if (state != NPCState.GONE) {
      for (NPC npc : npcs) {
        if (npc.state != NPCState.GONE) {
          float dx = npc.x-x;
          float dy = npc.y-y;
          float dist = sqrt(dx*dx+dy*dy);
          //TODO: elastic collisions
          if (dist < npc.radius + radius && dist > 0) {

            float mx = (dx/dist)*(dist-(npc.radius + radius))*0.5;
            float my = (dy/dist)*(dist-(npc.radius + radius))*0.5;

            x += mx;
            y += my;
            npc.x -= mx;
            npc.y -= my;
          }
        }
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

  void renderHUD() {
    if (state == NPCState.REQUESTING) {
      fill(255);
      textFont(talkFont);
      drawText("9", x+28+random(4.0*waitTime/maxRequestTime), y-50+random(4.0*waitTime/maxRequestTime), random(0.08*PI*waitTime/maxRequestTime), 0.90+random(0.2*waitTime/maxRequestTime));
      translate(x+28+random(6.0*waitTime/maxRequestTime), y-60+random(6.0*waitTime/maxRequestTime));
      scale(0.90+random(0.2*waitTime/maxRequestTime));
      rotate(random(0.15*PI*waitTime/maxRequestTime));
      image(beerIconImage, -10, -14);
      resetMatrix();
    } else if (state == NPCState.AGGRESSIVE && target != null) {
      float dx = target.x - x;
      float dy = target.y -y;
      float dist = sqrt(dx*dx+dy*dy);
      if (dist < maxTargetDist)
      {
        fill(255);
        textFont(talkFont);
        drawText("9", x+28+random(4.0), y-50+random(4.0), random(0.08*PI), 0.90+random(0.2));
        fill(red(target.playerColor), green(target.playerColor), blue(target.playerColor), 180);
        textFont(comicFont);
        drawText("!", x+28+random(6.0), y-60+random(6.0), random(0.15*PI), 0.90+random(0.2));
      }
    }
  }

  void render() {
    if (state != NPCState.GONE) {
      image(shadow, x-32, y-32);

      //Draw feet
      translate(x, y);
      rotate(dir-PI*0.5);
      image(shoeImage, -3-6, sin(walkAnim)*12-4);
      resetMatrix();
      translate(x, y);
      rotate(dir-PI*0.5);
      image(shoeImage, 6-3, cos(walkAnim)*12-4);
      resetMatrix();

      float ox = 0.0;
      float oy = 0.0;
      if (state == NPCState.REQUESTING) {
        ox = random(4.0*waitTime/maxRequestTime);
        oy = random(4.0*waitTime/maxRequestTime);
      }

      translate(x, y);
      rotate(dir-PI*0.5);
      if (type == 0) {
        switch(img) {
        case 0:
          image(fratBroImage1, -18+ox, -18+oy);
          break;
        case 1:
          image(fratBroImage2, -18+ox, -18+oy);
          break;
        default:
          image(fratBroImage3, -18+oy, -18+oy);
          break;
        }
      } else {
        image(guardImage, -18+ox, -18+oy);
      }
      if (carryingBeer) {
        image(beerImage, -18, -18);
      }
      resetMatrix();

      if (DEBUG) {
        noFill();
        stroke(255);
        ellipse(x, y, radius, radius);
      }
      if (DEBUG) {
        textFont(regularFont);
        stroke(255);
        fill(255);
        text(waitTime, x+10, y+50);
        ox = 10;
        oy = 30;
        switch(state) {
        case ENTERING:
          text("ENTERING", x+ox, y+oy);
          break;
        case REQUESTING:
          text("REQUESTING", x+ox, y+oy);
          break;
        case WAITING:
          text("WAITING", x+ox, y+oy);
          break;
        case LEAVING:
          text("LEAVING", x+ox, y+oy);
          break;
        case GONE:
          text("GONE", x+ox, y+oy);
          break;
        case AGGRESSIVE:
          text("AGGRESIVE", x+ox, y+oy);
          break;
        case ANGRYLEAVING:
          text("ANGRYLEAVING", x+ox, y+oy);
          break;
        }
      }
    }
  }
}