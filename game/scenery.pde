ArrayList<STable> tables = new ArrayList<STable>();
ArrayList<Seat> seats = new ArrayList<Seat>();
ArrayList<Door> doors = new ArrayList<Door>();
ArrayList<Obstacle> staticObstacles = new ArrayList<Obstacle>();


enum TableType {
  COMMANDER,
  SMALL,
  BIG
};

class STable {
  float x;
  float y;

  float w;
  float h;
  
  TableType type;

  STable(float x, float y, TableType type) {
    this.x = x;
    this.y = y;
    
    this.type = type;

    switch (type) {
      case SMALL:
        this.w = 150;
        this.h = 121;
        break;
      case BIG:
        this.w = 203;
        this.h = 164;
        break;
    }
  }

  void render() {
    switch (this.type) {
      case SMALL:
        image(smallTableImage, x-w/2-3, y-h/2-4);
        break;
      case BIG:
        image(bigTableImage, x-w/2-6, y-h/2-8);
        break;
    }

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

  // Center table
  tables.add(new STable(width/2, height/2, TableType.BIG));

  // Commander table
  //tables.add(new STable(60 + 70, height/2, TableType.COMMANDER));

  // Four smaller tables
  tables.add(new STable(60 + 275, 60 + 180, TableType.SMALL));
  tables.add(new STable(width - 60 - 275, 60 + 180, TableType.SMALL));
  tables.add(new STable(60 + 275, height - 60 - 180, TableType.SMALL));
  tables.add(new STable(width - 60 - 275, height - 60 - 180, TableType.SMALL));

  for (STable table : tables) {
    staticObstacles.add(table.createObstacle());
  }

  // Doors
  doors.add(new Door(width/2, 56, true));
  doors.add(new Door(width/2, height-56, true));
  doors.add(new Door(width-56, height/2, false));
  doors.add(new Door(56, height/3-5, false));
  doors.add(new Door(56, 2*height/3+18, false));

  // --- Seats ---
  
  // Top left table
  seats.add(new Seat(235, 215));
  seats.add(new Seat(235, 270));
  seats.add(new Seat(295, 150));
  seats.add(new Seat(370, 150)); 
  seats.add(new Seat(440, 215));
  seats.add(new Seat(440, 270));
  seats.add(new Seat(295, 325));
  seats.add(new Seat(370, 325));
  
  // Bottom left table
  seats.add(new Seat(235, 450));
  seats.add(new Seat(235, 510));
  seats.add(new Seat(295, 390));
  seats.add(new Seat(370, 390));
  seats.add(new Seat(440, 450));
  seats.add(new Seat(440, 510));
  seats.add(new Seat(295, 560));
  seats.add(new Seat(370, 560));
  
  // Top right table
  seats.add(new Seat(840, 215));
  seats.add(new Seat(840, 270));
  seats.add(new Seat(905, 150));
  seats.add(new Seat(980, 150));
  seats.add(new Seat(1050, 215));
  seats.add(new Seat(1050, 270));
  seats.add(new Seat(905, 325));
  seats.add(new Seat(980, 325));
  
  // Bottom right table
  seats.add(new Seat(845, 450));
  seats.add(new Seat(845, 510));
  seats.add(new Seat(905, 395));
  seats.add(new Seat(980, 395));
  seats.add(new Seat(1050, 450));
  seats.add(new Seat(1050, 510));
  seats.add(new Seat(905, 565));
  seats.add(new Seat(980, 565));

  // Find doors for seats
  for (Seat seat : seats) {
    seat.findDoor();
  }


  // Initial NPCS
  npcs.add(new NPC(seats.get(0), true));
  npcs.add(new NPC(seats.get(1), true));
  npcs.add(new NPC(seats.get(2), true));
  //npcs.add(new NPC(seats.get(3), true));
  //npcs.add(new NPC(seats.get(4), true));
}

boolean seatIsOccupied(Seat seat) {
  for (NPC npc : npcs) {
    if (npc.seat == seat) {
      return false;
    }
  }
  
  return true;
}