import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

int minute, second, mills;
PGraphics dataPanel;
PGraphics gameGraphic;
PFont timeFont;
color lifeColor;
Samurai samurai;
Enemy enemy;
boolean showWarning;
int infoCounter;
int flashTimer;
int maxFlashTimer;
color warnColor;
String info;
boolean die;
int dieTime;
int startTime;
int millis;
int score;
Boss theBoss;
boolean boss;
String screen;
int dieFor;
Minim minim;
AudioPlayer warningPlayer;
AudioPlayer backPlayer;
AudioPlayer diePlayer;
AudioPlayer atkPlayer;
AudioPlayer hitEnemy;
AudioPlayer hitSamurai;
void setup() {
  fullScreen();
  dataPanel = createGraphics(width, 3 * height / 10);
  gameGraphic = createGraphics(width, 7 * height / 10);
  minute = 0;
  second = 0;
  mills = 0;
  timeFont = createFont("UnidreamLED.ttf", 20);
  lifeColor = color(#B22222);
  samurai = new Samurai(0.1 * width, 0.5 * gameGraphic.height, 0.1 * height, 0.1 * height, gameGraphic);
  enemy = new Enemy(1.5 * width, 0.5 * gameGraphic.height, 0.1 * height, 0.1 * height, gameGraphic);
  showWarning = true;
  flashTimer = 0;
  maxFlashTimer = 20;
  warnColor = color(255, 0, 0);
  infoCounter = 300;
  die = true;
  dieTime = 0;
  startTime = 0;
  millis = 0;
  score = 0;
  theBoss = new Boss(1.3 * width, 0.5 * gameGraphic.height, 0.2 * gameGraphic.width, 0.2 * gameGraphic.width, gameGraphic);
  boss = false;
  screen = "START";
  dieFor = 0;
  minim = new Minim(this);
  warningPlayer = minim.loadFile("warning.mp3");
  backPlayer = minim.loadFile("back.mp3");
  diePlayer = minim.loadFile("die.mp3");
  atkPlayer = minim.loadFile("atk.mp3");
  hitEnemy = minim.loadFile("hit_enemy.mp3");
  hitSamurai = minim.loadFile("hit_samurai.mp3");
}

void draw() {
  switch(screen) {
  case "GAME":
    drawGame();
    image(dataPanel, 0, 7 * height / 10);
    image(gameGraphic, 0, 0);
    break;
  case "WIN":
    drawWin();
    break;
  case "START":
    drawStart();
    break;
  }
}

void drawWin() {
  background(0);
  textFont(timeFont);
  textSize(0.05 * width);
  textAlign(CENTER, CENTER);
  text("Congratulations!", 0.5 * width, 0.3 * height);
  textSize(0.03 * width);
  text("Press 'ENTER' to try again!", 0.5 * width, 0.8 * height);
  textSize(0.04 * width);
  textAlign(LEFT, CENTER);
  text("Time :", 0.3 * width, 0.5 * height);
  text("Die :", 0.3 * width, 0.6 * height);
  textAlign(RIGHT, CENTER);
  text(getMinute() + " : " + getSecond() + " : " + getMillis(), 0.7 * width, 0.5 * height);
  text(dieFor + " Times", 0.7 * width, 0.6 * height);
}


void drawStart() {
  background(0);
  textFont(timeFont);
  textSize(0.05 * width);
  textAlign(CENTER, CENTER);
  text("Stubborn samurai", 0.5 * width, 0.3 * height);
  textSize(0.03 * width);
  text("Press 'ENTER' to play!", 0.5 * width, 0.8 * height);
}

void drawGame() {
  dataPanel.beginDraw();
  dataPanel.background(0);
  dataPanel.fill(255);
  dataPanel.stroke(255);
  dataPanel.strokeWeight(0.05 * dataPanel.height);
  dataPanel.line(0, 0, width, 0);
  dataPanel.textFont(timeFont);
  dataPanel.textSize(dataPanel.height * 0.5);
  dataPanel.textAlign(RIGHT, CENTER);
  dataPanel.text(getMinute() + " : " + getSecond() + " : " + getMillis(), 0.6 * dataPanel.width, 0.4 * dataPanel.height);
  dataPanel.textAlign(CENTER, CENTER);
  dataPanel.textSize(dataPanel.height * 0.1);
  dataPanel.fill(255, 255, 0);
  if (infoCounter < 100) {
    dataPanel.text(info, 0.45 * dataPanel.width, 0.8 * dataPanel.height);
    infoCounter ++;
  }
  dataPanel.fill(lifeColor);
  dataPanel.noStroke();
  dataPanel.ellipse(0.1 * dataPanel.width, 0.5 * dataPanel.height, 0.4 * dataPanel.height, 0.4 * dataPanel.height);
  dataPanel.fill(0);
  for (int i = 0; i < 4; i++) {
    float sy = 0.3 * dataPanel.height + 3 * dataPanel.height / 20 * 2 / 5 * (i + 1) + dataPanel.height * 2 / 5 / 16 * i;
    dataPanel.rect(0.1 * dataPanel.width - 0.2 * dataPanel.height, sy, 0.4 * dataPanel.height, dataPanel.height * 2 / 5 / 16);
  }
  for (int i = 0; i < 5 - samurai.getLife(); i++) {
    float sy = 0.3 * dataPanel.height + 3 * dataPanel.height / 20 * 2 / 5 * i + dataPanel.height * 2 / 5 / 16 * i;
    dataPanel.rect(0.1 * dataPanel.width - 0.2 * dataPanel.height, sy, 0.4 * dataPanel.height, dataPanel.height * 2 / 5 * 3 / 20);
  }
  dataPanel.stroke(255);
  dataPanel.strokeWeight(0.05 * dataPanel.height);
  dataPanel.noFill();
  dataPanel.arc(0.1 * dataPanel.width, 0.5 * dataPanel.height, 0.45 * dataPanel.height, 0.45 * dataPanel.height, - PI / 2, - PI / 2 + 2 * PI * samurai.getEnergy() / 200);
  dataPanel.textSize(dataPanel.height * 0.2);
  dataPanel.fill(255);
  dataPanel.textAlign(LEFT, CENTER);
  if (!samurai.getSword().isLimited())
    dataPanel.text("00", 0.1 * dataPanel.width + 0.2 * dataPanel.height, 0.8 * dataPanel.height);
  else {
    dataPanel.text(samurai.getSword().getMinute() + ":" + samurai.getSword().getSecond(), 0.1 * dataPanel.width + 0.2 * dataPanel.height, 0.8 * dataPanel.height);
  }
  samurai.drawSwords();
  dataPanel.endDraw();
  if (!samurai.lock) {
    if (keyPressed) {
      switch(key) {
      case 'a':
      case 'A':
        samurai.moveLeft();
        break;
      case 'd':
      case 'D':
        samurai.moveRight();
        break;
      }
    }
    if (!mousePressed )
      samurai.fall();
    else if (!samurai.isRec())
      samurai.rise();
  }
  gameGraphic.beginDraw();
  gameGraphic.background(127);
  samurai.draw();
  if (! boss) {
    if (!enemy.status.equals("WAIT")) {
      enemy.draw();
      if (showWarning) {
        drawWarning();
      }
    }
  } else {
    theBoss.draw();
    if (showWarning)
      drawWarning();
  }
  gameGraphic.endDraw();
}

int calMillis() {
  if (die){
    return dieTime - millis;
  }
  else {
    return millis() - millis;
  }
}
String getMillis() {
  if (calMillis() % 1000 / 100 == 1) {
    return "  " + calMillis() % 1000 / 100;
  } else {
    return "" + calMillis() % 1000 / 100;
  }
}

String getSecond() {
  int second = calMillis() / 1000 % 60;
  if (second < 10) {
    return "0" + second;
  } else
    return second + "";
}

int getMinute() {
  return calMillis() / 60000;
}

void mouseReleased() {
  if (samurai.isRec()) {
    samurai.setRec(false);
  }
}

void keyPressed() {
  switch(screen) {
  case "GAME":
    if (key == ' ')
      samurai.setAttack();
    if (key == 'q' || key == 'Q' && !samurai.lock) {
      samurai.lastSword();
    } else if (key == 'e' || key == 'E' && !samurai.lock) {
      samurai.nextSword();
    }
    break;
  case "WIN":
  case "START":
    if (key == ENTER) {
      setup();
      screen = "GAME";
      startWarning();
      //millis += (millis() - dieTime);
    }
    break;
  }
}

void drawWarning() {
  gameGraphic.fill(warnColor, 255 * Math.abs(flashTimer - maxFlashTimer / 2) / maxFlashTimer);
  gameGraphic.textFont(timeFont);
  gameGraphic.textAlign(CENTER, CENTER);
  if (!boss) {
    gameGraphic.textSize(width / 20);
    gameGraphic.text("Enemy Coming", gameGraphic.width * 0.5, 0.1 * gameGraphic.height);
  } else {
    gameGraphic.textSize(height * 3 / 10);
    gameGraphic.text("WARNING!", gameGraphic.width / 2, gameGraphic.height / 2);
  }
  if (flashTimer < maxFlashTimer)
    flashTimer ++;
  else {
    flashTimer = 0;
  }
}

void showInfo(String i) {
  info = i;
  infoCounter = 0;
}

void startWarning(){
  if(!warningPlayer.isPlaying()){
    warningPlayer.play();
    warningPlayer.loop();
  }
  if(backPlayer.isPlaying()){
    backPlayer.pause();
    backPlayer.rewind();
  }
}

void stopWarning(){
  if(warningPlayer.isPlaying()){
    warningPlayer.pause();
    warningPlayer.rewind();
  }
  if(!backPlayer.isPlaying()){
    backPlayer.play();
    backPlayer.loop();
  }
}

void startDie(){
  diePlayer.rewind();
  diePlayer.play();
  if(backPlayer.isPlaying()){
    backPlayer.pause();
    backPlayer.rewind();
  }
}

float caMag(PVector v1, PVector v2) {
  PVector pv = new PVector(v2.x - v1.x, v2.y - v1.y) ;
  return pv.mag() ;
}
