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
Player[] players = new Player[2];


void setup() {
  size(1280, 720);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);

  players[0] = new Player(0, width/2, height/2);
  players[1] = new Player(1, width/2, height/2);

  initInputBuffer();

  for (int i = 0; i < obstacles.length; i++) {
    obstacles[i] = new Obstacle(random(width), random(height), 1);
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
    p.drunk = 1.0*mouseX/width;
    p.update();
  }
}

void render() {
  background(0);

  for (Player p : players) {
    p.render();
  }

  for (int i = 0; i < obstacles.length; i++) {
    obstacles[i].render();
  }

  // --- HUD ---
  for (Player p : players) {
    pushStyle();

    // Drunk-meter
    int drunk_meter_width = 100;
    int drunk_meter_height = 10;
    float drunk_meter_x = p.x - drunk_meter_width / 2;
    float drunk_meter_y = p.y - p.radius*2 - drunk_meter_height;

    stroke(59.2, 2.7, 0.8);
    noFill();
    rect(drunk_meter_x, drunk_meter_y, drunk_meter_width, drunk_meter_height);
    fill(59.2, 2.7, 0.8);
    rect(drunk_meter_x, drunk_meter_y, min(p.drunk*drunk_meter_width, drunk_meter_width), drunk_meter_height);

    popStyle();

    pushStyle();

    // Drunk-meter
    int bladder_meter_width = 100;
    int bladder_meter_height = 10;
    float bladder_meter_x = p.x - bladder_meter_width / 2;
    float bladder_meter_y = p.y - p.radius*2 - drunk_meter_height - 5 - bladder_meter_height;
    stroke(90.2, 90.2, 0);
    noFill();
    rect(bladder_meter_x, bladder_meter_y, bladder_meter_width, bladder_meter_height);
    fill(90.2, 90.2, 0);
    rect(bladder_meter_x, bladder_meter_y, min(p.bladder*bladder_meter_width, bladder_meter_width), bladder_meter_height);

    popStyle();
  }
}

int sign(float n) {
  return round(n/abs(n));
}