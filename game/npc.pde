ArrayList<NPC> npcs = new ArrayList<NPC>();

enum NPCState {
  ENTERING, 
    LEAVING, 
    GONE, 
    WAITING, 
    REQUESTING
};

  class NPC {
  float x;
  float y;
  float vx;
  float vy;
  float dir = random(2*PI);
  int img = round(random(2));

  float radius = 12;

  float bounciness = 0.8;
  float speed = 2;

  int waitTime = 0;
  int maxRequestTime = 600;

  float requestChanceBase = 0.10; //15% for beer request
  float requestChanceAddition =  0.06; //6% higher chance per player
  float spawnChance = 0.2; //20% chance that a new NPC will spawn

  Seat seat;

  NPCState state;

  NPC(Seat seat, boolean startAtDoor) {
    this.seat = seat;
    if (startAtDoor) {
      this.x = seat.door.x;
      this.y = seat.door.y;
      state = NPCState.ENTERING;
    } else {
      this.x = seat.x;
      this.y = seat.y;
      state = NPCState.WAITING;
    }
  }

  void update() {
    float dx, dy, dist;

    if (abs(vx) > 0.1 && abs(vy) > 0.1) { 
      dir += (atan2(vy, vx)-dir)*0.15;
    }

    switch(state) {
    case ENTERING:
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

      if (dist < 1) {
        state = NPCState.WAITING;
        vx = 0;
        vy = 0;
        waitTime = 60*3 + round(random(60*20));
      }
      break;
    case REQUESTING:
      waitTime++;
      if (waitTime > maxRequestTime) {
        waitTime = 0;
        state = NPCState.LEAVING;
        activeRequests--;
        for (Player p : players) {
          p.drink();
        }
      }
      break;
    case WAITING:
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
        if (activeRequests == 0 || rand <= requestChanceBase + requestChanceAddition*activePlayers) {
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
      dx = seat.door.x - x;
      dy = seat.door.y - y;
      dist = sqrt(dx*dx + dy*dy);
      if (dist > 0) {
        vx = (dx/dist)*speed;
        vy = (dy/dist)*speed;
      }

      if (dist <= radius+30) {
        state = NPCState.GONE;
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
          if (rand < 0.3) {
            spawnNPC = true;
          }
        }
      }
      break;
    }

    x += vx;
    y += vy;

    collisionHandling();
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
        float dx = p.x-x;
        float dy = p.y-y;
        float dist = sqrt(dx*dx+dy*dy);
        //TODO: elastic collisions
        if (dist < p.radius + radius && dist > 0) {
          if (state == NPCState.REQUESTING && p.carryingBeer) {

            state = NPCState.WAITING;
            activeRequests--;
            waitTime = 60*3 + round(random(60*20));
            
            p.carryingBeer = false;
            p.drinkingTimestamp = millis();
            for (Player otherPlayer : players) {
              if (otherPlayer != p) {
                otherPlayer.drink();
              }
            }
          } else {
            p.drink();
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

  void render() {
    if (state != NPCState.GONE) {
      image(shadow, x-32, y-32);
      translate(x, y);
      rotate(dir-PI*0.5);
      switch(img) {
      case 0:
        image(fratBroImage1, -18, -18);
        break;
      case 1:
        image(fratBroImage2, -18, -18);
        break;
      default:
        image(fratBroImage3, -18, -18);
        break;
      }
      resetMatrix();

      if (DEBUG) {
        noFill();
        stroke(255);
        ellipse(x, y, radius, radius);
      }

      if (state == NPCState.REQUESTING) {
        fill(255);
        textFont(talkFont);
        drawText("9", x+28+random(4.0*waitTime/maxRequestTime), y-50+random(4.0*waitTime/maxRequestTime), random(0.08*PI*waitTime/maxRequestTime), 0.90+random(0.2*waitTime/maxRequestTime));
        //fill(255, 64, 255, 180); //PINK
        fill(255);
        textFont(comicFont);
        drawText("!", x+28+random(6.0*waitTime/maxRequestTime), y-60+random(6.0*waitTime/maxRequestTime), random(0.15*PI*waitTime/maxRequestTime), 0.90+random(0.2*waitTime/maxRequestTime));
      }

      if (DEBUG) {
        textFont(regularFont);
        stroke(255);
        fill(255);
        text(waitTime, x+10, y+50);
        float ox = 10;
        float oy = 30;
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
          break;
        }
      }
    }
  }
}