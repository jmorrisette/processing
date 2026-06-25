/**
 * Noise Terrain
 * Generates a static 3D plane with hills and valleys from 2D Perlin noise.
 * The heightmap is sampled once in setup() so it does not shimmer like noise().
 * Press 'r' to regenerate with a new random seed.
 */

int cols = 110;
int rows = 110;
float spacing = 7;
float noiseScale = 0.07;
float heightScale = 130;

float[][] heights;

void setup() {
  size(640, 360, P3D);
  generateTerrain();
}

void generateTerrain() {
  noiseSeed((long) random(1000000));
  heights = new float[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      heights[x][y] = noise(x * noiseScale, y * noiseScale) * heightScale;
    }
  }
}

void draw() {
  background(20, 25, 40);
  lights();

  float terrainW = (cols - 1) * spacing;
  float terrainH = (rows - 1) * spacing;

  camera(0, -330, 620, 0, 0, 0, 0, 1, 0);

  translate(-terrainW / 2, 0, -terrainH / 2);

  noStroke();
  for (int y = 0; y < rows - 1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      float h1 = heights[x][y];
      float h2 = heights[x][y + 1];
      fill(heightColor(h1));
      vertex(x * spacing, -h1, y * spacing);
      fill(heightColor(h2));
      vertex(x * spacing, -h2, (y + 1) * spacing);
    }
    endShape();
  }
}

color heightColor(float h) {
  float t = h / heightScale;
  if (t < 0.30) return color(45, 85, 135);    // water
  if (t < 0.38) return color(220, 200, 140);  // sand
  if (t < 0.65) return color(70, 140, 70);    // grass
  if (t < 0.82) return color(110, 90, 70);    // rock
  return color(240, 240, 250);                // snow
}

void keyPressed() {
  if (key == 'r' || key == 'R') generateTerrain();
}
