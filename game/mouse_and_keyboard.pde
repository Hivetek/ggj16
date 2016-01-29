/**** DECLARATIONS ****/
boolean lmb, rmb, mmb;
boolean keys[] = new boolean[65535];

class Input {
  boolean lmb, rmb, mmb;
  boolean keys[] = new boolean[65535];
  boolean coded[] = new boolean[65535];
  
  Input() {}
  
  Input clone() {
    Input newInput = new Input();
    newInput.lmb = lmb;
    newInput.rmb = rmb;
    newInput.mmb = mmb;
    arrayCopy(keys, newInput.keys);
    arrayCopy(coded, newInput.coded);
    return newInput;
  }
  
  boolean isPressed(int key) {
    return coded[key] || keys[key];
  }
}

Input currentInput = new Input();

Input inputBuffer[] = new Input[3];

void mousePressed() {
  if (mouseButton == LEFT) {
    currentInput.lmb = true;
  } else if (mouseButton == RIGHT) {
    currentInput.rmb = true;
  } else if (mouseButton == CENTER) {
    currentInput.mmb = true;
  }
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
    currentInput.lmb = false;
  } else if (mouseButton == RIGHT) {
    currentInput.rmb = false;
  } else if (mouseButton == CENTER) {
    currentInput.mmb = false;
  }
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
  println(keyCode);
  if (key == CODED) {
    currentInput.coded[keyCode] = true;
  } else {
    currentInput.keys[key] = true;
  }
  if (key == CODED) {
    keys[255+keyCode] = true;
  } else {
    keys[key] = true;
  }
}

void keyReleased() {
  if (key == CODED) {
    currentInput.coded[keyCode] = false;
  } else {
    currentInput.keys[key] = false;
  }
  if (key == CODED) {
    keys[255+keyCode] = false;
  } else {
    keys[key] = false;
  }
}