import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
 import org.gamecontrolplus.*;
 import org.gamecontrolplus.gui.*;*/

boolean DEBUG = false;

PFont comicFont;
PFont talkFont;
PFont regularFont; 
PImage bgImage, smallTableImage, bigTableImage; //150x121, 203x164 

Obstacle[] obstacles = new Obstacle[22];

Player[] players = new Player[4];


void setup() {
  size(1280, 720);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);

  comicFont = loadFont("data/fonts/ComicaBDBold-48.vlw");
  talkFont = loadFont("data/fonts/Talkies-60.vlw");
  regularFont = loadFont("data/fonts/ArialMT-12.vlw");

  bgImage = loadImage("data/images/floor.png");
  smallTableImage = loadImage("data/images/table_small.png");
  bigTableImage = loadImage("data/images/table_big.png");
  textAlign(CENTER, CENTER);
  textFont(comicFont);

  players[0] = new Player(0, 60, 60, false); // Arrows
  players[1] = new Player(1, width-60, height-60, false); // WASD
  players[2] = new Player(2, width-60, 60, false); // IJKL
  players[3] = new Player(3, 60, height - 60, false); // Numpad

  initInputBuffer();
  initScenery();



  /*
  //LEVEL DESIGN
   //table
   obstacles[0] = new Obstacle(width/2, height/2, 1);
   obstacles[0].w = 400;
   obstacles[0].h = 180;
   
   //Seats
   for (int i = 1; i < 10; i++) {
   obstacles[i] = new Obstacle(width/2-180+45*(i-1), height/2-110, 0);
   }
   for (int i = 10; i < 19; i++) {
   obstacles[i] = new Obstacle(width/2-180+45*(i-10), height/2+110, 0);
   }
   
   obstacles[19] = new Obstacle(180, height/2, 1);
   obstacles[19].w = 60;
   obstacles[19].h = 120;
   
   obstacles[20] = new Obstacle(130, height/2+30, 0);
   obstacles[21] = new Obstacle(130, height/2-30, 0);
   */
}

void draw() {  
  update();
  render();
}

void update() {
  goToNextInput();

  for (NPC npc : npcs) {
    npc.update();
  }

  npccontroller.update();

  for (Player p : players) {
    //p.drunk = 1.0*mouseX/width;
    p.update();
  }
}

void render() {

  image(bgImage, 0, 0);

  for (Seat seat : seats) {
    seat.render();
  }

  for (STable table : tables) {
    table.render();
  }

  for (Door door : doors) {
    door.render();
  }

  for (NPC npc : npcs) {
    npc.render();
  }

  for (Player p : players) {
    p.render();
  }

  if (DEBUG) {
    for (Obstacle obstacle : staticObstacles) {
      obstacle.render();
    }
  }
}

int sign(float n) {
  return round(n/abs(n));
}

void drawText(String text, float x, float y, float a, float s) {
  translate(x, y);
  scale(s);
  rotate(a);
  text(text, 0, 0);
  resetMatrix();
}