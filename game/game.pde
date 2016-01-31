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

boolean paused = true;

PFont comicFont;
PFont talkFont;
PFont regularFont; 
PFont emojiFont;
PFont introFont; 

PImage bgImage, smallTableImage, bigTableImage, commanderTableImage, fratBroImage1, fratBroImage2, fratBroImage3, shadow, bunny1, bunny2, bunny3, bunny4, bunny1dead, bunny2dead, bunny3dead, bunny4dead, beerImage, shoeImage, beerstationImage, beerIconImage, guardImage;  

Obstacle[] obstacles = new Obstacle[22];

Player[] players = new Player[4];
Player winningPlayer;

int activePlayers = 0;
int activeRequests = 0;

int spawnNPC = 0;

Minim minim; // Audio context

float countdown = 5.0;

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
  guardImage = loadImage("data/images/commander.png");

  textAlign(CENTER, CENTER);
  textFont(comicFont);

  players[0] = new Player(0, 90, 150, false); // Arrows
  players[1] = new Player(1, width-90, height-150, false); // WASD
  players[2] = new Player(2, width-90, 150, false); // IJKL
  players[3] = new Player(3, 90, height - 150, false); // Numpad

  initInputBuffer();
  initScenery();

  minim = new Minim(this);

  initSound();
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
  case END:
    showEnd();
    break;
  }
}

void update() {
  goToNextInput();

  if (paused)
    return;

  while (spawnNPC > 0) {
    spawnNPC--;
    int i = 0;
    while (i < seats.size()-1 && seatIsOccupied(seats.get(i))) {
      i++;
    }
    if (!seatIsOccupied(seats.get(i)))
      npcs.add(new NPC(seats.get(i), true, 0));
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

  for (Seat seat : guardSeats) {
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

  if (paused) {
    int n = 0;
    for (Player p : players) {
      if (p.active)
        n++;
    }

    if (n > 1)
      countdown -= 1.0/60.0;

    noStroke();
    fill(0, 0, 0, 128);
    rect(0, 0, width, height);

    drawKeys(0, 100, 100);
    drawKeys(1, width-100, height-100);
    drawKeys(2, width-100, 100);
    drawKeys(3, 100, height-100);

    fill(255);
    textFont(introFont);
    text("WAITING FOR PLAYERS...", width/2, height/2-80);

    if (countdown < 5.0)
      text(ceil(countdown), width/2, height/2+80);

    if (countdown <= 0.0)
      paused = false;
  }
}

void drawKeys(int id, float x, float y) {
  if (players[id].active)
    fill(255, 255, 255, 220);
  else fill(255, 255, 255, 128);
  rect(x-35, y, 30, 30);
  rect(x, y, 30, 30);
  rect(x+35, y, 30, 30);
  rect(x, y-35, 30, 30);

  fill(0);
  textFont(regularFont);
  switch(id) {
  case 0:
    text("<", x-35+15, y+15);
    text("v", x+15, y+15);
    text(">", x+35+15, y+15);
    text("^", x+15, y-35+15);
    break;
  case 1:
    text("A", x-35+15, y+15);
    text("S", x+15, y+15);
    text("D", x+35+15, y+15);
    text("W", x+15, y-35+15);
    break;
  case 2:
    text("J", x-35+15, y+15);
    text("K", x+15, y+15);
    text("L", x+35+15, y+15);
    text("I", x+15, y-35+15);
    break;
  case 3:
    text("4", x-35+15, y+15);
    text("5", x+15, y+15);
    text("6", x+35+15, y+15);
    text("8", x+15, y-35+15);
    break;
  default:
    break;
  }
}

void decideWinning() {
  ArrayList<Player> alivePlayers = new ArrayList<Player>();
  int deadCount = 0;
  for (Player p : players) {
    if (p.active) {
      if (!p.dead) {
        alivePlayers.add(p);
      } else {
        deadCount++;
      }
    }
  }
  if (deadCount >= 0 && alivePlayers.size() == 1) {
    winningPlayer = alivePlayers.get(0);
    changeDisplay(Display.END);
  }
}

void resetGame() {
  // TODO: Reset game to initial condition
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