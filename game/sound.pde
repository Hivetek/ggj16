AudioPlayer background_music;
AudioPlayer death_sound;
AudioPlayer bro_drinking_sound;
AudioPlayer[] angry_bro_sound = new AudioPlayer[3];


void initSound() {
  // Sound effects
  death_sound = minim.loadFile("data/sound/scream_balloon_splatter.mp3", 2048);
  
  angry_bro_sound[0] = minim.loadFile("data/sound/angry-bro1.mp3", 2048);
  angry_bro_sound[1] = minim.loadFile("data/sound/angry-bro2.mp3", 2048);
  angry_bro_sound[2] = minim.loadFile("data/sound/angry-bro3.mp3", 2048);
  
  bro_drinking_sound = minim.loadFile("data/sound/NPC_Bro-Drinking Sound.mp3", 2048);
    
  // Start intro beat
  background_music = minim.loadFile("data/sound/Frat-Trap-Intro-Beat.mp3", 2048);
  background_music.loop();
}