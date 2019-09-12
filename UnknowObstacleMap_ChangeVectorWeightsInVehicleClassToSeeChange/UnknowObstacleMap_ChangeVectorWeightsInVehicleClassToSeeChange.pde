
Unit barry;
ArrayList<Unit> Units;
ArrayList<obstacle> avoids;

float globalScale = .5;
float eraseRadius = 20;
String tool = "Units";

// Unit control
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
PrintWriter output;
Threat threat;
long start = System.currentTimeMillis();
long finish = 0;
long timeElapsed = finish - start;
void setup () {
  size(700,700);
  output = createWriter("Goal2STEPSNORMALWEIGHTS.txt"); //Specify for https://app.rawgraphs.io/
  smooth();
  background(162);
  textSize(16);
  recalculateConstants();
  Units = new ArrayList<Unit>();
  avoids = new ArrayList<obstacle>();
  
  for (int x = 0; x < 24; x++) Units.add(new Unit(70, height -50 + x));
  
  setupWalls();
  setupScenario_1();
}

void recalculateConstants () {
  maxSpeed = 1.3 * globalScale;
  friendRadius = 50 * globalScale;
  crowdRadius = (friendRadius / 1.5);
  avoidRadius = 15 * globalScale;
  coheseRadius = friendRadius;
}

void setupWalls() {
  avoids = new ArrayList<obstacle>();
   for (int x = 0; x < width; x+= 2) {
    avoids.add(new obstacle(x, 10));
    avoids.add(new obstacle(x, height - 10));
    avoids.add(new obstacle(10,x));
    avoids.add(new obstacle(width - 10,x));
  } 
}

void setupScenario_1() {
  for (int x = height-107; x < height-30; x++) {//right
     for (int f = 130; f < 131; f++){
     avoids.add(new obstacle(f,x));
     }
  }
  for (int x = height-107; x < height-30; x++) {//left
     for (int f = 30; f < 31; f++){
     avoids.add(new obstacle(f,x));
     }
  }
  for (int x = 30; x < 112; x++) {
     for (int f = height-107; f < height-105; f++){//top
     avoids.add(new obstacle(x,f));
     }
  }
  
  for (int x = height/2; x < height/2+60; x++) {//left
     for (int f = 30; f < 33; f++){
     avoids.add(new obstacle(x,x)); //croisee
     }
  }
 
 
  for (int x = width/2 ; x < width/2+110; x++) {//left
     for (int f = height/2; f < height/2+2; f++){
     avoids.add(new obstacle(x,f));
     }
  } 
  
  //base top left
  for (int x = 40; x < height/2-100; x++) {
     for (int f = height/2; f < height/2+2; f++){//top
     avoids.add(new obstacle(x,f));
     }
  }
  
  //right top left
   for (int x = height/2-200; x < height/2; x++) {//right
     for (int f = height/2-100; f < height/2-100+2; f++){
     avoids.add(new obstacle(f,x));
     }
  }
 
   for (int x =100; x < height/2-50; x++) {
     for (int f = height/2; f < height/2+2; f++){//top
     avoids.add(new obstacle(f,x));
     }
  } 
  
  for (int x = width/2-30 ; x < width/2+110; x++) {//left
     for (int f = height/2-50; f < height/2-48; f++){
     avoids.add(new obstacle(x,f));
     }
  }
}

void setupScenario_2(){
  threat = new Threat(width/2,height/2+60); // enable line 80;
}

void setupScenario_3(){
  for (int x = 0; x < height/2; x+= 10) 
     avoids.add(new obstacle(width/2-60,x));   
  avoids.add(new obstacle(height/2,height/2));
  avoids.add(new obstacle(height/2-40,height/2+30));
  avoids.add(new obstacle(height/2,height/2));
  avoids.add(new obstacle(height/2-40,height/2+30));
  avoids.add(new obstacle(height/2+40,height/2));
  avoids.add(new obstacle(height/2+40,height/2+30));
  threat = new Threat(width/2,height/2); // enable line 80;
}

void draw () {
  noStroke();
  colorMode(HSB);

  fill(255, 255);
  rect(0, 0, width, height);

  int xx=0;
  for (int i = 0; i <Units.size(); i++) {
    Unit current = Units.get(i);
    System.out.println("Unit"+i+":{ X = "+current.pos.x+"; Y = "+current.pos.y+"; "+current.steps);
    output.println("Unit "+i+";"+current.pos.x+";"+current.pos.y+"; "+current.steps);
    float x = current.pos.x;
    float y = current.pos.y;
    
    current.go();
    current.draw();
    
    if((Math.abs(current.pos.x - x) < 5) || (Math.abs(current.pos.y - y) < 5))
      current.steps++;
    if(Math.abs(current.pos.x - x)<1)
      current.repel(new PVector(x,y),1,2,5);
    
    if(current.pos.x>600 && current.pos.y<100){
      current.move=new PVector(0,0);
      xx++;
    }
  }
  
  if(xx>20){
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
    exit();  // Stops the program
  }
  
  for (int i = 0; i <avoids.size(); i++) {
    obstacle current = avoids.get(i);
    current.go();
    current.draw();
    
  }
  if (messageTimer > 0)
    messageTimer -= 1; 
  
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
  drawGUI();
}




void keyPressed () {
  if (key == 'q') {
    tool = "Units";
    message("Add Units");
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
  case "Units":
    Units.add(new Unit(mouseX, mouseY));
    message(Units.size() + " Total Unit" + s(Units.size()));
    break;
  case "avoids":
    for (int x = mouseX; x < mouseX+150; x++) 
       for (int f = mouseY; f < mouseY+1; f++)//top
           avoids.add(new obstacle(x,f));
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
  for (int i = Units.size()-1; i > -1; i--) {
    Unit b = Units.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius)
      Units.remove(i);
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
