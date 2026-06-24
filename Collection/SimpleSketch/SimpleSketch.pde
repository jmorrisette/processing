/**
 * SimpleSketch
 */

final float FLOOR_Y = 0;
final float PLANE_HALF = 50;

void setup() {
  size(960, 640, P3D);
}

void draw() {
  background(255);
  camera(650, -450, 750, 0, -80, 0, 0, -1, 0);
  drawPlane();
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
