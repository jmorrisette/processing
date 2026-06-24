class Wake {
  ArrayList<WakeParticle> particles;
  ArrayList<PVector> trail;
  float sternX;
  float sternY;
  float lastDirX;
  float lastDirY;
  final int maxTrail = 15;
  final float spawnSpacing = 6;
  final int particlesPerSpawn = 4;
  final float catchUpSpeed = 2.8;
  final float minSpeed = 0.35;

  Wake() {
    particles = new ArrayList<WakeParticle>();
    trail = new ArrayList<PVector>();
    lastDirX = 0;
    lastDirY = -1;
  }

  void update(User user) {
    for (int i = particles.size() - 1; i >= 0; i--) {
      particles.get(i).update();
      if (particles.get(i).isDead()) {
        particles.remove(i);
      }
    }

    float speed = sqrt(user.vx * user.vx + user.vy * user.vy);
    float dirX;
    float dirY;

    if (speed >= minSpeed) {
      dirX = user.vx / speed;
      dirY = user.vy / speed;
      lastDirX = dirX;
      lastDirY = dirY;
    } else {
      dirX = lastDirX;
      dirY = lastDirY;
    }

    sternX = user.x - dirX * user.radius * 0.9;
    sternY = user.y - dirY * user.radius * 0.9;

    catchUpTrail();

    if (speed > catchUpSpeed) {
      extendTrail(user, speed, dirX, dirY);
    }
  }

  void catchUpTrail() {
    for (int i = 0; i < trail.size(); i++) {
      PVector point = trail.get(i);
      float targetX;
      float targetY;

      if (i == trail.size() - 1) {
        targetX = sternX;
        targetY = sternY;
      } else {
        PVector next = trail.get(i + 1);
        targetX = next.x;
        targetY = next.y;
      }

      movePointToward(point, targetX, targetY, catchUpSpeed);
    }

    while (trail.size() > 0) {
      PVector last = trail.get(trail.size() - 1);
      if (dist(last.x, last.y, sternX, sternY) > 2.5) {
        break;
      }
      trail.remove(trail.size() - 1);
    }

    for (int i = trail.size() - 2; i >= 0; i--) {
      PVector a = trail.get(i);
      PVector b = trail.get(i + 1);
      if (dist(a.x, a.y, b.x, b.y) < 2.0) {
        trail.remove(i);
      }
    }
  }

  void extendTrail(User user, float speed, float dirX, float dirY) {
    float perpX = -dirY;
    float perpY = dirX;
    boolean shouldSpawn = trail.isEmpty();

    if (!trail.isEmpty()) {
      PVector last = trail.get(trail.size() - 1);
      shouldSpawn = dist(last.x, last.y, sternX, sternY) >= spawnSpacing;
    }

    if (!shouldSpawn) {
      return;
    }

    trail.add(new PVector(sternX, sternY));
    while (trail.size() > maxTrail) {
      trail.remove(0);
    }

    for (int i = 0; i < particlesPerSpawn; i++) {
      float side = random(1) < 0.5 ? -1 : 1;
      float spreadSpeed = random(0.9, 2.4);
      boolean isWhite = random(1) < 0.45;
      particles.add(new WakeParticle(
        sternX,
        sternY,
        perpX * side * spreadSpeed,
        perpY * side * spreadSpeed,
        isWhite
      ));
    }
  }

  void movePointToward(PVector point, float targetX, float targetY, float amount) {
    float dx = targetX - point.x;
    float dy = targetY - point.y;
    float distance = sqrt(dx * dx + dy * dy);

    if (distance < 0.001) {
      return;
    }

    if (distance <= amount) {
      point.x = targetX;
      point.y = targetY;
    } else {
      point.x += (dx / distance) * amount;
      point.y += (dy / distance) * amount;
    }
  }

  void draw() {
    if (trail.size() > 0) {
      noFill();
      for (int i = 1; i < trail.size(); i++) {
        float t = (float) i / (trail.size() + 1);
        stroke(50, 110, 220, t * 100);
        strokeWeight(6.5);
        PVector a = trail.get(i - 1);
        PVector b = trail.get(i);
        line(a.x, a.y, b.x, b.y);
      }

      PVector last = trail.get(trail.size() - 1);
      stroke(50, 110, 220, 100);
      strokeWeight(1.5);
      line(last.x, last.y, sternX, sternY);
    }

    for (WakeParticle particle : particles) {
      particle.draw();
    }
  }
}

class WakeParticle {
  float x;
  float y;
  float vx;
  float vy;
  float radius;
  color baseColor;
  float alpha;
  float alphaDecay;

  WakeParticle(float x, float y, float vx, float vy, boolean isWhite) {
    this.x = x + random(-1.5, 1.5);
    this.y = y + random(-1.5, 1.5);
    this.vx = vx + random(-0.15, 0.15);
    this.vy = vy + random(-0.15, 0.15);
    radius = random(1.2, 3.5);
    alpha = random(160, 255);
    alphaDecay = random(3.5, 7.0);
    baseColor = isWhite ? color(235, 245, 255) : color(35, 95, 255);
  }

  void update() {
    x += vx;
    y += vy;
    vx *= 0.97;
    vy *= 0.97;
    alpha -= alphaDecay;
  }

  boolean isDead() {
    return alpha <= 0;
  }

  void draw() {
    fill(red(baseColor), green(baseColor), blue(baseColor), max(0, alpha));
    noStroke();
    circle(x, y, radius * 2);
  }
}
