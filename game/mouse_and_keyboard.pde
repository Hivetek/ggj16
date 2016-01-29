/**** DECLARATIONS ****/
boolean lmb, rmb, mmb;
boolean keys[] = new boolean[65535];

void mousePressed() {
  if (mouseButton == LEFT) {
    lmb = true;
  } 
  else if (mouseButton == RIGHT) {
    rmb = true;
  } 
  else if (mouseButton == CENTER) {
    mmb = true;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    lmb = false;
  } 
  else if (mouseButton == RIGHT) {
    rmb = false;
  } 
  else if (mouseButton == CENTER) {
    mmb = false;
  }
}

/**** KEYBOAD ****/
void keyPressed() {
  if (key == CODED) {
    keys[255+keyCode] = true;
  } else {
    keys[key] = true;
  }
  if(key == ESC){
    key = 0;
    if(paused){
      paused = false;
      noCursor();
    } else {
      paused = true;
      cursor(ARROW);
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    keys[255+keyCode] = false;
  } else {
    keys[key] = false;
  }
}