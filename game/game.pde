import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

/*import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;*/

float moveSpeed = 3.5;
float turnSpeed = 0.08;
float radius = 16;

float x, y, dir;
float dirOffset = 0.0;

void setup(){
  size(640, 480);
  stroke(255);
  noFill();
  ellipseMode(RADIUS);
  x = 320;
  y = 240;
  dir = -PI/2;
}

void draw(){  
  if(currentInput().isPressed(LEFT)){
    dir -= turnSpeed;
  }
  if(currentInput().isPressed(RIGHT)){
    dir += turnSpeed;
  }
  if(currentInput().isPressed(UP)){
    x += cos(dir)*moveSpeed;
    y += sin(dir)*moveSpeed;
  }
  if(currentInput().isPressed(DOWN)){
    x -= cos(dir)*moveSpeed;
    y -= sin(dir)*moveSpeed;
  }
  dir += 0.02*cos(2*PI*millis()/1000);
  background(0);
  ellipse(x, y, radius, radius);
  line(x, y, x+cos(dir)*radius, y+sin(dir)*radius);
}