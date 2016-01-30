class Table {
  int x;
  int y;
  
  int w;
  int h;
  
  Seat[] north_seat;
  Seat[] east_seat;
  Seat[] south_seat;
  Seat[] west_seat;
  
  Table(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    
    this.w = w;
    this.h = h;
    
    north_seat = new Seat[w];
    east_seat  = new Seat[h];
    south_seat = new Seat[w];
    west_seat  = new Seat[h];
  }
}

class Seat {
  
}