class User {
  float x;
  float y;
  float radius;
  color fillColor;
  float vx;
  float vy;
  float acceleration = 0.25;
  float maxSpeed = 10;
  float bounce = 0.98;
  float friction = 0.98;
  float heading;

  boolean moveUp;
  boolean moveDown;
  boolean moveLeft;
  boolean moveRight;

  User(float x, float y, float radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.fillColor = color(6, 6, 8);
    heading = -HALF_PI;
  }

  void onKeyPressed() {
    if (isUpKey()) {
      moveUp = true;
    }
    if (isDownKey()) {
      moveDown = true;
    }
    if (isLeftKey()) {
      moveLeft = true;
    }
    if (isRightKey()) {
      moveRight = true;
    }
  }

  void onKeyReleased() {
    if (isUpKey()) {
      moveUp = false;
    }
    if (isDownKey()) {
      moveDown = false;
    }
    if (isLeftKey()) {
      moveLeft = false;
    }
    if (isRightKey()) {
      moveRight = false;
    }
  }

  void resetInput() {
    moveUp = false;
    moveDown = false;
    moveLeft = false;
    moveRight = false;
    vx = 0;
    vy = 0;
  }

  void update(float worldWidth, float worldHeight) {
    float ax = 0;
    float ay = 0;

    if (moveUp) {
      ay -= 1;
    }
    if (moveDown) {
      ay += 1;
    }
    if (moveLeft) {
      ax -= 1;
    }
    if (moveRight) {
      ax += 1;
    }

    if (ax != 0 || ay != 0) {
      float magnitude = sqrt(ax * ax + ay * ay);
      ax = (ax / magnitude) * acceleration;
      ay = (ay / magnitude) * acceleration;
    }

    vx += ax;
    vy += ay;

    vx *= friction;
    vy *= friction;

    float speed = sqrt(vx * vx + vy * vy);
    if (speed >= 0.35) {
      heading = atan2(vy, vx);
    }
    if (speed > maxSpeed) {
      vx = (vx / speed) * maxSpeed;
      vy = (vy / speed) * maxSpeed;
    }

    x += vx;
    y += vy;

    float minX = radius;
    float maxX = worldWidth - radius;
    float minY = radius;
    float maxY = worldHeight - radius;

    if (x < minX) {
      x = minX;
      vx = abs(vx) * bounce;
    } else if (x > maxX) {
      x = maxX;
      vx = -abs(vx) * bounce;
    }

    if (y < minY) {
      y = minY;
      vy = abs(vy) * bounce;
    } else if (y > maxY) {
      y = maxY;
      vy = -abs(vy) * bounce;
    }
  }

  void draw() {
    drawBoatAt(x, y);
  }

  void drawScreen() {
    drawBoatAt(width / 2.0, height / 2.0);
  }

  void drawBoatAt(float cx, float cy) {
    float r = radius;
    float speed = sqrt(vx * vx + vy * vy);
    float speedRatio = speed / maxSpeed;

    pushMatrix();
    translate(cx, cy);
    rotate(heading);

    if (speedRatio >= 0.75) {
      drawSpeedEffect(speedRatio);
    }

    drawB2Silhouette(r, fillColor);

    popMatrix();
  }

  void drawB2Silhouette(float r, color c) {
    fill(c);
    //noStroke();
    beginShape();
    vertex(r * 1.28, 0);
    vertex(r * 0.14, -r * 1.42);
    vertex(r * -0.1, -r * 1.26);
    vertex(r * 0.06, -r * 1.0);
    vertex(r * -0.64, -r * 0.66);
    vertex(r * -0.82, -r * 0.9);
    vertex(r * -0.96, -r * 0.3);
    vertex(r * -1.28, 0);
    vertex(r * -0.96, r * 0.3);
    vertex(r * -0.82, r * 0.9);
    vertex(r * -0.64, r * 0.66);
    vertex(r * 0.06, r * 1.0);
    vertex(r * -0.1, r * 1.26);
    vertex(r * 0.14, r * 1.42);
    endShape(CLOSE);
  }

  void drawSpeedEffect(float speedRatio) {
    float t = constrain((speedRatio - 0.75) / 0.25, 0, 1);
    float pulse = sin(millis() * 0.014) * 0.1 + 1.0;
    float time = millis() * 0.001;

    noFill();
    stroke(90, 210, 255, lerp(25, 95, t) * pulse);
    strokeWeight(lerp(1.2, 2.4, t));
    ellipse(0, 0, radius * 3.5 * pulse, radius * 2.1 * pulse);

    stroke(255, 130, 50, lerp(20, 75, t) * pulse);
    strokeWeight(lerp(1, 1.8, t));
    ellipse(0, 0, radius * 2.7 * pulse, radius * 1.5 * pulse);

    for (int i = 0; i < 6; i++) {
      float spread = map(i, 0, 5, -0.55, 0.55);
      float wave = sin(time * 8 + i * 1.3) * radius * 0.06;
      float yOff = radius * spread + wave;
      float streakLen = radius * lerp(1.4, 3.2, t);
      float flicker = sin(time * 12 + i * 2.1) * 0.3 + 0.7;
      stroke(180, 230, 255, lerp(35, 160, t) * flicker);
      strokeWeight(lerp(0.8, 2.2, t));
      line(-radius * 1.3, yOff, -radius * 1.3 - streakLen, yOff);
    }

    for (int i = 0; i < 3; i++) {
      float ghostT = (i + 1) / 4.0;
      float ghostAlpha = lerp(12, 45, t) * (1 - ghostT);
      pushMatrix();
      translate(-radius * ghostT * lerp(0.4, 1.1, t), 0);
      scale(1 - ghostT * 0.08);
      drawB2Silhouette(radius, color(190, 70, 84, ghostAlpha));
      popMatrix();
    }
  }

  boolean isUpKey() {
    return key == 'w' || key == 'W' || keyCode == UP;
  }

  boolean isDownKey() {
    return key == 's' || key == 'S' || keyCode == DOWN;
  }

  boolean isLeftKey() {
    return key == 'a' || key == 'A' || keyCode == LEFT;
  }

  boolean isRightKey() {
    return key == 'd' || key == 'D' || keyCode == RIGHT;
  }
}
