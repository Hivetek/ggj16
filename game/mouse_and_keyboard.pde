/**** DECLARATIONS ****/

final int NUM_INPUT = 16;
final int KEY_ARRAY_SIZE = 65535;

class Input {
  int id = 0;
  boolean lmb, rmb, mmb;
  boolean keys[] = new boolean[KEY_ARRAY_SIZE];
  boolean coded[] = new boolean[KEY_ARRAY_SIZE];
  
  //Input() {}
  
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
    return inputBuffer[(inputBuffer.length + currentInputPointer - num)%inputBuffer.length];
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
  if (display == Display.GAME) {
    Input current = currentInput();
    
    if (key == CODED) {
      currentInput().coded[keyCode] = true;
    } else {
      currentInput().keys[key] = true;
    }
  
    if ((current.isPressed(UP) || current.isPressed(LEFT) || current.isPressed(DOWN) || current.isPressed(RIGHT)) && !players[0].active && !players[0].dead) {
       players[0].active = true;
       players[0].drunk = 0.0;
       players[0].bladder = 0.0;
       players[0].dead = false;
       println("Player0 active!");
    }
    
    if ((current.isPressed('w') || current.isPressed('a') || current.isPressed('s') || current.isPressed('d')) && !players[1].active && !players[1].dead) {
       players[1].active = true;
       players[1].drunk = 0.0;
       players[1].bladder = 0.0;
       players[1].dead = false;
       println("Player1 active!");
    }
    
    if ((current.isPressed('i') || current.isPressed('j') || current.isPressed('k') || current.isPressed('l')) && !players[2].active && !players[2].dead) {
       players[2].active = true;
       players[2].drunk = 0.0;
       players[2].bladder = 0.0;
       players[2].dead = false;
       println("Player2 active!");
    }
    
    if ((current.isPressed('8') || current.isPressed('4') || current.isPressed('5') || current.isPressed('6')) && !players[3].active && !players[3].dead) {
       players[3].active = true;
       players[3].drunk = 0.0;
       players[3].bladder = 0.0;
       players[3].dead = false;
       println("Player3 active!");
    }
  } else {
    displayHandleKeyPressed();
  }
}

void keyReleased() {
  if (key == CODED) {
    currentInput().coded[keyCode] = false;
  } else {
    currentInput().keys[key] = false;
  }
}