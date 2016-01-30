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

  float speed = 2;

  int waitTime = 0;

  float requestChance = 0.2; //40% for beer request
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
      if (dist > 0) {
        x += (dx/dist)*speed;
        y += (dy/dist)*speed;
      }

      if (dist < 1) {
        state = NPCState.WAITING;
        waitTime = 60*3 + round(random(60*20));
        println("Waiting for "+waitTime+" frames");
      }
      break;
    case REQUESTING:
      break;
    case WAITING:
      if (waitTime > 0) {
        waitTime--;
      } else {
        waitTime = 0;
        float rand = random(1.0);
        if (rand <= requestChance) {
          state = NPCState.REQUESTING;
          println("REQUESTING!");
        } else {
          state = NPCState.LEAVING;
          println("LEAVING!");
        }
      }
      break;
    case LEAVING:
      dx = seat.door.x - x;
      dy = seat.door.y - y;
      dist = sqrt(dx*dx + dy*dy);
      if (dist > 0) {
        x += (dx/dist)*speed;
        y += (dy/dist)*speed;
      }

      if (dist < 1.0) {
        state = NPCState.GONE;
        waitTime = 60+round(random(60*10));
        println("Waiting for "+waitTime+" frames");
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