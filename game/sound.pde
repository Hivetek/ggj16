AudioPlayer background_music;
AudioPlayer death_sound;


void initSound() {
  // Sound effects
  death_sound = minim.loadFile("data/sound/scream_balloon_splatter.mp3", 2048);
    
  // Start intro beat
  background_music = minim.loadFile("data/sound/Frat-Trap-Intro-Beat.mp3", 2048);
  background_music.loop();
}