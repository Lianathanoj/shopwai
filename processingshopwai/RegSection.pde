public class RegSection {

   float x;
   float y;
   float w;
   float h;
   
   public RegSection(float newX, float newY, float newW, float newH) {
      x = newX;
      y = newY;
      w = newW;
      h = newH;
   }
   
   public void drawSect(int r, int g, int b, int style) {
       //Style 1 = fuzzy edges
       if (style == 1 && w >= 10 && h >= 10) {
         fill(r,g,b);
         noStroke();
         rect(x + 5,y + 5,w - 10,h - 10);
         fill(r,g,b,220);
         rect(x,y,w,h);
         fill(r,g,b,150);
         rect(x - 5,y - 5,w + 10,h + 10);
         fill(r,g,b,50);
         rect(x - 10,y - 10,w + 20,h + 20);
       } else if (style == 2 || w < 10 || h < 10) {
          fill(r,g,b);
          noStroke();
          rect(x,y,w,h);
       }
   }
   float getX() {
     return x;
   }
   float getY() {
     return y;
   }
   float getW() {
     return w;
   }
   float getH() {
     return h;
   }
}