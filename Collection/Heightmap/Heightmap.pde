/**
 * Heightmap
 * Loads a grayscale PNG and renders it as a 3D heightmapped terrain
 * in the same biome-colored style as the Noise sketch.
 *
 * Put a grayscale image at: Collection/Heightmap/data/heightmap.png
 * Or press 'o' at runtime to pick any image from disk.
 *
 * Brighter pixels = higher terrain.
 */

PImage source;
float[][] heights;
int cols, rows;

float spacing = 10;
float heightScale = 120;
int maxRes = 280;

void setup() {
  size(640, 360, P3D);
  loadHeightmap(dataPath("heightmap.png"));
}

void loadHeightmap(String path) {
  PImage img = loadImage(path);
  if (img == null || img.width < 2 || img.height < 2) {
    source = null;
    heights = null;
    return;
  }
  source = img;
  img.loadPixels();

  cols = min(img.width, maxRes);
  rows = min(img.height, maxRes);
  heights = new float[cols][rows];

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      int px = (int) map(x, 0, cols - 1, 0, img.width - 1);
      int py = (int) map(y, 0, rows - 1, 0, img.height - 1);
      float b = brightness(img.pixels[px + py * img.width]);
      heights[x][y] = b / 255.0 * heightScale;
    }
  }
}

void draw() {
  background(20, 25, 40);

  if (heights == null) {
    drawHint();
    return;
  }

  lights();

  float terrainW = (cols - 1) * spacing;
  float terrainH = (rows - 1) * spacing;
  camera(0, -500, 620, 0, 0, 0, 0, 1, 0);
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
  if (t < 0.05) return color(45, 85, 135);    // water
  if (t < 0.28) return color(220, 200, 140);  // sand
  if (t < 0.65) return color(70, 140, 70);    // grass
  if (t < 0.82) return color(110, 90, 70);    // rock
  return color(240, 240, 250);                // snow
}

void drawHint() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  fill(230);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("No heightmap loaded.\n"
     + "Drop a grayscale PNG at data/heightmap.png\n"
     + "or press 'o' to choose one.",
       width / 2, height / 2);
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  if (key == 'o' || key == 'O') {
    selectInput("Choose a grayscale heightmap image", "imageChosen");
  }
}

public void imageChosen(File selection) {
  if (selection == null) return;
  loadHeightmap(selection.getAbsolutePath());
}
