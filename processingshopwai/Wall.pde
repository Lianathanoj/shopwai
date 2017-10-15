public class Wall {

   float x1;
   float y1;
   float x2;
   float y2;
   
   public Wall(float newX1, float newY1, float newX2, float newY2) {
        x1 = newX1;
        x2 = newX2;
       y1 = newY1;
       y2 = newY2;
   }
   
   public void drawWall(int r, int g, int b, int style) {
       if (style == 1) {
         stroke(r,g,b);
         strokeWeight(6);
         line(x1,y1,x2,y2);
         noStroke();
         stroke(r,g,b,220);
         strokeWeight(10);
         line(x1,y1,x2,y2);
         noStroke();
         stroke(r,g,b,150);
         strokeWeight(14);
         line(x1,y1,x2,y2);
         noStroke();
         stroke(r,g,b,50);
         strokeWeight(18);
         line(x1,y1,x2,y2);
         noStroke();
       } else if (style == 2) {
         stroke(r,g,b);
         strokeWeight(10);
         line(x1,y1,x2,y2);
         noStroke();
       }
   }
   float getX1() {
     return x1;
   }
   float getY1() {
     return y1;
   }
   float getX2() {
     return x2;
   }
   float getY2() {
     return y2;
   }
}