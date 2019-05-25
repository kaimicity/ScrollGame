class Boss {
  PVector position;
  PVector from;
  PVector to;
  float width;
  float height;
  color myColor;
  color canonColor;
  color knifeColor;
  color gunColor;
  int life;
  PGraphics pg;
  float accelerate;
  float velocity;
  color inter;
  String status;
  int counter;
  ArrayList<Missile> myMissile;
  ArrayList<Integer> killList;
  float knifeDir;
  int colorCounter;
  boolean showCanon;
  boolean hit;
  float rotVelo;
  float rotAcc;

  Boss(float x, float y, float w, float h, PGraphics graphic) {
    this.position = new PVector(x, y);
    this.width = w;
    this.height = h;
    this.pg = graphic;
    this.from = new PVector(x, y);
    this.to = new PVector(0.7 * pg.width, y);
    this.life = 20;
    this.accelerate = w / 400;
    this.velocity = 0;
    this.myColor = color((int)(Math.random() * 255), (int)(Math.random() * 155 + 100), (int)(Math.random() * 155 + 100));
    canonColor = myColor;
    knifeColor = myColor;
    gunColor = myColor;
    this.status = "COMEIN";
    knifeDir = 0;
    counter = 0;
    colorCounter = 50;
    showCanon = false;
    hit = false;
    rotVelo = 0;
    rotAcc = PI / 1250;
    myMissile = new ArrayList();
    killList = new ArrayList();
  }

  void draw() {
    act();
    if (colorCounter < 30) {
      pg.fill(255, 0, 0);
      colorCounter ++;
    } else {
      pg.fill(myColor);
    }
    pg.stroke(0);
    pg.ellipse(position.x, position.y, width, height);
    pg.pushMatrix();
    pg.translate(position.x, position.y);
    pg.fill(canonColor);
    pg.rotate(knifeDir);
    pg.rect(width * 9 / 20, - width / 10, width / 10, width / 5);
    if (showCanon) {
      drawCanon();
    }
    pg.rotate(PI);
    pg.rect(width * 9 / 20, - width / 10, width / 10, width / 5);
    if (showCanon) {
      drawCanon();
    }
    pg.rotate(PI / 4);
    pg.fill(knifeColor);
    for (int i = 0; i < 4; i++) {
      pg.rotate(i * PI / 2);
      pg.rect(width * 9 / 20, - width / 30, width / 2, width / 15);
      pg.triangle(19 * width / 20, - width / 30, width, width / 30, 19 * width / 20, width / 30);
    }
    pg.fill(gunColor);
    pg.rotate(PI / 4);
    pg.rect(width * 9 / 20, - width / 20, width / 10, width / 10);
    pg.rotate(PI);
    pg.rect(width * 9 / 20, - width / 20, width / 10, width / 10);
    pg.popMatrix();
    pg.pushMatrix();
    pg.fill(0);
    pg.translate(position.x, position.y);
    pg.line(- 3 * width / 10, 0, 3 * width / 10, 0 );
    pg.line(- 2 * width / 5, 2.828 * width / 10, - 3 * width / 10, 0);
    pg.line(- 2 * width / 5, - 2.828 * width / 10, - 3 * width / 10, 0);
    pg.line(2 * width / 5, 2.828 * width / 10, 3 * width / 10, 0);
    pg.line(2 * width / 5, - 2.828 * width / 10, 3 * width / 10, 0);
    pg.line(0, 0, 0, 3 * width / 10);
    pg.line(2.828 * width / 10, 2 * width / 5, 0, 3 * width / 10);
    pg.line(- 2.828 * width / 10, 2 * width / 5, 0, 3 * width / 10);
    pg.triangle(- width / 6, - width / 6, - width / 12, - width / 6, - width / 8, - width / 12);
    pg.popMatrix();
    checkHit();
    for (int i = 0; i < myMissile.size(); i++) {
      Missile m = myMissile.get(i);
      m.draw();
      if (m.getWidth() / 2 + samurai.getWidth() / 2 >= caMag(m.position, samurai.position)) {
        samurai.loseLife();
        killList.add(i);
      }
    }
    for (int i : killList) {
      myMissile.remove(i);
    }
    killList = new ArrayList();
  }

  void act() {
    switch(status) {
    case "WIN":
      if (caMag(position, from) < caMag(from, to) / 2) {
        velocity += accelerate;
        position.x += velocity;
      } else if (velocity > 0) {
        velocity -= accelerate;
        if (velocity < 0)
          velocity = 0;
        position.x += velocity;
      } else {
        status = "WON";
      }
      break;
    case "COMEIN":
      if (caMag(position, from) < caMag(from, to) / 2) {
        velocity += accelerate;
        position.x -= velocity;
      } else if (velocity > 0) {
        velocity -= accelerate;
        if (velocity < 0)
          velocity = 0;
        position.x -= velocity;
      } else {
        returnThinking();
      }
      break;
    case "THINKING":
      if (counter < 100) {
        counter ++;
      } else {
        double rate = Math.random();
        if (samurai.getX() < pg.width * 0.5) {
          if (rate < 0.3) {
            status = "CANON";
          } else {
            status = "GUN";
          }
        } else {
          if (rate < 0.6) {
            status = "KNIFE";
            rotVelo = 0;
          } else if (rate < 0.8) {
            status = "GUN";
          } else {
            status = "CANON";
          }
        }
        counter = 0;
        hit = false;
      }
      shake();
      break;
    case "CANON":
      shake();
      if (counter <= 100) {
        canonColor = color(255, 0, 0, 255 * Math.abs(flashTimer - maxFlashTimer) / maxFlashTimer);
        if (flashTimer < maxFlashTimer)
          flashTimer ++;
        else {
          flashTimer = 0;
        }
        counter ++;
      } else if (counter < 200) {
        canonColor = color(255, 0, 0);
        showCanon = true;
        counter ++;
      } else {
        showCanon = false;
        canonColor = myColor;
        status = "THINKING";
        counter = 0;
      }
      break;
    case "KNIFE":
      shake();
      if (counter <= 100) {
        knifeColor = color(255, 0, 0, 255 * Math.abs(flashTimer - maxFlashTimer) / maxFlashTimer);
        if (flashTimer < maxFlashTimer)
          flashTimer ++;
        else {
          flashTimer = 0;
        }
        counter ++;
      } else if (counter < 200) {
        knifeColor = color(255, 0, 0);
        knifeDir += rotVelo;
        if (knifeDir < PI) {
          rotVelo += rotAcc;
        } else {
          rotVelo -= rotAcc;
          if (rotVelo < 0)
            rotVelo = 0;
        }
        counter ++;
      } else {
        knifeColor = myColor;
        knifeDir = 0;
        status = "THINKING";
        counter = 0;
      }
      break;
    case "GUN":
      shake();
      if (counter < 100) {
        gunColor = color(255, 0, 0, 255 * Math.abs(flashTimer - maxFlashTimer) / maxFlashTimer);
        if (flashTimer < maxFlashTimer)
          flashTimer ++;
        else {
          flashTimer = 0;
        }
        counter ++;
      } else if (counter < 200) {
        gunColor = color(255, 0, 0);
        if (counter % 50 == 0) {
          Missile m1 = new Missile(position.x, position.y - height / 2, width / 10, width / 10, myColor, true, pg);
          Missile m2 = new Missile(position.x, position.y + height / 2, width / 10, width / 10, myColor, false, pg);
          myMissile.add(m1);
          myMissile.add(m2);
        }
        counter ++;
      } else {
        gunColor = myColor;
        status = "THINKING";
        counter = 0;
      }
      break;
    case "FALL":
      if (caMag(position, from) < caMag(from, to)) {
        velocity += accelerate;
        position.y += velocity;
      } else {
        screen = "WIN";
      }
      break;
    }
  }

  void returnThinking() {
    velocity = 0;
    from = new PVector(position.x, position.y);
    if (position.y > 0.1 * pg.height)
      to = new PVector(position.x, position.y - 0.1 * pg.height);
    else {
      to = new PVector(position.x, position.y + 0.1 * pg.height);
    }
    showWarning = false;
    stopWarning();
    counter = 0;
    samurai.unlock();
    if (!samurai.sword.using)
      samurai.sword.turnOn();
    if (die) {
      die = false;
      millis += (millis() - dieTime);
    }
    status = "THINKING";
  }

  void drawCanon() {
    pg.noStroke();
    pg.fill(255);
    if (counter < 130) {
      pg.rect(width * 11 / 20, - (counter - 100) * width / 20  / 30, pg.width, (counter - 100) * width /  10 / 30);
    } else if (counter > 170 ) {
      pg.rect(width * 11 / 20, - (200 - counter) * width / 20  / 30, pg.width, (200 - counter) * width / 10 / 30);
    } else if (counter <= 200) {
      pg.rect(width * 11 / 20, - width / 20, pg.width, width / 10);
    }
    pg.fill(canonColor);
    pg.stroke(0);
  }

  void shake() {
    if (caMag(position, from) < caMag(from, to) / 2) {
      velocity += accelerate;
      if (from.y > to.y)
        position.y -= velocity;
      else {
        position.y += velocity;
      }
    } else if (velocity > 0) {
      velocity -= accelerate;
      if (velocity < 0)
        velocity = 0;
      if (from.y > to.y)
        position.y -= velocity;
      else {
        position.y += velocity;
      }
    } else {
      PVector inter = new PVector(from.x, from.y);
      from = new PVector(to.x, to.y);
      to = inter;
    }
  }

  void checkHit() {
    if (showCanon && !hit) {
      float sy = samurai.getY();
      float sr = samurai.getWidth() / 2;
      float topBorder = 0, botBorder = 0;
      if (counter < 130) {
        topBorder = position.y - (counter - 100) * width / 20  / 30;
        botBorder = position.y + (counter - 100) * width / 20  / 30;
      } else if ( counter > 170) {
        topBorder = position.y - (200 - counter) * width / 20  / 30;
        botBorder = position.y + (200 - counter) * width / 20  / 30;
      } else if ( counter <= 200) {
        topBorder = position.y - width / 20;
        botBorder = position.y + width / 20;
      }
      if (sy - sr >= topBorder && sy - sr <= botBorder) {
        hit = true;
        samurai.life = 0;
        samurai.loseAllLife();
      } else if (sy + sr >= topBorder && sy + sr <= botBorder) {
        hit = true;
        samurai.life = 0;
        samurai.loseAllLife();
      } else if (sy + sr >= botBorder && sy - sr <= topBorder) {
        hit = true;
        samurai.life = 0;
        samurai.loseAllLife();
      }
    } else if (knifeDir > 0 && ! hit) {
      float samuraiAngle = atan((samurai.getY() - position.y) / (samurai.getX() - position.x));
      if (Math.abs((samuraiAngle - knifeDir - PI / 4) % (PI / 2)) < PI / 10 && caMag(samurai.position, position) < width) {
        hit = true;
        samurai.loseLife();
        samurai.setBossPush();
      }
    }
  }

  void attacked() {
    colorCounter = 0;
    life --;
    if (life == 0) {
      if (!die) {
        die = true;
        dieTime = millis();
      }
      status = "FALL";
      from = new PVector(position.x, position.y);
      to = new PVector(position.x, pg.height + width / 2);
      if (samurai.sword.using)
        samurai.sword.turnOff();
    }
  }
}
