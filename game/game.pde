import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;*/

float moveSpeed = 2.8;
float turnSpeed = 0.08;
float radius = 16;

float px, py, x, y, dir;
float dirOffset = 0.0;

float drunk = 0.0;

void setup(){
  size(640, 480);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);
  px = x = 320;
  py = y = 240;
  dir = -PI/2;
  
  initInputBuffer();
}

void draw(){  
  update();
  render();
}

void update(){
  goToNextInput();
  
  drunk = 1.0*mouseX/width;
  
  float direction = dir + drunk*0.4*PI*cos(dirOffset);
  if(currentInput().isPressed(LEFT)){
    dir -= turnSpeed;
  }
  if(currentInput().isPressed(RIGHT)){
    dir += turnSpeed;
  }
  if(currentInput().isPressed(UP)){
    x += cos(direction)*moveSpeed;
    y += sin(direction)*moveSpeed;
  }
  if(currentInput().isPressed(DOWN)){
    x -= cos(direction)*moveSpeed;
    y -= sin(direction)*moveSpeed;
  }
  
  float dx = x-px;
  float dy = y-py;
  float dist = drunk*0.02*sqrt(dx*dx+dy*dy);
  dirOffset += dist;
  if(dirOffset > PI*2) dirOffset -= PI*2;
  
  x = min(max(radius, x), width-radius);
  y = min(max(radius, y), height-radius);
  
  px = x;
  py = y;
}

void render(){
  float direction = dir + drunk*0.4*PI*cos(dirOffset);
  background(0);
  noFill();
  ellipse(x, y, radius, radius);

  line(x, y, x+cos(direction)*radius, y+sin(direction)*radius);
  
  fill(255);
  ellipse(200, 350, 30, 30);
  ellipse(340, 350, 30, 30);
  rect(0, 10, drunk*width, 20);
  line(0, 10, drunk*width, 10);
}