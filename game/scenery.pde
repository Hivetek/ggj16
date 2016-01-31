ArrayList<STable> tables = new ArrayList<STable>();
ArrayList<Seat> seats = new ArrayList<Seat>();
ArrayList<Seat> guardSeats = new ArrayList<Seat>();
ArrayList<Door> doors = new ArrayList<Door>();
ArrayList<BeerStation> beerstations = new ArrayList<BeerStation>();
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
  Obstacle assocObstacle;
  int img = 0;

  STable(float x, float y, TableType type) {
    this.x = x;
    this.y = y;

    this.type = type;
    this.img = round(random(2.0));

    switch (type) {
    case SMALL:
      this.w = 150;
      this.h = 121;
      break;
    case BIG:
      this.w = 203;
      this.h = 164;
      break;
    case COMMANDER:
      this.w = 44;
      this.h = 121;
    }

    this.assocObstacle = createObstacle();
  }

  void render() {
    switch (this.type) {
    case SMALL:
      image(smallTableImages[img], x-w/2-3, y-h/2-4);
      break;
    case BIG:
      image(bigTableImage, x-w/2-6, y-h/2-8);
      break;
    case COMMANDER:
      image(commanderTableImage, x-w/2-5, y-h/2-7);
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
    if (DEBUG) {
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
    if (DEBUG) {
      pushStyle();
      noFill();
      stroke(255);
      if (horizontal) {
        rect(x - w/2, y - h/2, w, h);
      } else {
        rect(x - h/2, y - w/2, h, w);
      }

      ellipse(x, y, 30, 30);

      popStyle();
    }
  }
}


class BeerStation {
  float x;
  float y;

  float w = 95;
  float h = 40;

  Obstacle assocObstacle;

  BeerStation(float x, float y) {
    this.x = x;
    this.y = y;

    this.assocObstacle = createObstacle();
  }

  void render() {
    image(beerstationImage, x-w/2, y-h/2-7);
  }


  Obstacle createObstacle() {
    Obstacle o = new Obstacle(x, y, 1);
    o.w = w;
    o.h = h;
    return o;
  }
}


// -----------------------------------------------------------

void initScenery() {
  // Tables
  int table1dx = -15;
  int table1dy = -15;
  int table2dx = -15;
  int table2dy = 15;
  int table3dx = 15;
  int table3dy = -15;
  int table4dx = 15;
  int table4dy = 15;

  // Center table
  tables.add(new STable(width/2, height/2, TableType.BIG));

  // Commander table
  //tables.add(new STable(60 + 70, height/2 + 15, TableType.COMMANDER));

  // Four smaller tables
  tables.add(new STable(60 + 275 + table1dx, 60 + 180 + table1dy, TableType.SMALL));
  tables.add(new STable(60 + 275 + table2dx, height - 60 - 180 + table2dy, TableType.SMALL));
  tables.add(new STable(width - 60 - 275 + table3dx, 60 + 180 + table3dy, TableType.SMALL));
  tables.add(new STable(width - 60 - 275 + table4dx, height - 60 - 180 + table4dy, TableType.SMALL));

  for (STable table : tables) {
    staticObstacles.add(table.assocObstacle);
  }

  beerstations.add(new BeerStation(120, 95));
  beerstations.add(new BeerStation(120, 630));
  beerstations.add(new BeerStation(1160, 95));
  beerstations.add(new BeerStation(1160, 630));

  for (BeerStation beerstation : beerstations) {
    staticObstacles.add(beerstation.assocObstacle);
  }

  // Doors
  doors.add(new Door(width/2, 56, true));
  doors.add(new Door(width/2, height-56, true));
  doors.add(new Door(width-56, height/2, false));
  doors.add(new Door(56, height/3-5, false));
  doors.add(new Door(56, 2*height/3+18, false));

  // --- Seats ---


  // Center table
  seats.add(new Seat(510, 310));
  seats.add(new Seat(510, 366));
  seats.add(new Seat(510, 415));

  seats.add(new Seat(770, 310));
  seats.add(new Seat(770, 366));
  seats.add(new Seat(770, 415));

  seats.add(new Seat(575, 255));
  seats.add(new Seat(640, 255));
  seats.add(new Seat(700, 255));

  seats.add(new Seat(575, 465));
  seats.add(new Seat(640, 465));
  seats.add(new Seat(700, 465));

  // Top left table, 1
  seats.add(new Seat(235 + table1dx, 215 + table1dy));
  seats.add(new Seat(235 + table1dx, 270 + table1dy));
  seats.add(new Seat(295 + table1dx, 150 + table1dy));
  seats.add(new Seat(370 + table1dx, 150 + table1dy)); 
  seats.add(new Seat(440 + table1dx, 215 + table1dy));
  seats.add(new Seat(440 + table1dx, 270 + table1dy));
  seats.add(new Seat(295 + table1dx, 325 + table1dy));
  seats.add(new Seat(370 + table1dx, 325 + table1dy));

  // Bottom left table, 2
  seats.add(new Seat(235 + table2dx, 450 + table2dy));
  seats.add(new Seat(235 + table2dx, 510 + table2dy));
  seats.add(new Seat(295 + table2dx, 390 + table2dy));
  seats.add(new Seat(370 + table2dx, 390 + table2dy));
  seats.add(new Seat(440 + table2dx, 450 + table2dy));
  seats.add(new Seat(440 + table2dx, 510 + table2dy));
  seats.add(new Seat(295 + table2dx, 560 + table2dy));
  seats.add(new Seat(370 + table2dx, 560 + table2dy));

  // Top right table, 3
  seats.add(new Seat(840 + table3dx, 215 + table3dy));
  seats.add(new Seat(840 + table3dx, 270 + table3dy));
  seats.add(new Seat(905 + table3dx, 150 + table3dy));
  seats.add(new Seat(980 + table3dx, 150 + table3dy));
  seats.add(new Seat(1050 + table3dx, 215 + table3dy));
  seats.add(new Seat(1050 + table3dx, 270 + table3dy));
  seats.add(new Seat(905 + table3dx, 325 + table3dy));
  seats.add(new Seat(980 + table3dx, 325 + table3dy));

  // Bottom right table, 4
  seats.add(new Seat(845 + table4dx, 450 + table4dy));
  seats.add(new Seat(845 + table4dx, 510 + table4dy));
  seats.add(new Seat(905 + table4dx, 395 + table4dy));
  seats.add(new Seat(980 + table4dx, 395 + table4dy));
  seats.add(new Seat(1050 + table4dx, 450 + table4dy));
  seats.add(new Seat(1050 + table4dx, 510 + table4dy));
  seats.add(new Seat(905 + table4dx, 565 + table4dy));
  seats.add(new Seat(980 + table4dx, 565 + table4dy));


  // Guard seats
  guardSeats.add(new Seat(90, 435));
  guardSeats.add(new Seat(715, 625));
  guardSeats.add(new Seat(90, 290));
  guardSeats.add(new Seat(570, 90));
  guardSeats.add(new Seat(1185, 290));



  // Find doors for seats
  for (Seat seat : seats) {
    seat.findDoor();
  }
  for (Seat seat : guardSeats) {
    seat.findDoor();
  }


  // Initial NPC fratBros
  for (int i = 0; i < 8; i++) {
    npcs.add(new NPC(seats.get(i), false, 0));
  }

  //Initial NPC guards
  for (int i = 0; i < guardSeats.size(); i++) {
    npcs.add(new NPC(guardSeats.get(i), false, 1));
  }
}

boolean seatIsOccupied(Seat seat) {
  for (NPC npc : npcs) {
    if (npc.seat == seat && (npc.state == NPCState.WAITING || npc.state == NPCState.ENTERING || npc.state == NPCState.REQUESTING)) {
      return true;
    }
  }

  return false;
}