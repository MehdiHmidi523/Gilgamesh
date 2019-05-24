
Boid barry;
ArrayList<Boid> boids;
ArrayList<obstacle> avoids;

float globalScale = .91;
float eraseRadius = 20;
String tool = "boids";

// boid control
float maxSpeed;
float friendRadius;
float crowdRadius;
float avoidRadius;
float coheseRadius;

boolean option_friend = true;
boolean option_crowd = true;
boolean option_avoid = true;
boolean option_noise = true;
boolean option_cohese = true;

int messageTimer = 0;
String messageText = "";

// ------------------------Trump----------------------


void setup () {
  size(1024, 576);
  smooth();
  background(162);
  textSize(16);
  recalculateConstants();
  boids = new ArrayList<Boid>();
  avoids = new ArrayList<obstacle>();
  for (int x = 100; x < width - 100; x+= 100) 
    for (int y = 100; y < height - 100; y+= 100) 
      boids.add(new Boid(x + random(3), y + random(3))); 
  setupCircle();
}

void recalculateConstants () {
  maxSpeed = 2 * globalScale;
  friendRadius = 50 * globalScale;
  crowdRadius = (friendRadius / 1.3);
  avoidRadius = 50 * globalScale;
  coheseRadius = friendRadius;
}

void setupWalls() {
  avoids = new ArrayList<obstacle>();
   for (int x = 0; x < width; x+= 20) {
    avoids.add(new obstacle(x, 10));
    avoids.add(new obstacle(x, height - 10));
  } 
}

void setupCircle() {
  avoids = new ArrayList<obstacle>();
   for (int x = 0; x < 50; x+= 1) {
     float dir = (x / 30.0) * TWO_PI;
     avoids.add(new obstacle(width * 0.5 + cos(dir) * height*.4, height * 0.5 + sin(dir)*height*.4));
  }
}

void draw () {
  noStroke();
  colorMode(HSB);
  fill(0, 100);
  rect(0, 0, width, height);

  if (tool == "erase") {
    noFill();
    stroke(0, 100, 260);
    rect(mouseX - eraseRadius, mouseY - eraseRadius, eraseRadius * 2, eraseRadius *2);
    if (mousePressed)
      erase();
  } else if (tool == "avoids") {
    noStroke();
    fill(0, 200, 200);
    ellipse(mouseX, mouseY, 15, 15);
  }
  for (int i = 0; i <boids.size(); i++) {
    Boid current = boids.get(i);
    current.go();
    current.draw();
  }

  for (int i = 0; i <avoids.size(); i++) {
    obstacle current = avoids.get(i);
    current.go();
    current.draw();
  }
  if (messageTimer > 0)
    messageTimer -= 1; 
  drawGUI();
}

void keyPressed () {
  if (key == 'q') {
    tool = "boids";
    message("Add boids");
  } else if (key == 'w') {
    tool = "avoids";
    message("Place obstacles");
  } else if (key == 'e') {
    tool = "erase";
    message("Eraser");
  } else if (key == '-') {
    message("Decreased scale");
    globalScale *= 0.8;
  } else if (key == '=') {
      message("Increased Scale");
    globalScale /= 0.8;
  } else if (key == '1') {
     option_friend = option_friend ? false : true;
     message("Turned friend allignment " + on(option_friend));
  } else if (key == '2') {
     option_crowd = option_crowd ? false : true;
     message("Turned crowding avoidance " + on(option_crowd));
  } else if (key == '3') {
     option_avoid = option_avoid ? false : true;
     message("Turned obstacle avoidance " + on(option_avoid));
  }else if (key == '4') {
     option_cohese = option_cohese ? false : true;
     message("Turned cohesion " + on(option_cohese));
  }else if (key == '5') {
     option_noise = option_noise ? false : true;
     message("Turned noise " + on(option_noise));
  } else if (key == 'x') {
     setupWalls(); 
  } else if (key == 't') {
     setupCircle(); 
  }
  recalculateConstants();
}

void drawGUI() {
   if(messageTimer > 0) {
     fill((min(30, messageTimer) / 30.0) * 255.0);
    text(messageText, 10, height - 20); 
   }
}

void mousePressed () {
  switch (tool) {
  case "boids":
    boids.add(new Boid(mouseX, mouseY));
    message(boids.size() + " Total Boid" + s(boids.size()));
    break;
  case "avoids":
    avoids.add(new obstacle(mouseX, mouseY));
    break;
  }
}

String s(int count) {
  return (count != 1) ? "s" : "";
}

String on(boolean in) {
  return in ? "on" : "off"; 
}

void erase () {
  for (int i = boids.size()-1; i > -1; i--) {
    Boid b = boids.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius)
      boids.remove(i);
  }
  for (int i = avoids.size()-1; i > -1; i--) {
    obstacle b = avoids.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius)
      avoids.remove(i);
  }
}

void drawText (String s, float x, float y) {
  fill(0);
  text(s, x, y);
  fill(200);
  text(s, x-1, y-1);
}
void message (String in) {
   messageText = in;
   messageTimer = (int) frameRate * 3;
}
