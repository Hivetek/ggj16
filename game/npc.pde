ArrayList<NPC> npcs = new ArrayList<NPC>();

enum NPCState {
  ENTERING, 
  LEAVING,
  WAITING_OUTSIDE,
  WATINIG,
  REQUESTING
};

  class NPC {
  float x;
  float y;
  float vx;
  float vy;
  float dir = 0;

  int radius = 20;

  int speed = 2;

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
      state = NPCState.LEAVING;
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
        state = NPCState.LEAVING;
      }
    } else if (state == NPCState.LEAVING) {
      float dx = seat.door.x - x;
      float dy = seat.door.y - y;
      float dist = sqrt(dx*dx + dy*dy);
      x += (dx/dist)*speed;
      y += (dy/dist)*speed;
      
      if (dist < 1) {
        state = NPCState.ENTERING;
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