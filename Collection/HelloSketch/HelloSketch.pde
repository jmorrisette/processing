/**
 * HelloSketch — starter sketch for the Collection.
 *
 * A simple animated grid of circles. Tweak COLS, ROWS, and speed to explore.
 */

final int COLS = 12;
final int ROWS = 8;
final float SPEED = 0.02;

void setup() {
  size(960, 640);
  colorMode(HSB, 360, 100, 100, 100);
  noStroke();
}

void draw() {
  background(0, 0, 12);

  float t = frameCount * SPEED;

  for (int col = 0; col < COLS; col++) {
    for (int row = 0; row < ROWS; row++) {
      float x = map(col, 0, COLS - 1, width * 0.1, width * 0.9);
      float y = map(row, 0, ROWS - 1, height * 0.15, height * 0.85);

      float phase = col * 0.4 + row * 0.6;
      float radius = 18 + 14 * sin(t + phase);
      float hue = (t * 40 + col * 18 + row * 12) % 360;

      fill(hue, 70, 90, 85);
      circle(x, y, radius * 2);
    }
  }
}

void mousePressed() {
  saveFrame("screenshot-####.png");
}
