/**
 * Mazey — a ball bouncing on a plane.
 */

final float GRAVITY = 0.6;
final float BOUNCE = 0.85;
final float FLOOR_Y = 0;
final float BALL_RADIUS = 45;
final float PLANE_HALF = 500;

float ballX = 0;
float ballY = -350;
float ballZ = 0;
float velX = 5;
float velY = 0;
float velZ = 3.5;

void setup() {
  size(960, 640, P3D);
}

void draw() {
  background(25, 30, 40);
  lights();

  camera(650, -450, 750, 0, -80, 0, 0, 1, 0);

  updateBall();
  drawPlane();
  drawBall();
}

void updateBall() {
  velY += GRAVITY;

  ballX += velX;
  ballY += velY;
  ballZ += velZ;

  if (ballY + BALL_RADIUS >= FLOOR_Y) {
    ballY = FLOOR_Y - BALL_RADIUS;
    velY *= -BOUNCE;
    velX *= 0.995;
    velZ *= 0.995;
  }

  float limit = PLANE_HALF - BALL_RADIUS;
  if (ballX < -limit || ballX > limit) {
    velX *= -BOUNCE;
    ballX = constrain(ballX, -limit, limit);
  }
  if (ballZ < -limit || ballZ > limit) {
    velZ *= -BOUNCE;
    ballZ = constrain(ballZ, -limit, limit);
  }
}

void drawPlane() {
  noStroke();
  fill(70, 75, 85);
  beginShape();
  vertex(-PLANE_HALF, FLOOR_Y, -PLANE_HALF);
  vertex(PLANE_HALF, FLOOR_Y, -PLANE_HALF);
  vertex(PLANE_HALF, FLOOR_Y, PLANE_HALF);
  vertex(-PLANE_HALF, FLOOR_Y, PLANE_HALF);
  endShape(CLOSE);

  stroke(100, 105, 120);
  strokeWeight(1);
  for (float x = -PLANE_HALF; x <= PLANE_HALF; x += 50) {
    line(x, FLOOR_Y + 0.5, -PLANE_HALF, x, FLOOR_Y + 0.5, PLANE_HALF);
  }
  for (float z = -PLANE_HALF; z <= PLANE_HALF; z += 50) {
    line(-PLANE_HALF, FLOOR_Y + 0.5, z, PLANE_HALF, FLOOR_Y + 0.5, z);
  }
  noStroke();
}

void drawBall() {
  pushMatrix();
  translate(ballX, ballY, ballZ);
  fill(230, 90, 70);
  noStroke();
  sphere(BALL_RADIUS);
  popMatrix();
}

void mousePressed() {
  ballY = -350;
  velX = random(-6, 6);
  velY = random(-2, 0);
  velZ = random(-6, 6);
}
