import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;*/

Player player;
Obstacle[] obstacles = new Obstacle[45];

void setup(){
  size(1280, 720);
  frameRate(60);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);
  
  player = new Player(width/2, height/2);
  
  initInputBuffer();
  
  for(int i = 0; i < obstacles.length; i++){
    obstacles[i] = new Obstacle(random(width), random(height), 1);
    obstacles[i].w = 16+random(32);
    obstacles[i].h = 16+random(32);
    obstacles[i].r = 8+random(24);
  }
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
  for(int i = 0; i < obstacles.length; i++){
    obstacles[i].render();
  }
  rect(0, 10, player.drunk*width, 20);
  line(0, 10, player.drunk*width, 10);
}

int sign(float n){
  return round(n/abs(n));
}