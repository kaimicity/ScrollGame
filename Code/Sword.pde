class Sword {
  String name;
  boolean limited;
  int millis;
  float length;
  int damage;
  color handleColor;
  color bladeColor;
  boolean using;
  int startTime;

  Sword(String name, boolean limited, int millis, float length, int damage, color hc, color bc) {
    this.name = name;
    this.limited = limited;
    this.millis = millis;
    this.length = length;
    this.damage = damage;
    this.handleColor = hc;
    this.bladeColor = bc;
    using = false;
  }

  public int getDamage() {
    return damage;
  }

  public int getMillis() {
    if (using)
      return millis - millis();
    else {
      return millis;
    }
  }

  public boolean isLimited() {
    return limited;
  }

  public int getMinute() {
    return getMillis() / 1000 / 60;
  }

  public int getSecond() {
    return getMillis() / 1000 % 60;
  }

  public color getBladeColor() {
    return bladeColor;
  }

  public color getHandleColor() {
    return handleColor;
  }

  public float getLength() {
    return length;
  }

  void turnOn() {
    using = true;
    startTime = millis();
    millis += startTime;
  }

  void turnOff() {
    using = false;
    millis -= millis();
  }
}
