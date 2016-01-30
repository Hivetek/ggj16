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
    image(smallTableImage, x-w/2-3, y-h/2-4);
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
    //ellipse(x, y, radius, radius);

    if (door != null) {
      //line(x, y, door.x, door.y);
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

  // Center table
  //tables.add(new STable(width/2, height/2, 180, 180));

  // Commander table
  //tables.add(new STable(60 + 70, height/2, 30, 120));

  // Four smaller tables
  tables.add(new STable(60 + 275, 60 + 180, 150, 121));
  tables.add(new STable(width - 60 - 275, 60 + 180, 150, 121));
  tables.add(new STable(60 + 275, height - 60 - 180, 150, 121));
  tables.add(new STable(width - 60 - 275, height - 60 - 180, 150, 121));

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
  for (int i = 0; i < 50; i++) {
    seats.add(new Seat(random(width), random(height)));
  }


  // Find doors for seats
  for (Seat seat : seats) {
    seat.findDoor();
  }


  // Initial NPCS
  for(int i = 0; i < 49; i++){
    npcs.add(new NPC(seats.get(i), true));
  }
  //npcs.add(new NPC(seats.get(1), true));
  //npcs.add(new NPC(seats.get(2), true));
  //npcs.add(new NPC(seats.get(3), true));
  //npcs.add(new NPC(seats.get(4), true));
}

boolean seatIsOccupied(Seat seat) {
  for (NPC npc : npcs) {
    if (npc.seat == seat && (npc.state == NPCState.WAITING || npc.state == NPCState.ENTERING || npc.state == NPCState.REQUESTING)) {
      return true;
    }
  }
  
  return false;
}