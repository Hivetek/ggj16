
enum Display {
  TITLESCREEN, 
  MENU,
  INTRO,
  GAME
}

Display display = Display.TITLESCREEN;


void showTitlescreen() {
  pushStyle();
  
  background(0);
  
  textAlign(CENTER);
    
  textFont(regularFont);
  textSize(100);

  text("Frat Trap", width/2, height/2);
  
  textSize(32);

  text("Press any key...", width/2, height/2+200);
  
  popStyle();
}



void showIntro() {
  
  String[] text = {
    "bla",
    "bla2"
  };
  
  pushStyle();
  
  background(0);
  
  textAlign(CENTER);
    
  textFont(regularFont);
  
  textSize(32);

  text("Press any key...", width/2, height/2+200);
  
  popStyle();
}



void changeDisplay(Display disp) {
  display = disp;
}


void displayHandleKeyPressed() {
  switch(display) {
    case TITLESCREEN:
      changeDisplay(Display.INTRO);
      break;
    case INTRO:
      changeDisplay(Display.GAME);
      break;
  }
}