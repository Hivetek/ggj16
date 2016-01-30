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

void setup(){
  size(1280, 720);
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
  
  
  // --- HUD ---
  
  pushStyle();
  
  // Drunk-meter
  int drunk_meter_width = 100;
  int drunk_meter_height = 10;
  stroke(59.2, 2.7, 0.8);
  noFill();
  rect(player.x - drunk_meter_width / 2, player.y - player.radius*2 - drunk_meter_height, drunk_meter_width, drunk_meter_height);
  fill(59.2, 2.7, 0.8);
  rect(player.x - drunk_meter_width / 2, player.y - player.radius*2 - drunk_meter_height, min(player.drunk*drunk_meter_width, drunk_meter_width), drunk_meter_height);
  
  popStyle();
  
  pushStyle();
  
  // Drunk-meter
  int bladder_meter_width = 100;
  int bladder_meter_height = 10;
  stroke(   90.2, 90.2, 0);
  noFill();
  rect(player.x - bladder_meter_width / 2, player.y - player.radius*2 - drunk_meter_height - 5 - bladder_meter_height, bladder_meter_width, bladder_meter_height);
  fill(   90.2, 90.2, 0);
  rect(player.x - bladder_meter_width / 2, player.y - player.radius*2 - drunk_meter_height - 5 - bladder_meter_height, min(player.bladder*bladder_meter_width, bladder_meter_width), bladder_meter_height);
  
  popStyle();
}