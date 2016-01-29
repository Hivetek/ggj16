/**** DECLARATIONS ****/

int NUM_INPUT = 16;


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

Input inputBuffer[] = new Input[NUM_INPUT];
int currentInputPointer = 0;



Input currentInput() {
  return inputBuffer[currentInputPointer];
}

void goToNextInput() {
  Input oldInput = currentInput().clone();
  int newInputPointer = (currentInputPointer + 1) % inputBuffer.length;
  inputBuffer[newInputPointer] = oldInput;
  currentInputPointer = newInputPointer;
}

void mousePressed() {
  if (mouseButton == LEFT) {
    currentInput().lmb = true;
  } else if (mouseButton == RIGHT) {
    currentInput().rmb = true;
  } else if (mouseButton == CENTER) {
    currentInput().mmb = true;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    currentInput().lmb = false;
  } else if (mouseButton == RIGHT) {
    currentInput().rmb = false;
  } else if (mouseButton == CENTER) {
    currentInput().mmb = false;
  }
}

/**** KEYBOAD ****/
void keyPressed() {
  if (key == CODED) {
    currentInput().coded[keyCode] = true;
  } else {
    currentInput().keys[key] = true;
  }
}

void keyReleased() {
  if (key == CODED) {
    currentInput().coded[keyCode] = false;
  } else {
    currentInput().keys[key] = false;
  }
}