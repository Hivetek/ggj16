import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;*/

final int screenWidth  = 1280;
final int screenHeight = 720;

Player player;

void setup(){
  size(screenWidth, screenHeight);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);
  
  player = new Player(width/2, height/2);
  
  initInputBuffer();
}

void draw(){  
  update();
  render();
}

void update(){
  goToNextInput();
  player.drunk = 1.0*mouseX/width;
  player.update();
}

void render(){
  background(0);
  
  player.render();
  
  fill(255);
  ellipse(200, 350, 30, 30);
  ellipse(340, 350, 30, 30);
  rect(0, 10, player.drunk*width, 20);
  line(0, 10, player.drunk*width, 10);
}