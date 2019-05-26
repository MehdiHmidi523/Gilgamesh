
Vehicle v;
ArrayList<Vehicle> cluster_1 = new ArrayList<Vehicle>();

void setup() {
  size(500, 400);
  
  for (int i = 0; i < 13; i++) 
    cluster_1.add(new Vehicle(2+random(0,75),2+random(0,75)));
 
  //v = new Vehicle(2, height/2);
}

void draw() {
  background(255);

  // Draw an ellipse at the mouse position 
  PVector mouse = new PVector(width-60, height-60);
  fill(99,255,32);
  stroke(0);
  strokeWeight(2);
  ellipse(mouse.x, mouse.y, 15, 15);  
  // Draw an ellipse at the mouse position
  fill(200);


  // Call the appropriate steering behaviors for our agents
  for (int i = 0; i < cluster_1.size(); i++){
     cluster_1.get(i).arrive(mouse);
     cluster_1.get(i).update();
     cluster_1.get(i).display();
     cluster_1.get(i).flock(cluster_1);
  }

}
