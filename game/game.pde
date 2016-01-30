import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
 import org.gamecontrolplus.*;
 import org.gamecontrolplus.gui.*;*/

Obstacle[] obstacles = new Obstacle[45];
Player[] players = new Player[4];


void setup() {
  size(1280, 720);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);

  players[0] = new Player(0, width/2+30, height/2, false); // Arrows
  players[1] = new Player(1, width/2-30, height/2, false); // WASD
  players[2] = new Player(2, width/2+60, height/2, false); // IJKL
  players[3] = new Player(3, width/2-60, height/2, false); // Numpad

  initInputBuffer();

  for (int i = 0; i < obstacles.length; i++) {
    obstacles[i] = new Obstacle(random(width), random(height), round(random(1)));
    obstacles[i].w = 16+random(32);
    obstacles[i].h = 16+random(32);
    obstacles[i].r = 8+random(24);
  }
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