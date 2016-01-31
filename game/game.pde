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
PFont emojiFont;
PFont introFont; 

PImage bgImage, smallTableImage, bigTableImage, commanderTableImage, fratBroImage1, fratBroImage2, fratBroImage3, shadow, bunny1, bunny2, bunny3, bunny4, bunny1dead, bunny2dead, bunny3dead, bunny4dead, beerImage, shoeImage, beerstationImage, beerIconImage;  

Obstacle[] obstacles = new Obstacle[22];

Player[] players = new Player[4];

int activePlayers = 0;
int activeRequests = 0;

int spawnNPC = 0;

AudioPlayer player;
Minim minim; // Audio context

void setup() {
  size(1280, 720);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);

  //FONTS
  comicFont = loadFont("data/fonts/ComicaBDBold-48.vlw");
  talkFont = loadFont("data/fonts/Talkies-60.vlw");
  regularFont = loadFont("data/fonts/ArialMT-12.vlw");
  emojiFont = loadFont("data/fonts/Emoticons-28.vlw");
  introFont = loadFont("data/fonts/FreeMono-48.vlw");

  //IMAGES
  bgImage = loadImage("data/images/floor.png");
  smallTableImage = loadImage("data/images/table_small.png");
  bigTableImage = loadImage("data/images/table_big.png");
  commanderTableImage = loadImage("data/images/commander_table_54x132.png");
  fratBroImage1 = loadImage("data/images/frat_bro_1.png");
  fratBroImage2 = loadImage("data/images/frat_bro_2.png");
  fratBroImage3 = loadImage("data/images/frat_bro_3.png");
  bunny1 = loadImage("data/images/bunny_1.png");
  bunny2 = loadImage("data/images/bunny_2.png");
  bunny3 = loadImage("data/images/bunny_3.png");
  bunny4 = loadImage("data/images/bunny_4.png");
  bunny1dead = loadImage("data/images/bunny_1_dead.png");
  bunny2dead = loadImage("data/images/bunny_2_dead.png");
  bunny3dead = loadImage("data/images/bunny_3_dead.png");
  bunny4dead = loadImage("data/images/bunny_4_dead.png");
  shadow = loadImage("data/images/shadow.png");
  beerImage = loadImage("data/images/big_beer_left.png");
  shoeImage = loadImage("data/images/shoe.png");
  beerstationImage = loadImage("data/images/station.png");
  beerIconImage = loadImage("data/images/beer_icon.png");

  textAlign(CENTER, CENTER);
  textFont(comicFont);

  players[0] = new Player(0, 90, 150, false); // Arrows
  players[1] = new Player(1, width-90, height-150, false); // WASD
  players[2] = new Player(2, width-90, 150, false); // IJKL
  players[3] = new Player(3, 90, height - 150, false); // Numpad

  initInputBuffer();
  initScenery();
  
  minim = new Minim(this);
  
  // Start intro beat
  player = minim.loadFile("data/sound/Frat-Trap-Intro-Beat.mp3", 2048);
  player.play();
}

void draw() {
  switch(display) {
    case GAME:
      update();
      render();
      break;
    case TITLESCREEN:
      showTitlescreen();
      break;
   case INTRO:
      showIntro();
      break;
   case INSTRUCTIONS:
      showInstructions();
      break;
  }
}

void update() {
  goToNextInput();

  while (spawnNPC > 0) {
    spawnNPC--;
    int i = 0;
    while (i < seats.size()-1 && seatIsOccupied(seats.get(i))) {
      i++;
    }
    if (!seatIsOccupied(seats.get(i)))
      npcs.add(new NPC(seats.get(i), true));
  }

  for (NPC npc : npcs) {
    npc.update();
  }

  for (Player p : players) {
    p.update();
  }
}

void render() {

  image(bgImage, 0, 0);

  for (Seat seat : seats) {
    seat.render();
  }

  for (Player p : players) {
    if (p.dead)
      p.render();
  }

  for (STable table : tables) {
    table.render();
  }

  for (BeerStation beerstation : beerstations) {
    beerstation.render();
  }

  for (Door door : doors) {
    door.render();
  }

  for (NPC npc : npcs) {
    npc.render();
  }

  for (Player p : players) {
    if (!p.dead)
      p.render();
  }
  
  //---- HUD ----
  for (NPC npc : npcs) {
    npc.renderHUD();
  }
  
  for (Player p : players) {
    if (!p.dead)
      p.renderHUD();
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