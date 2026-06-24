/**
 * LootSeeker — collect white loot circles as the user.
 */

import processing.sound.*;

final float WORLD_WIDTH = 2000;
final float WORLD_HEIGHT = 2000;
final int GRID_SIZE = 100;
final float GAME_DURATION_SEC = 30;

final int STATE_TITLE = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

User user;
ArrayList<Loot> loot;
ArrayList<Firework> fireworks;
Wake wake;
SoundFile explosionSound;
WhiteNoise snapNoise;
HighPass snapHighPass;
Env snapEnv;

int gameState = STATE_TITLE;
int score = 0;
float timeRemaining = GAME_DURATION_SEC;
long gameEndAtMs = 0;

void setup() {
  size(600, 600);
  frameRate(60);
  user = new User(WORLD_WIDTH / 2.0, WORLD_HEIGHT / 2.0, min(width, height) * 0.05);
  loot = new ArrayList<Loot>();
  fireworks = new ArrayList<Firework>();
  wake = new Wake();
  loadSounds();
}

void draw() {
  background(20);

  if (gameState == STATE_TITLE) {
    drawTitleScreen();
    return;
  }

  if (gameState == STATE_PLAYING) {
    updateTimer();
    user.update(WORLD_WIDTH, WORLD_HEIGHT);
    wake.update(user);
    checkLootCollisions();
    updateFireworks();

    pushMatrix();
    translate(width / 2.0 - user.x, height / 2.0 - user.y);
    drawWorldBackground();
    wake.draw();
    drawLoot();
    drawFireworks();
    popMatrix();

    user.drawScreen();
    drawHud();

    if (gameState == STATE_GAME_OVER) {
      drawGameOverScreen();
    }
    return;
  }

  if (gameState == STATE_GAME_OVER) {
    drawFrozenGame();
    drawGameOverScreen();
  }
}

void drawTitleScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("HIT ENTER TO PLAY", width / 2.0, height / 2.0);

  textSize(16);
  fill(180);
  text("Speck 5  |  Loot 20  |  Bonus 50", width / 2.0, height / 2.0 + 42);
}

void drawHud() {
  fill(255);
  textAlign(CENTER, TOP);
  textSize(30);
  text(nf(max(0, timeRemaining), 0, 1), width / 2.0, 14);

  textAlign(LEFT, TOP);
  textSize(18);
  text("Score: " + score, 16, 16);
}

void drawGameOverScreen() {
  fill(0, 180);
  noStroke();
  rect(0, 0, width, height);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("TIME'S UP", width / 2.0, height / 2.0 - 36);
  textSize(28);
  text("Score: " + score, width / 2.0, height / 2.0 + 8);
  textSize(18);
  fill(200);
  text("HIT ENTER TO PLAY AGAIN", width / 2.0, height / 2.0 + 52);
}

void drawFrozenGame() {
  pushMatrix();
  translate(width / 2.0 - user.x, height / 2.0 - user.y);
  drawWorldBackground();
  wake.draw();
  drawLoot();
  drawFireworks();
  popMatrix();

  user.drawScreen();
  drawHud();
}

void startGame() {
  score = 0;
  timeRemaining = GAME_DURATION_SEC;
  gameEndAtMs = millis() + (long)(GAME_DURATION_SEC * 1000);
  gameState = STATE_PLAYING;

  user.x = WORLD_WIDTH / 2.0;
  user.y = WORLD_HEIGHT / 2.0;
  user.resetInput();

  loot.clear();
  fireworks.clear();
  spawnLoot(55);
}

void updateTimer() {
  timeRemaining = max(0, (gameEndAtMs - millis()) / 1000.0);
  if (timeRemaining <= 0) {
    gameState = STATE_GAME_OVER;
  }
}

void drawWorldBackground() {
  stroke(28);
  strokeWeight(1);
  int startX = max(0, (int)floor((user.x - width) / GRID_SIZE) * GRID_SIZE);
  int endX = min((int)WORLD_WIDTH, (int)ceil((user.x + width) / GRID_SIZE) * GRID_SIZE);
  int startY = max(0, (int)floor((user.y - height) / GRID_SIZE) * GRID_SIZE);
  int endY = min((int)WORLD_HEIGHT, (int)ceil((user.y + height) / GRID_SIZE) * GRID_SIZE);

  for (int gx = startX; gx <= endX; gx += GRID_SIZE) {
    line(gx, startY, gx, endY);
  }
  for (int gy = startY; gy <= endY; gy += GRID_SIZE) {
    line(startX, gy, endX, gy);
  }
}

void spawnLoot(int count) {
  for (int i = 0; i < count; i++) {
    loot.add(createRandomLoot(user.radius, user.x, user.y, WORLD_WIDTH, WORLD_HEIGHT));
  }
}

void checkLootCollisions() {
  for (int i = loot.size() - 1; i >= 0; i--) {
    Loot piece = loot.get(i);
    if (piece.collidesWith(user)) {
      score += piece.points();
      if (!piece.isSpeck()) {
        fireworks.add(new Firework(piece.x, piece.y, piece.radius, user.vx, user.vy, user.maxSpeed, piece.isBonus()));
      }
      playLootSound(piece);
      loot.remove(i);
      loot.add(createRandomLoot(user.radius, user.x, user.y, WORLD_WIDTH, WORLD_HEIGHT));
    }
  }
}

void updateFireworks() {
  for (int i = fireworks.size() - 1; i >= 0; i--) {
    fireworks.get(i).update();
    if (fireworks.get(i).isFinished()) {
      fireworks.remove(i);
    }
  }
}

void drawFireworks() {
  for (Firework firework : fireworks) {
    firework.draw();
  }
}

void drawLoot() {
  for (Loot piece : loot) {
    piece.draw();
  }
}

void keyPressed() {
  if (key == ENTER || key == RETURN || key == '\n' || key == '\r') {
    if (gameState == STATE_TITLE || gameState == STATE_GAME_OVER) {
      startGame();
      return;
    }
  }

  if (gameState == STATE_PLAYING) {
    user.onKeyPressed();
  }
}

void keyReleased() {
  user.onKeyReleased();
}

void loadSounds() {
  explosionSound = new SoundFile(this, "explosion.wav");
  snapNoise = new WhiteNoise(this);
  snapHighPass = new HighPass(this);
  snapHighPass.process(snapNoise, 3200);
  snapEnv = new Env(this);
}

void playLootSound(Loot piece) {
  if (piece.isSpeck()) {
    playFingerSnap();
  } else {
    playExplosionSound();
  }
}

void playFingerSnap() {
  if (snapEnv == null) {
    return;
  }
  snapNoise.play();
  snapEnv.play(snapNoise, 0.001, 0.006, 0.21, 0.038);
}

void playExplosionSound() {
  if (explosionSound != null) {
    explosionSound.play();
  }
}
