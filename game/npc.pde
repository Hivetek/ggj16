ArrayList<NPC> npcs = new ArrayList<NPC>();

NPCController npccontroller = new NPCController();

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
  float dir = 0;

  float radius = 20;

  float bounciness = 0.8;
  float speed = 2;

  int waitTime = 0;

  float requestChance = 0.1; //40% for beer request
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
        if (rand <= requestChance) {
          state = NPCState.REQUESTING;
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
          if (state == NPCState.REQUESTING) {
            state = NPCState.WAITING;
            waitTime = 60*3 + round(random(60*20));
            //TODO: Other players drink
          } else {
            if (p.drunk < 1.0) {
              p.drunk += 0.1;
              p.bladder += 0.05;
            }
          }

          float mx = (dx/dist)*(dist-(p.radius + radius))*0.5;
          float my = (dy/dist)*(dist-(p.radius + radius))*0.5;

          p.vx += (dx/dist)*100.0;
          p.vy += (dy/dist)*100.0;

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
      noFill();
      stroke(255);

      ellipse(x, y, radius, radius);

      line(x, y, x+cos(dir)*radius, y+sin(dir)*radius);

      if (state == NPCState.REQUESTING) {
        fill(255);
        textFont(talkFont);
        drawText("9", x+28+random(3), y-50+random(3), random(0.05*PI), 0.95+random(0.1));
        //fill(255, 64, 255, 180); //PINK
        fill(255);
        textFont(comicFont);
        drawText("!", x+28+random(6), y-60+random(6), random(0.15*PI), 0.95+random(0.1));
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


class NPCController {
  void update() {

    /*for (NPC npc : npcs) {
     // Do meaningful things in these states
     if (npc.state == NPCState.WAITING) {
     npc.state = NPCState.REQUESTING;
     }
     if (npc.state == NPCState.REQUESTING) {
     npc.state = NPCState.LEAVING;
     }
     }*/
  }
}