AudioPlayer background_music;
AudioPlayer death_sound;
AudioPlayer bro_drinking_sound;
AudioPlayer[] angry_bro_sound = new AudioPlayer[2];
AudioPlayer angry_guard_sound;
AudioPlayer[] player_drinking = new AudioPlayer[4];


void initSound() {
  // Sound effects
  death_sound = minim.loadFile("data/sound/scream_balloon_splatter.mp3", 2048);
  
  angry_guard_sound = minim.loadFile("data/sound/angry-bro1.mp3", 2048);
  angry_bro_sound[0] = minim.loadFile("data/sound/angry-bro2.mp3", 2048);
  angry_bro_sound[1] = minim.loadFile("data/sound/angry-bro3.mp3", 2048);
  
  bro_drinking_sound = minim.loadFile("data/sound/NPC_Bro-Drinking Sound.mp3", 2048);
  
  for (int i = 0; i < players.length; i++) {
    player_drinking[i] = minim.loadFile("data/sound/Player Drinking.mp3", 2048); 
  }
    
  // Start intro beat
  background_music = minim.loadFile("data/sound/Frat-Trap-Intro-Beat.mp3", 2048);
  background_music.loop();
}