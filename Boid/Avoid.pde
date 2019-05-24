class obstacle {
   PVector pos;
   
   obstacle (float xx, float yy) {
     pos = new PVector(xx,yy);
   }
   
   void go () {
     
   }
   
   void draw () {
     fill(0, 255, 200);
     ellipse(pos.x, pos.y, 15, 15);
   }
}
