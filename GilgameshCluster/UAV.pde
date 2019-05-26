// Bachelor Thesis
// Mehdi Hmidi
// https://mehdihmidi523.github.io

// The "UAV" class

class UAV {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;
  float maxspeed;    
  color col;
  UAV(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(0,0);
    position = new PVector(x,y);
    r = 2.0; //size of arrow
    maxspeed = 2;
    maxforce = 0.03;
    col = color(255, 0, 0);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
   }
  void applyForce(PVector force) {acceleration.add(force);}
  void arrive(PVector target) {
    PVector desired = PVector.sub(target,position);  // Desired vector points to the target
    float d = desired.mag();
    // Scale with arbitrary damping within 100 pixels
    if (d < 100) {
      float m = map(d,0,100,0,maxspeed);
      desired.setMag(m);
    } else
      desired.setMag(maxspeed);
    // STEER = DESIRED - VELOCITY  
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);
    applyForce(steer);
    borders();
  }
  void render() { 
    float theta = velocity.heading() + radians(90);
    noStroke();
    fill(col);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape();
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape(CLOSE);
    popMatrix();
  }

  /**
   * Repels an object away from a target.
   * @param target  target to repel away from
   * @param threshold  if target is within this threshold then repel away from it
   * @param repelValue value specifying repulsion, this is the magnitude.
   * @param maxRepel   maximum repulsion value
   */
  public void repel(PVector target, float threshold, float repelValue, float maxRepel) {
    float distanceT = target.dist(position);
    if (distanceT > 0 && distanceT < threshold) {
      PVector desired = PVector.sub(target, position);
      desired.normalize();
      desired.mult(repelValue);
      PVector steerTarget = PVector.sub(desired, velocity);
      steerTarget.limit(maxRepel);
      steerTarget.mult(-1);
      velocity.add(steerTarget);
    }
  }
  
  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<UAV> drones) {
    PVector sep = separate(drones);   // Separation
    PVector ali = align(drones);      // Alignment
    PVector coh = cohesion(drones);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(3);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }
  
  // Separation
  PVector separate (ArrayList<UAV> drones) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (UAV other : drones) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }
    if (count > 0) steer.div((float)count);
    //Steering = Desired - Velocity
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
  
  // Alignment
  PVector align (ArrayList<UAV> drones) {
    float neighbordist = 70;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (UAV other : drones) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    }
    else
      return new PVector(0, 0);
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby drones, calculate steering vector towards that position
  PVector cohesion (ArrayList<UAV> drones) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (UAV other : drones) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    }
    else 
      return new PVector(0, 0);
  }
  
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    return steer;
  }
  
  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }
}
