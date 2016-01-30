ArrayList<STable> tables = new ArrayList<STable>();
ArrayList<Seat> seats = new ArrayList<Seat>();
ArrayList<Door> doors = new ArrayList<Door>();
ArrayList<Obstacle> staticObstacles = new ArrayList<Obstacle>();



class STable {
  float x;
  float y;

  float w;
  float h;

  STable(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;

    this.w = w;
    this.h = h;
  }

  void render() {
    pushStyle();

    fill(255, 255, 255);
    rect(x-w/2, y-h/2, w, h);

    popStyle();
  }

  Obstacle createObstacle() {
    Obstacle o = new Obstacle(x, y, 1);
    o.w = w;
    o.h = h;
    return o;
  }
}

class Seat {
  float radius = 16;
  float x;
  float y;

  Door door;

  Seat(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void findDoor() {
    Door bestDoor = null;
    float bestDist = 99999999;
    for (Door door : doors) {
      float dx = x - door.x;
      float dy = y - door.y;
      float dist = sqrt(dx*dx + dy*dy);
      if (dist < bestDist) {
        bestDoor = door;
        bestDist = dist;
      }
    }

    if (bestDoor == null) {
      println("Error: Could not find door for seat");
    }

    this.door = bestDoor;
  }

  void render() {
    pushStyle();
    stroke(255);
    fill(255, 255, 255);
    ellipse(x, y, radius, radius);

    if (door != null) {
      line(x, y, door.x, door.y);
    }

    popStyle();
  }
}

class Door {
  float w = 75;
  float h = 5;
  float x;
  float y;
  boolean horizontal;

  Door(float x, float y, boolean horizontal) {
    this.x = x;
    this.y = y;
    this.horizontal = horizontal;
  }

  void render() {
    pushStyle();
    noFill();
    stroke(255);
    if (horizontal) {
      rect(x - w/2, y - h/2, w, h);
    } else {
      rect(x - h/2, y - w/2, h, w);
    }

    popStyle();
  }
}

void initScenery() {
  // Tables
  tables.add(new STable(500, 400, 300, 200));

  for (STable table : tables) {
    staticObstacles.add(table.createObstacle());
  }

  // Doors
  doors.add(new Door(width/2, 56, true));
  doors.add(new Door(width/2, height-56, true));
  doors.add(new Door(width-56, height/2, false));
  doors.add(new Door(56, height/3-5, false));
  doors.add(new Door(56, 2*height/3+18, false));

  // Seats
  for (int i = 0; i < 10; i++) {
    seats.add(new Seat(random(width), random(height)));
  }


  // Find doors for seats
  for (Seat seat : seats) {
    seat.findDoor();
  }


  // Initial NPCS
  npcs.add(new NPC(seats.get(0), true));
  npcs.add(new NPC(seats.get(1), true));
  npcs.add(new NPC(seats.get(2), true));
  npcs.add(new NPC(seats.get(3), true));
  npcs.add(new NPC(seats.get(4), true));
}