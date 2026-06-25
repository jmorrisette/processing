/**
 * Mazey — roll a ball on a plane (WASD or arrow keys).
 */

final float MOVE_SPEED = 6;
final float FLOOR_Y = 0;
final float BALL_RADIUS = 45;
final float PLANE_HALF = 500;

float ballX = 0;
float ballZ = 0;

boolean moveUp, moveDown, moveLeft, moveRight;

void setup() {
  size(960, 640, P3D);
}

void draw() {
  background(25, 30, 40);
  lights();

  camera(0, -600, 850, 0, 0, 0, 0, 1, 0);
  updateBall();
  drawPlane();
  drawBall();
}

void updateBall() {
  float dx = 0;
  float dz = 0;

  if (moveUp) dz -= MOVE_SPEED;
  if (moveDown) dz += MOVE_SPEED;
  if (moveLeft) dx -= MOVE_SPEED;
  if (moveRight) dx += MOVE_SPEED;

  ballX += dx;
  ballZ += dz;

  float limit = PLANE_HALF - BALL_RADIUS;
  ballX = constrain(ballX, -limit, limit);
  ballZ = constrain(ballZ, -limit, limit);
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
  translate(ballX, FLOOR_Y - BALL_RADIUS, ballZ);
  fill(230, 90, 70);
  noStroke();
  sphere(BALL_RADIUS);
  popMatrix();
}

void keyPressed() {
  setMoveKey(key, keyCode, true);
}

void keyReleased() {
  setMoveKey(key, keyCode, false);
}

void setMoveKey(char k, int code, boolean pressed) {
  if (k == 'w' || k == 'W' || code == UP) moveUp = pressed;
  if (k == 's' || k == 'S' || code == DOWN) moveDown = pressed;
  if (k == 'a' || k == 'A' || code == LEFT) moveLeft = pressed;
  if (k == 'd' || k == 'D' || code == RIGHT) moveRight = pressed;
}
