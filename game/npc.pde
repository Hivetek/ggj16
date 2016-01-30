ArrayList<NPC> npcs = new ArrayList<NPC>();

class NPC {
  float x;
  float y;
  float dir = 0;

  int radius = 20;


  Seat seat;

  NPC(Seat seat, boolean startAtDoor) {
    this.seat = seat;
    if (startAtDoor) {
      this.x = seat.door.x;
      this.y = seat.door.y;
    } else {
      this.x = seat.x;
      this.y = seat.y;
    }
  }

  void update() {
  }

  void render() {

    noFill();
    stroke(255);
    ellipse(x, y, radius, radius);

    line(x, y, x+cos(dir)*radius, y+sin(dir)*radius);
  }
}