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

    if (state == NPCState.ENTERING) {
      float dx = seat.x - x;
      float dy = seat.y - y;
      float dist = sqrt(dx*dx + dy*dy);
      x += (dx/dist)*speed;
      y += (dy/dist)*speed;
      
      if (dist < 1) {
        state = NPCState.WAITING;
      }
    } else if (state == NPCState.LEAVING) {
      float dx = seat.door.x - x;
      float dy = seat.door.y - y;
      float dist = sqrt(dx*dx + dy*dy);
      x += (dx/dist)*speed;
      y += (dy/dist)*speed;
      
      if (dist < 1) {
        state = NPCState.GONE;
      }
    }
  }

  void render() {

    noFill();
    stroke(255);
    ellipse(x, y, radius, radius);

    line(x, y, x+cos(dir)*radius, y+sin(dir)*radius);
  }
}


class NPCController {
  void update() {
    
    for (NPC npc : npcs) {
      // Do meaningful things in these states
      if (npc.state == NPCState.WAITING) {
        npc.state = NPCState.REQUESTING;
      }
      if (npc.state == NPCState.REQUESTING) {
        npc.state = NPCState.LEAVING;
      }
    }
  }
}