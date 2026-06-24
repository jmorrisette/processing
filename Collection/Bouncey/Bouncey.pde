/**
 * Bouncey — bouncing ball with trails, squash/stretch, shadow, and camera orbit.
 *
 * Click to launch a new ball. Each bounce leaves a colored ring on the floor.
 * The camera slowly orbits the scene. Balls accumulate until you press 'R'.
 */

final float GRAVITY = 0.4;
final float RESTITUTION = 0.82;
final float PLANE_HALF = 600;
final float TILE_SIZE = 60;

ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<Ring> rings = new ArrayList<Ring>();
float camAngle = 0;

void setup() {
  size(1080, 720, P3D);
  smooth(8);
  balls.add(new Ball(0, 400, 0, random(-4, 4), 0, random(-4, 4), randomHue()));
}

void draw() {
  background(18, 18, 26);

  camAngle += 0.003;
  float camDist = 1100;
  float camY = 550;
  camera(
    cos(camAngle) * camDist, camY, sin(camAngle) * camDist,
    0, 80, 0,
    0, -1, 0
  );

  ambientLight(60, 60, 80);
  directionalLight(200, 195, 180, 0.3, -0.8, -0.3);
  pointLight(120, 140, 200, 0, 600, 0);

  drawFloor();
  drawRings();

  for (int i = balls.size() - 1; i >= 0; i--) {
    Ball b = balls.get(i);
    b.update();
    b.draw();
    if (b.isDead()) balls.remove(i);
  }
}

void drawFloor() {
  noStroke();
  for (float x = -PLANE_HALF; x < PLANE_HALF; x += TILE_SIZE) {
    for (float z = -PLANE_HALF; z < PLANE_HALF; z += TILE_SIZE) {
      int col = round((x + PLANE_HALF) / TILE_SIZE);
      int row = round((z + PLANE_HALF) / TILE_SIZE);
      boolean light = (col + row) % 2 == 0;
      fill(light ? color(48, 50, 58) : color(38, 40, 46));
      beginShape();
      vertex(x, 0, z);
      vertex(x + TILE_SIZE, 0, z);
      vertex(x + TILE_SIZE, 0, z + TILE_SIZE);
      vertex(x, 0, z + TILE_SIZE);
      endShape(CLOSE);
    }
  }

  noFill();
  stroke(80, 85, 100);
  strokeWeight(2);
  beginShape();
  vertex(-PLANE_HALF, 0, -PLANE_HALF);
  vertex(PLANE_HALF, 0, -PLANE_HALF);
  vertex(PLANE_HALF, 0, PLANE_HALF);
  vertex(-PLANE_HALF, 0, PLANE_HALF);
  endShape(CLOSE);
  noStroke();
}

void drawRings() {
  for (int i = rings.size() - 1; i >= 0; i--) {
    Ring r = rings.get(i);
    r.draw();
    if (r.isDead()) rings.remove(i);
  }
}

void mousePressed() {
  float angle = random(TWO_PI);
  float speed = random(3, 7);
  balls.add(new Ball(
    0, 500, 0,
    cos(angle) * speed, random(0, 3), sin(angle) * speed,
    randomHue()
  ));
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    balls.clear();
    rings.clear();
  }
}

float randomHue() {
  return random(360);
}

color hueToColor(float h, float sat, float bri) {
  pushStyle();
  colorMode(HSB, 360, 100, 100);
  color c = color(h % 360, sat, bri);
  popStyle();
  return c;
}

// ─── Ball ───────────────────────────────────────────────────────────────

class Ball {
  float x, y, z;
  float vx, vy, vz;
  float radius = 30;
  float hue;
  float squash = 1.0;
  float life = 1.0;
  int bounceCount = 0;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  final int TRAIL_MAX = 20;

  Ball(float x, float y, float z, float vx, float vy, float vz, float hue) {
    this.x = x; this.y = y; this.z = z;
    this.vx = vx; this.vy = vy; this.vz = vz;
    this.hue = hue;
  }

  void update() {
    vy -= GRAVITY;
    x += vx;
    y += vy;
    z += vz;

    trail.add(new PVector(x, y, z));
    if (trail.size() > TRAIL_MAX) trail.remove(0);

    squash = lerp(squash, 1.0, 0.15);

    if (y - radius <= 0) {
      y = radius;
      vy *= -RESTITUTION;
      vx *= 0.98;
      vz *= 0.98;
      squash = 0.55;
      bounceCount++;
      rings.add(new Ring(x, z, hue, radius * 1.5));
    }

    float limit = PLANE_HALF - radius;
    if (x < -limit) { x = -limit; vx *= -RESTITUTION; }
    if (x > limit)  { x = limit;  vx *= -RESTITUTION; }
    if (z < -limit) { z = -limit; vz *= -RESTITUTION; }
    if (z > limit)  { z = limit;  vz *= -RESTITUTION; }

    if (bounceCount > 2 && abs(vy) < 0.5 && y - radius < 2) {
      life -= 0.01;
    }
  }

  void draw() {
    drawShadow();
    drawTrail();

    pushMatrix();
    translate(x, y, z);
    scale(1.0 / squash, squash, 1.0 / squash);
    noStroke();
    fill(hueToColor(hue, 75, 95));
    specular(200);
    shininess(25);
    sphere(radius);

    fill(hueToColor(hue + 30, 40, 100));
    translate(-radius * 0.3, radius * 0.3, radius * 0.4);
    sphere(radius * 0.18);
    popMatrix();
  }

  void drawShadow() {
    float groundDist = y;
    float shadowScale = map(constrain(groundDist, 0, 500), 0, 500, 1.2, 0.4);
    float shadowAlpha = map(constrain(groundDist, 0, 500), 0, 500, 100, 15);

    pushMatrix();
    translate(x, 0.5, z);
    rotateX(HALF_PI);
    noStroke();
    fill(0, shadowAlpha);
    ellipse(0, 0, radius * 2 * shadowScale, radius * 2 * shadowScale);
    popMatrix();
  }

  void drawTrail() {
    noFill();
    for (int i = 1; i < trail.size(); i++) {
      PVector p = trail.get(i);
      PVector prev = trail.get(i - 1);
      float alpha = map(i, 0, trail.size(), 0, 180) * life;
      stroke(hueToColor(hue, 60, 90), alpha);
      strokeWeight(map(i, 0, trail.size(), 1, 4));
      line(prev.x, prev.y, prev.z, p.x, p.y, p.z);
    }
    noStroke();
  }

  boolean isDead() {
    return life <= 0;
  }
}

// ─── Ring ───────────────────────────────────────────────────────────────

class Ring {
  float x, z;
  float hue;
  float radius;
  float maxRadius;
  float alpha = 200;

  Ring(float x, float z, float hue, float startRadius) {
    this.x = x;
    this.z = z;
    this.hue = hue;
    this.radius = startRadius;
    this.maxRadius = startRadius * 4;
  }

  void draw() {
    radius += 2.5;
    alpha -= 4;

    pushMatrix();
    translate(x, 0.3, z);
    rotateX(HALF_PI);
    noFill();
    stroke(hueToColor(hue, 70, 90), constrain(alpha, 0, 255));
    strokeWeight(2.5);
    ellipse(0, 0, radius * 2, radius * 2);
    popMatrix();
  }

  boolean isDead() {
    return alpha <= 0;
  }
}
