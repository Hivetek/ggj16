ArrayList<Table> tables = new ArrayList<Table>();
ArrayList<Seat> seats = new ArrayList<Seat>();
ArrayList<Door> doors = new ArrayList<Door>();


class Table {
  int x;
  int y;

  int w;
  int h;

  Table(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;

    this.w = w;
    this.h = h;
  }
}

class Seat {
  int radius = 16;
  int x;
  int y;

  Door door;

  Seat(int x, int y) {
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

    fill(255, 255, 255);
    ellipse(x, y, radius, radius);

    if (door != null) {
      line(x, y, door.x, door.y);
    }

    popStyle();
  }
}

class Door {
  int w = 50;
  int h = 5;
  int x;
  int y;
  boolean horizontal;

  Door(int x, int y, boolean horizontal) {
    this.x = x;
    this.y = y;
    this.horizontal = horizontal;
  }

  void render() {
    pushStyle();

    fill(255, 255, 255);
    if (horizontal) {
      rect(x - w/2, y - h/2, x + w/2, y + h/2);
    } else {
      rect(x - h/2, y - w/2, x + h/2, y + w/2);
    }

    popStyle();
  }
}




void initScenery() {
  // Doors
  doors.add(new Door(50, 10, true));
  
  doors.add(new Door(10, 50, false));

  // Seats
  for (int i = 0; i < 10; i++) {
    seats.add(new Seat(width/2 - i*40, height/2));
  }
  
  
  // Find doors for seats
  for (Seat seat : seats) {
    seat.findDoor(); 
  }
}



class NPC {
  Seat seat;
}