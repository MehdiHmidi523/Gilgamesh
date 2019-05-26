// Bachelor Thesis
// Mehdi Hmidi
// https://mehdihmidi523.github.io

//  UAV "arrive"

UAV v;
UAV x;
ArrayList<UAV> cluster_1 = new ArrayList<UAV>();
ArrayList<UAV> cluster_2 = new ArrayList<UAV>();
ArrayList<UAV> avoid = new ArrayList<UAV>();

void setup() {
  size(1000, 800);
  for (int i = 0; i < 5; i++) 
    cluster_1.add(new UAV(2+random(0,75),height+random(0,75)));
  for (int i = 0; i < 10; i++) 
    cluster_2.add(new UAV(2+random(0,75),2+random(0,75)));
    x = new UAV(350+random(0,75),height);
    x.r = 12;
    avoid.add(x);
}

void draw() {
  background(255);
  // Draw an ellipse at the mouse position 
  PVector mouse = new PVector(width/2, height/2);
  fill(99,255,32);
  stroke(0);
  strokeWeight(2);
  ellipse(mouse.x, mouse.y, 15, 15);  
  PVector objective2 = new PVector(350, 0);
 // Call the appropriate steering behaviors for our agents
 for (int i = 0; i < cluster_1.size(); i++) {
    cluster_1.get(i).flock(cluster_1);
    cluster_1.get(i).flock(cluster_2);
    cluster_1.get(i).flock(avoid);
    cluster_1.get(i).arrive(mouse);
    cluster_1.get(i).update();
    cluster_1.get(i).render();
    cluster_1.get(i).repel(avoid.get(0).position,200,20,20);
 }
 for (int i = 0; i < cluster_2.size(); i++) {
    cluster_2.get(i).col= color(91,94,231);
    cluster_2.get(i).flock(cluster_2);
    cluster_2.get(i).flock(cluster_1);
    cluster_2.get(i).flock(avoid);
    cluster_2.get(i).arrive(mouse);
    cluster_2.get(i).update();
    cluster_2.get(i).render();
    cluster_2.get(i).repel(avoid.get(0).position,200,20,20);
 }
 
 for (int i = 0; i < avoid.size(); i++) {
    avoid.get(i).col= color(150,177,210);
    avoid.get(i).flock(avoid);
    avoid.get(i).arrive(objective2);
    avoid.get(i).update();
    avoid.get(i).render();
 }
}
