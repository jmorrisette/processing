class Firework {
  ArrayList<Particle> particles;

  Firework(float x, float y, float lootRadius, float userVx, float userVy, float userMaxSpeed, boolean bonus) {
    particles = new ArrayList<Particle>();

    float userSpeed = sqrt(userVx * userVx + userVy * userVy);
    float intensity = constrain(userSpeed / userMaxSpeed, 0.1, 1.0);

    if (bonus) {
      int particleCount = 90;
      float acceleration = 0.16;

      for (int i = 0; i < particleCount; i++) {
        particles.add(new Particle(x, y, lootRadius, acceleration, userVx, userVy, 1.0, true));
      }
    } else {
      int particleCount = (int)lerp(18, 85, intensity);
      float acceleration = lerp(0.025, 0.12, intensity);

      for (int i = 0; i < particleCount; i++) {
        particles.add(new Particle(x, y, lootRadius, acceleration, userVx, userVy, intensity, false));
      }
    }
  }

  void update() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      particles.get(i).update();
      if (particles.get(i).isDead()) {
        particles.remove(i);
      }
    }
  }

  boolean isFinished() {
    return particles.isEmpty();
  }

  void draw() {
    for (Particle particle : particles) {
      particle.draw();
    }
  }
}

class Particle {
  float x;
  float y;
  float vx;
  float vy;
  float ax;
  float ay;
  float radius;
  color baseColor;
  float alpha;
  float alphaDecay;
  boolean hasTail;
  ArrayList<PVector> tail;
  final int maxTailLength = 9;

  Particle(float x, float y, float lootRadius, float acceleration, float userVx, float userVy, float intensity, boolean bonus) {
    this.x = x;
    this.y = y;
    hasTail = bonus;
    tail = bonus ? new ArrayList<PVector>() : null;

    if (bonus) {
      float angle = random(TWO_PI);
      float speed = random(3.2, 9.5);
      vx = cos(angle) * speed;
      vy = sin(angle) * speed;
      ax = cos(angle) * acceleration * random(1.1, 1.6);
      ay = sin(angle) * acceleration * random(1.1, 1.6);

      radius = random(lootRadius * 0.18, lootRadius * 0.28);
      baseColor = pickBonusColor();
      alpha = 255;
      alphaDecay = random(3.2, 5.2);
    } else {
      float userSpeed = sqrt(userVx * userVx + userVy * userVy);
      float baseAngle = userSpeed >= 0.35 ? atan2(userVy, userVx) : random(TWO_PI);
      float velocitySpread = radians(lerp(45, 80, intensity));
      float angle = baseAngle + random(-velocitySpread, velocitySpread);
      float minSpeed = lerp(0.35, 1.6, intensity);
      float maxSpeed = lerp(1.0, 5.8, intensity);
      float speed = random(minSpeed, maxSpeed);
      float velocityInheritance = lerp(0.08, 0.38, intensity);
      vx = cos(angle) * speed + userVx * velocityInheritance;
      vy = sin(angle) * speed + userVy * velocityInheritance;

      float accelSpread = radians(lerp(55, 95, intensity));
      float accelAngle = baseAngle + random(-accelSpread, accelSpread);
      ax = cos(accelAngle) * acceleration;
      ay = sin(accelAngle) * acceleration;

      float maxRadius = lootRadius * lerp(0.22, 0.42, intensity);
      radius = random(0.6, maxRadius);
      baseColor = color(random(80, 255), random(80, 255), random(80, 255));
      alpha = lerp(180, 255, intensity);
      alphaDecay = lerp(6.0, 3.2, intensity);
    }
  }

  color pickBonusColor() {
    color[] palette = {
      color(255, 70, 110),
      color(255, 190, 40),
      color(70, 220, 255),
      color(120, 255, 90),
      color(200, 90, 255),
      color(255, 120, 50),
      color(255, 255, 240)
    };
    color picked = palette[(int)random(palette.length)];
    return color(
      constrain(red(picked) + random(-20, 20), 0, 255),
      constrain(green(picked) + random(-20, 20), 0, 255),
      constrain(blue(picked) + random(-20, 20), 0, 255)
    );
  }

  void update() {
    if (hasTail) {
      tail.add(new PVector(x, y));
      if (tail.size() > maxTailLength) {
        tail.remove(0);
      }
    }

    vx += ax;
    vy += ay;
    x += vx;
    y += vy;
    alpha -= alphaDecay;
  }

  boolean isDead() {
    return alpha <= 0;
  }

  void draw() {
    if (hasTail) {
      drawTail();
    }

    fill(red(baseColor), green(baseColor), blue(baseColor), max(0, alpha));
    noStroke();
    circle(x, y, radius * 2);
  }

  void drawTail() {
    if (tail == null || tail.isEmpty()) {
      return;
    }

    float prevX = tail.get(0).x;
    float prevY = tail.get(0).y;

    for (int i = 1; i < tail.size(); i++) {
      PVector point = tail.get(i);
      float t = i / (float) tail.size();
      stroke(red(baseColor), green(baseColor), blue(baseColor), max(0, alpha * t * 0.7));
      strokeWeight(radius * lerp(0.35, 1.0, t));
      line(prevX, prevY, point.x, point.y);
      prevX = point.x;
      prevY = point.y;
    }

    stroke(red(baseColor), green(baseColor), blue(baseColor), max(0, alpha * 0.85));
    strokeWeight(radius);
    line(prevX, prevY, x, y);
  }
}
