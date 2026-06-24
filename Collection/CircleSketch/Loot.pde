class Loot {
  static final int KIND_SPECK = 0;
  static final int KIND_NORMAL = 1;
  static final int KIND_BONUS = 2;

  float x;
  float y;
  float radius;
  int kind;
  float bobPhase;
  float bobAmplitude;
  float bobSpeed;
  int particleCount;
  float[] px;
  float[] py;
  float[] pSize;
  float[] pBright;
  float[] pWobble;
  color[] pColor;
  color speckColor;

  Loot(float x, float y, float radius, int kind) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.kind = kind;
    bobPhase = random(TWO_PI);
    bobAmplitude = radius * (kind == KIND_SPECK ? 0.45 : 0.3);
    bobSpeed = 0.003 + random(0.002);
    speckColor = color(random(200, 235), random(205, 240), random(215, 255));
    buildParticles();
  }

  boolean isBonus() {
    return kind == KIND_BONUS;
  }

  boolean isSpeck() {
    return kind == KIND_SPECK;
  }

  int points() {
    if (kind == KIND_SPECK) {
      return 5;
    }
    if (kind == KIND_BONUS) {
      return 50;
    }
    return 20;
  }

  void buildParticles() {
    if (kind == KIND_SPECK) {
      particleCount = 0;
      return;
    }

    particleCount = (int)(radius * 2.2) + 10;
    px = new float[particleCount];
    py = new float[particleCount];
    pSize = new float[particleCount];
    pBright = new float[particleCount];
    pWobble = new float[particleCount];
    pColor = new color[particleCount];

    for (int i = 0; i < particleCount; i++) {
      float clusterRadius = radius * sqrt(random(0.9));
      float angle = random(TWO_PI);
      px[i] = cos(angle) * clusterRadius;
      py[i] = sin(angle) * clusterRadius;
      pSize[i] = radius * random(0.14, 0.38);
      pWobble[i] = random(TWO_PI);

      if (kind == KIND_BONUS) {
        pColor[i] = pickBonusLootColor();
        pBright[i] = 255;
      } else {
        pColor[i] = color(255);
        pBright[i] = random(185, 255);
      }
    }
  }

  color pickBonusLootColor() {
    color[] palette = {
      color(255, 90, 120),
      color(255, 200, 60),
      color(80, 220, 255),
      color(130, 255, 100),
      color(210, 100, 255),
      color(255, 255, 240)
    };
    return palette[(int)random(palette.length)];
  }

  float bobOffset() {
    return sin(millis() * bobSpeed + bobPhase) * bobAmplitude;
  }

  boolean collidesWith(User user) {
    return dist(x, y, user.x, user.y) < radius + user.radius;
  }

  void draw() {
    float baseY = y + bobOffset();

    if (kind == KIND_SPECK) {
      noStroke();
      fill(speckColor, 220);
      circle(x, baseY, radius * 2);
      return;
    }

    if (kind == KIND_BONUS) {
      float pulse = sin(millis() * 0.009 + bobPhase) * 0.12 + 1.0;
      noFill();
      stroke(255, 190, 70, 110);
      strokeWeight(1.6);
      circle(x, baseY, radius * 2.7 * pulse);
      stroke(90, 210, 255, 70);
      strokeWeight(1.2);
      circle(x, baseY, radius * 3.3 * pulse);
    }

    noStroke();
    for (int i = 0; i < particleCount; i++) {
      float drift = sin(millis() * 0.005 + pWobble[i]) * radius * 0.05;
      float drawX = x + px[i] + cos(pWobble[i]) * drift;
      float drawY = baseY + py[i] + sin(pWobble[i]) * drift;
      color c = pColor[i];
      fill(red(c), green(c), blue(c), pBright[i]);
      circle(drawX, drawY, pSize[i] * 2);
    }
  }
}

Loot createRandomLoot(float userRadius, float userX, float userY, float worldW, float worldH) {
  float roll = random(1);
  int kind;
  float radius;

  if (roll < 0.65) {
    kind = Loot.KIND_SPECK;
    radius = userRadius * 0.09;
  } else if (roll < 0.75) {
    kind = Loot.KIND_BONUS;
    radius = userRadius * 0.58;
  } else {
    kind = Loot.KIND_NORMAL;
    radius = userRadius * 0.58;
  }

  float minDist = kind == Loot.KIND_SPECK ? 80 : 200;
  float maxDist = kind == Loot.KIND_SPECK ? 900 : 1000;
  float angle = random(TWO_PI);
  float distance = random(minDist, maxDist);
  float spawnX = userX + cos(angle) * distance;
  float spawnY = userY + sin(angle) * distance;
  float minBound = radius;
  float maxBoundX = worldW - radius;
  float maxBoundY = worldH - radius;
  spawnX = constrain(spawnX, minBound, maxBoundX);
  spawnY = constrain(spawnY, minBound, maxBoundY);
  return new Loot(spawnX, spawnY, radius, kind);
}
