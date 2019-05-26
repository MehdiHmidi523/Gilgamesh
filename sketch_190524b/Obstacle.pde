class obstacle {
   PVector pos;
   
   obstacle (float x, float y) {
     pos = new PVector(x,y);
   }
   
   void go () {
     
   }
   
   void draw () {
     fill(0, 255, 200);
     ellipse(pos.x, pos.y, 5, 5);
   }
}
