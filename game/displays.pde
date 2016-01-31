
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


int intro_text_index = 0;
int intro_text_timestamp = 0;
int intro_interval = 43;

void showIntro() {
  
  String[] text = {
    "Undercover journalists have infiltrated the fraternity Theta Epsilon Mu",
    "Aiming to investigate its hazing ritual...",
    "And expose them to the world",
    "After suffering...",
    "Humiliating bunny costumes",
    "Countless bouts of paddling ",
    "ΘΣΜ tattoos on the butt",
    "Innumerable alcohol poisonings ",
    "Lines of cocaine ",
    "Overdoses",
    "Humiliating bunny costumes",
    "More alcohol poisonings ",
    "Burning iron branding ",
    "All in the name of an ideal cause of...",
    "exposing these crimes to the world.",
    "One final test remains before becoming a full member",
    "and getting access to the frat bros secret video archive...",
    "Having to serve drinks to the bros and drink for the whole night...",
    "Without going to the bathroom!",
    "Press any key to continue..."
  };
  
  int now = millis();
  
  int actual_interval = intro_interval * text[intro_text_index].length();
  
  if (intro_text_index+1 == text.length/2) {
    actual_interval += 1000;
  }
  
  if (now - intro_text_timestamp >= actual_interval) {
    intro_text_timestamp = now;
    if (intro_text_index < text.length - 1) {
      intro_text_index++;
    }
  }
  
  pushStyle();
  
  background(0);
  
  textAlign(CENTER);
    
  textFont(introFont);
  
  textSize(28);

  int i;
  int j = 0;
  if (intro_text_index < text.length/2) {
    i = 0;
  } else {
    i = text.length/2;
  }
  
  for (; i <= intro_text_index && i < text.length; i++) {
    text(text[i], width/2, (j+1)*60);
    j++;
  }
  
  
  popStyle();
}



void changeDisplay(Display disp) {
  display = disp;
  if (disp == Display.INTRO) {
    intro_text_timestamp = millis();
  }
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