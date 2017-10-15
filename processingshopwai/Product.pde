public class Product {

   float x;
   float y;
   String name;

   
   public Product(String n) {
      name = n;
   }
   
   public void drawProduct(int r, int g, int b, int style) {
       noStroke();
       fill(0);
       ellipse(x, y, 10, 10);
   }
   public void setCoords(float newX, float newY) {
     x = newX;
     y = newY;
   }
   public String getInfo() {
     return name + "," + x + "," + y + "\n";
   }
}