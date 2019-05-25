class Samurai {
  PVector position;
  float width;
  float height;
  PVector initPosition;
  int life;
  int energy;
  PGraphics pg;
  float accelerate;
  float increment;
  float velocity;
  color myColor;
  boolean rec;
  Sword sword;
  ArrayList<Sword> mySwords;
  int swordIndex;
  float swordRote;
  float attackIncrement;
  boolean attacking;
  boolean lock;
  boolean hit;
  Sword ls;
  Sword ns;
  String status;
  int dieCounter;

  Samurai(float x, float y, float w, float h, PGraphics graphic) {
    this.initPosition = new PVector(x, y);
    this.position = new PVector(x, - h);
    this.width = w;
    this.height = h;
    this.life = 5;
    this.energy = 200;
    this.pg = graphic;
    this.increment = w / 10;
    this.accelerate = w / 200;
    myColor = color(#CAFF70);
    rec = false;
    sword = new Sword("Wooden Sword", false, 0, pg.width / 60, 1, color(255), color(255));
    swordRote = 7 * PI / 8;
    attackIncrement = PI / 32;
    attacking = false;
    lock = true;
    hit = false;
    mySwords = new ArrayList();
    mySwords.add(sword);
    swordIndex = 0;
    status = "BORN";
    dieCounter = 0;
  }

  float getX() {
    return position.x;
  }

  float getY() {
    return position.y;
  }

  float getWidth() {
    return width;
  }

  float getHeight() {
    return height;
  }

  int getLife() {
    return life;
  }

  int getEnergy() {
    return energy;
  }

  boolean isRec() {
    return rec;
  }

  void loseLife() {
    life --;
    hitSamurai.rewind();
    hitSamurai.play();
    if (life == 0) {
      loseAllLife();
    }
  }

  void loseAllLife() {
    lock();
    if (sword.using)
      sword.turnOff();
    die = true;
    startDie();
    dieTime = millis();
    status = "DIE";
    dieCounter = 0;
    hit = false;
    swordRote = 7 * PI / 8;
    attacking = false;
    if (!boss) {
      enemy.status = "WIN";
      enemy.velocity = 0;
      enemy.from = new PVector(enemy.position.x, enemy.position.y);
      enemy.to = new PVector(1.2 * pg.width, enemy.position.y);
    } else {
      theBoss.status  = "WIN";
      theBoss.velocity = 0;
      theBoss.showCanon = false;
      theBoss.from = new PVector(theBoss.position.x, theBoss.position.y);
      theBoss.to = new PVector(1.3 * pg.width, theBoss.position.y);
    }
    accelerate = width / 200;
    dieFor ++;
    showInfo("You die!");
  }

  void draw() {
    if (!lock)
      acc();
    switch(status) {
    case "BORN":
      born();
      break;
    case "ENEMYPUSH":
      pushBack();
      break;
    case "BOSSPUSH":
      bossPush();
      break;
    case "DIE":
      die();
      break;
    }
    pg.stroke(0);
    pg.fill(myColor);
    pg.ellipse(position.x, position.y, width, height);
    pg.pushMatrix();
    pg.strokeWeight(height * 0.1);
    pg.translate(position.x - width / 2 * 0.8, position.y - width / 2 * 0.6);
    pg.line(0, 0, width * 0.8, 0);
    pg.line(0, 0, - width / 5, - width / 5);
    pg.line(0, 0, - width / 3, width / 5);
    pg.ellipse(width * 0.6, width * 0.2, width * 0.1, width * 0.1);
    pg.popMatrix();
    pg.pushMatrix();
    pg.translate(position.x - width / 2, position.y + width / 2 * 0.2);
    pg.line(0, 0, width, 0);
    pg.popMatrix();
    pg.pushMatrix();
    pg.translate(position.x + 0.6 * width, position.y + width / 20);
    attack();
    pg.rotate(swordRote);
    pg.stroke(sword.getBladeColor());
    pg.line(width / 2, 0, 7 * width / 10 + sword.getLength(), 0);
    pg.stroke(sword.getHandleColor());
    pg.line(7 * width / 10, - width / 10, 7 * width / 10, width / 10);
    pg.popMatrix();
    if (inRange() && !hit) {
      hitEnemy.rewind();
      hitEnemy.play();
      if (!boss) {
        enemy.attacked();
        hit = true;
      } else {
        theBoss.attacked();
        hit = true;
      }
    }
    if (sword.getMillis() <= 0 && sword.limited) {
      removeSword();
      showInfo("Your sword is so rusty that you lose it.");
    }
  }

  void drawSwords() {
    dataPanel.fill(0);
    dataPanel.stroke(255);
    dataPanel.strokeWeight(0.05 * dataPanel.height);
    dataPanel.strokeJoin(10);
    dataPanel.rect(dataPanel.width * 0.78, dataPanel.height * 0.1, 0.1 * dataPanel.width, dataPanel.height * 0.8);
    dataPanel.rect(dataPanel.width * 0.7, dataPanel.height * 0.4, 0.06 * dataPanel.width, dataPanel.height * 0.5);
    dataPanel.rect(dataPanel.width * 0.9, dataPanel.height * 0.4, 0.06 * dataPanel.width, dataPanel.height * 0.5);
    dataPanel.strokeJoin(0);
    dataPanel.stroke(sword.getHandleColor());
    dataPanel.line(0.82 * dataPanel.width, 0.3 * dataPanel.height, 0.84 * dataPanel.width, 0.3 * dataPanel.height);
    dataPanel.stroke(sword.getBladeColor());
    dataPanel.line(0.83 * dataPanel.width, 0.3 * dataPanel.height - 0.02 * dataPanel.width, 0.83 * dataPanel.width, 0.3 * dataPanel.height + sword.getLength() / (width / 5) * (0.02 * dataPanel.width));
    dataPanel.textSize(0.2 * dataPanel.height);
    dataPanel.textAlign(CENTER, CENTER);
    dataPanel.fill(255);
    dataPanel.text("ATK: " + sword.damage, 0.2 * dataPanel.width, 0.3 * dataPanel.height);
    if (mySwords.size() > 1) {
      if (swordIndex == 0) {
        ls = mySwords.get(mySwords.size() - 1);
        ns = mySwords.get(swordIndex + 1);
      } else if (swordIndex == mySwords.size() - 1) {
        ls = mySwords.get(swordIndex - 1);
        ns = mySwords.get(0);
      } else {
        ls = mySwords.get(swordIndex - 1);
        ns = mySwords.get(swordIndex + 1);
      }
      dataPanel.textSize(0.15 * dataPanel.height);
      dataPanel.strokeWeight(0.03 * dataPanel.height);
      dataPanel.stroke(ls.getHandleColor());
      dataPanel.line(0.724 * dataPanel.width, 0.525 * dataPanel.height, 0.736 * dataPanel.width, 0.525 * dataPanel.height);
      dataPanel.stroke(ls.getBladeColor());
      dataPanel.line(0.73 * dataPanel.width, 0.525 * dataPanel.height - 0.012 * dataPanel.width, 0.73 * dataPanel.width, 
        0.525 * dataPanel.height + ls.getLength() / (width / 5) * (0.012 * dataPanel.width));
      dataPanel.text("ATK: " + ls.damage, 0.73 * dataPanel.width, 0.2 * dataPanel.height);
      dataPanel.stroke(ns.getHandleColor());
      dataPanel.line(0.924 * dataPanel.width, 0.525 * dataPanel.height, 0.936 * dataPanel.width, 0.525 * dataPanel.height);
      dataPanel.stroke(ns.getBladeColor());
      dataPanel.line(0.93 * dataPanel.width, 0.525 * dataPanel.height - 0.012 * dataPanel.width, 0.93 * dataPanel.width, 
        0.525 * dataPanel.height + ns.getLength() / (width / 5) * (0.012 * dataPanel.width));
      dataPanel.text("ATK: " + ns.damage, 0.93 * dataPanel.width, 0.2 * dataPanel.height);
    }
  }

  public void moveLeft() {
    position.x -= increment;
    if (position.x <= width / 2)
      position.x = width / 2;
  }

  public void moveRight() {
    position.x += increment;
    if (!boss) {
      if (position.x >= 0.95 * pg.width - width)
        position.x = 0.95 * pg.width - width;
    } else {
      if (position.x >= 0.6 * pg.width - width)
        position.x = 0.6 * pg.width - width;
    }
  }

  void pushBack() {
    position.x -= increment * 2;
    if (position.x <= pg.width / 10) {
      status = "";
      position.x = pg.width / 10;
      showWarning = true;
      startWarning();
      if (score < 10) {
        enemy = new Enemy(1.5 * pg.width, 0.5 * pg.height, height, height, pg);
        enemy.status = "COMEIN";
      } else {
        boss = true;
        enemy.status = "WAIT";
      }
    }
  }

  void bossPush() {
    position.x -= increment * 2;
    if (position.x <= pg.width * 0.4) {
      status = "";
      position.x = pg.width * 0.4;
      unlock();
    }
  }

  void die() {
    if (accelerate > 0)
      velocity += accelerate;
    position.y += velocity;
    if (position.y >= pg.height + height) {
      if (dieCounter < 100)
        dieCounter ++;
      else if (enemy.status.equals("WON") || theBoss.status.equals("WON")) {
        position.x = initPosition.x;
        position.y = - height;
        showWarning = true;
        startWarning();
        if (enemy.status.equals("WON"))
          enemy = new Enemy(1.5 * pg.width, 0.5 * pg.height, height, height, pg);
        else {
          theBoss = new Boss(1.3 * pg.width, 0.5 * pg.height, 0.2 * pg.width, 0.2 * pg.width, pg);
        }
        status = "BORN";
        velocity = 0;
      }
    }
  }

  void born() {
    if (position.y < initPosition.y / 2) {
      velocity += accelerate;
    } else {
      velocity -= accelerate * 1.5;
      if (velocity <= 0)
        velocity = 0;
    }
    position.y += velocity;
    if (velocity == 0) {
      life = 5;
      energy = 200;
      status = "";
      if (!sword.using)
        sword.turnOn();
      enemy.status = "COMEIN";
    }
  }

  void acc() {
    if (energy == 0) {
      accelerate = width /200;
      rec = true;
    } 
    if (accelerate > 0 && energy < 200) {
      energy += 4;
    } else if (accelerate < 0 && energy > 0) {
      energy -= 2;
    }
    if (!lock) {
      velocity +=accelerate;
      position.y += velocity;
    }
    if (position.y < width / 2) {
      velocity = 0;
      position.y = width / 2;
    } else if (position.y > pg.height) {
      life = 0;
      loseAllLife();
    }
  }

  public void fall() {
    this.accelerate = width / 200;
  }

  public void rise() {
    this.accelerate = - width / 200;
  }

  public void setRec(boolean r) {
    this.rec = r;
  }

  public Sword getSword() {
    return sword;
  }

  public void attack() {
    if (attacking) {
      if (swordRote == 7 * PI / 8) {
        swordRote = - PI / 2;
      } else if (swordRote < PI / 2) {
        swordRote += attackIncrement;
      } else {
        hit = false;
        swordRote = 7 * PI / 8;
        attacking = false;
      }
    }
  }

  public void setAttack() {
    if (!attacking && energy >= 30 && !lock) {
      attacking = true;
      energy -= 30;
      atkPlayer.rewind();
      atkPlayer.play();
    }
  }

  boolean inRange() {
    if (!boss) {
      float angle = atan((enemy.getY() - position.y) / (enemy.getX() - position.x - 0.6 * width));
      float offset = asin(enemy.getWidth() / 2 / caMag(new PVector(position.x + 0.6 * width, position.y), enemy.position));
      float topBorder = angle + offset;
      float botBorder = angle - offset;
      if (swordRote > botBorder && swordRote < topBorder && caMag(new PVector(position.x + 0.6 * width, position.y), enemy.position) < (7 * width / 10 + sword.getLength()))
        return true;
      else {
        return false;
      }
    } else {
      PVector sd = new PVector(position.x + 0.6 * width + (7 * width / 10 + sword.getLength()) * cos(swordRote), position.y + width / 20 + (7 * width / 10 + sword.getLength()) * sin(swordRote));
      if (caMag( sd, theBoss.position) < theBoss.width / 2)
        return true;
      else {
        return false;
      }
    }
  }

  void lock() {
    this.lock = true;
  }

  void unlock() {
    lock = false;
  }

  void enemyPush() {
    status = "ENEMYPUSH";
  }

  void setBossPush() {
    status = "BOSSPUSH";
  }

  void getSword(Sword s) {
    mySwords.add(s);
    showInfo("You get a new sword (Length: " + (int)s.getLength() + ", ATK: " + s.getDamage());
  }

  void nextSword() {
    if (mySwords.size() > 1) {
      if (sword.using)
        sword.turnOff();
      if (swordIndex == mySwords.size() - 1) {
        swordIndex = 0;
      } else {
        swordIndex ++;
      }
      sword = mySwords.get(swordIndex);
      if (!enemy.status.equals("COMEIN") && !enemy.status.equals("FALL") && !enemy.status.equals("DEAD") )
        sword.turnOn();
    }
  }

  void lastSword() {
    if (mySwords.size() > 1) {
      if (sword.using)
        sword.turnOff();
      if (swordIndex == 0) {
        swordIndex = mySwords.size() - 1;
      } else {
        swordIndex --;
      }
      sword = mySwords.get(swordIndex);
      if (!enemy.status.equals("COMEIN") && !enemy.status.equals("FALL") && !enemy.status.equals("DEAD") )
        sword.turnOn();
    }
  }

  void removeSword() {
    mySwords.remove(swordIndex);
    if (swordIndex == mySwords.size()) {
      swordIndex = 0;
    }
    sword = mySwords.get(swordIndex);
    if (!enemy.status.equals("COMEIN") && !enemy.status.equals("FALL") && !enemy.status.equals("DEAD") )
      sword.turnOn();
  }
}
