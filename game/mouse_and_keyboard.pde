/**** DECLARATIONS ****/

int NUM_INPUT = 16;


class Input {
  int id = 0;
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
  Input oldInput = currentInput();
  Input newInput = oldInput.clone();
  newInput.id = oldInput.id + 1;
  int newInputPointer = (currentInputPointer + 1) % inputBuffer.length;
  inputBuffer[newInputPointer] = newInput;
  currentInputPointer = newInputPointer;
}

Input getPastInput(int num) {
  if (num <= 0) {
    return inputBuffer[currentInputPointer];
  } else if (num >= inputBuffer.length) {
    return inputBuffer[(currentInputPointer+1)%inputBuffer.length];
  } else {
    return inputBuffer[(currentInputPointer-num)%inputBuffer.length];
  }
}



void initInputBuffer() {
  for (int i = 0; i < inputBuffer.length; i++) {
    inputBuffer[i] = new Input();
  } 
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