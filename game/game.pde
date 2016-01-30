import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
 import org.gamecontrolplus.*;
 import org.gamecontrolplus.gui.*;*/

Obstacle[] obstacles = new Obstacle[22];
Player[] players = new Player[4];


void setup() {
  size(1280, 720);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);


  players[0] = new Player(0, 60, 60, false); // Arrows
  players[1] = new Player(1, width-60, height-60, false); // WASD
  players[2] = new Player(2, width-60, 60, false); // IJKL
  players[3] = new Player(3, 60, height - 60, false); // Numpad

  initInputBuffer();

  //DEBUG: Random scattered obstacles
  /*for (int i = 0; i < obstacles.length; i++) {
    obstacles[i] = new Obstacle(random(width-180)+90, random(height-180)+90, round(random(1)));
    obstacles[i].w = 16+random(32);
    obstacles[i].h = 16+random(32);
    obstacles[i].r = 8+random(24);
  }*/
  
  
  //LEVEL DESIGN
  //table
  obstacles[0] = new Obstacle(width/2, height/2, 1);
  obstacles[0].w = 400;
  obstacles[0].h = 180;
  
  //Seats
  for(int i = 1; i < 10; i++){
    obstacles[i] = new Obstacle(width/2-180+45*(i-1), height/2-110, 0); 
  }
  for(int i = 10; i < 19; i++){
    obstacles[i] = new Obstacle(width/2-180+45*(i-10), height/2+110, 0); 
  }
  
  obstacles[19] = new Obstacle(180, height/2, 1);
  obstacles[19].w = 60;
  obstacles[19].h = 120;
  
  obstacles[20] = new Obstacle(130, height/2+30, 0);
  obstacles[21] = new Obstacle(130, height/2-30, 0);
}

void draw() {  
  update();
  render();
}

void update() {
  goToNextInput();

  for (Player p : players) {
    //p.drunk = 1.0*mouseX/width;
    p.update();
  }
}

void render() {
  background(0);

  for (Player p : players) {
    p.render();
  }

  for (int i = 0; i < obstacles.length; i++) {
    fill(255);
    obstacles[i].render();
  }
}

int sign(float n) {
  return round(n/abs(n));
}