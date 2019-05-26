class Unit {
  PVector pos;
  PVector move;
  float shade;
  ArrayList<Unit> friends;
  // timers
  int thinkTimer = 0;
  Unit (float xx, float yy) {
    move = new PVector(0, 0);
    pos = new PVector(0, 0);
    pos.x = xx;
    pos.y = yy;
    thinkTimer = int(random(10));
    shade = random(255);
    friends = new ArrayList<Unit>();
  }

  void go () {
    increment();
    if (thinkTimer ==0 )
      getFriends();
    flock();
    arrive(new PVector(width - 50,height/2));
    pos.add(move);
  }
  
 // STEER = DESIRED MINUS VELOCITY
  void arrive(PVector target) {
    PVector desired = PVector.sub(target,pos);  // A vector pointing from the position to the target
    float d = desired.mag();
    // Scale with arbitrary damping within 100 pixels
    if (d < 100) {
      float m = map(d,0,100,0,maxSpeed);
      desired.setMag(m);
    } else {
      desired.setMag(maxSpeed);
    }
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,move);
    steer.limit(0.05);  // Limit to maximum steering force
    move.add(steer);
  }
  
   public void repel(PVector target, float threshold, float repelValue, float maxRepel) {
    float distanceT = target.dist(pos);
    if (distanceT > 0 && distanceT < threshold) {
      PVector desired = PVector.sub(target, pos);
      desired.normalize();
      desired.mult(repelValue);
      PVector steerTarget = PVector.sub(desired, move);
      steerTarget.limit(maxRepel);
      steerTarget.mult(-1);
      move.add(steerTarget);
    }
  }
  
  void flock () {
    PVector allign = getAverageDir();
    PVector avoidDir = getobstacleDir(); 
    PVector avoidObjects = getobstacleobstacles();
    PVector noise = new PVector(random(2) - 1, random(2) -1);
    PVector cohese = getCohesion();

    allign.mult(1);
    if (!option_friend) allign.mult(0);
    
    avoidDir.mult(1);
    if (!option_crowd) avoidDir.mult(0);
    
    avoidObjects.mult(3);
    if (!option_avoid) avoidObjects.mult(0);

    noise.mult(0.1);
    if (!option_noise) noise.mult(0);

    cohese.mult(1);
    if (!option_cohese) cohese.mult(0);
    
    stroke(0, 255, 160);

    move.add(allign);
    move.add(avoidDir);
    move.add(avoidObjects);
    move.add(noise);
    move.add(cohese);

    move.limit(maxSpeed);
    
    shade += getAverageColor() * 0.03;
    shade += (random(2) - 1) ;
    shade = (shade + 255) % 255; //max(0, min(255, shade));
  }

  void getFriends () {
    ArrayList<Unit> nearby = new ArrayList<Unit>();
    for (int i =0; i < Units.size(); i++) {
      Unit test = Units.get(i);
      if (test == this) continue;
      if (abs(test.pos.x - this.pos.x) < friendRadius &&
        abs(test.pos.y - this.pos.y) < friendRadius) {
        nearby.add(test);
      }
    }
    friends = nearby;
  }

  float getAverageColor () {
    float total = 0;
    float count = 0;
    for (Unit other : friends) {
      if (other.shade - shade < -128) {
        total += other.shade + 255 - shade;
      } else if (other.shade - shade > 128) {
        total += other.shade - 255 - shade;
      } else {
        total += other.shade - shade; 
      }
      count++;
    }
    if (count == 0) return 0;
    return total / (float) count;
  }

  PVector getAverageDir () {
    PVector sum = new PVector(0, 0);
    int count = 0;

    for (Unit other : friends) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < friendRadius)) {
        PVector copy = other.move.copy();
        copy.normalize();
        copy.div(d); 
        sum.add(copy);
        count++;
      }
      if (count > 0) {
        //sum.div((float)count);
      }
    }
    return sum;
  }

  PVector getobstacleDir() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (Unit other : friends) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < crowdRadius)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    if (count > 0) {
      //steer.div((float) count);
    }
    return steer;
  }

  PVector getobstacleobstacles() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (obstacle other : avoids) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < avoidRadius)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    return steer;
  }
  
  PVector getCohesion () {
   float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Unit other : friends) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < coheseRadius)) {
        sum.add(other.pos); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      
      PVector desired = PVector.sub(sum, pos);  
      return desired.setMag(0.05);
    } 
    else {
      return new PVector(0, 0);
    }
  }

  void draw(){
    for ( int i = 0; i < friends.size(); i++) {
      Unit f = friends.get(i);
      stroke(0);
      line(this.pos.x, this.pos.y, f.pos.x, f.pos.y);
    }
    noStroke();
    fill(shade, 90, 200);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(move.heading());
    beginShape();
    vertex(15 * globalScale, 0);
    vertex(-7* globalScale, 7* globalScale);
    vertex(-7* globalScale, -7* globalScale);
    endShape(CLOSE);
    popMatrix();
  }

  // update all those timers!
  void increment () {
    thinkTimer = (thinkTimer + 1) % 5;
  }

}
