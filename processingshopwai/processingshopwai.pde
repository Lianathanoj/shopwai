//MapMaking
int tBox = 1;
boolean clicked;
boolean keyP;
float firstX;
float firstY;
ArrayList<RegSection> sectList = new ArrayList<RegSection>();
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<Wall> walls = new ArrayList<Wall>();
float circX;
float circY;
int mode = 1;
float imageBackX;
float imageBackY;
int selectedImg = 0;  
BufferedReader reader;
PrintWriter output;
String line;
ArrayList<Product> newProducts = new ArrayList<Product>();
ArrayList<Product> setProducts = new ArrayList<Product>();
PImage map;
boolean usingImage = false;
boolean gridSnapOn = true;
boolean duplicating = false;
float duplicatingX;
float duplicatingY;
float duplicatingX2;
float duplicatingY2;
float duplicatingW;
float duplicatingH;
PImage drawImg;
PImage undoImg;
PImage copyImg;
PImage drawImg2;
PImage undoImg2;
PImage copyImg2;


//Uploading Images
boolean uploading = true;
PImage uploadingImage;
boolean imageUploaded = false;
boolean mousePress = false;
boolean uploadingFile = false;
int imageNum = 0;

import controlP5.*;
 
ControlP5 cp5;
String[] filenames;
int fileNum;
 
String textValue = "";
PFont font;
PrintWriter output2;
boolean selecting = false;
int numCharsRemove = 0;

void setup() {
  size(1000, 600); 
  background(255);
  clicked = false;
  keyP = false;
  drawImg = loadImage("draw.png");
  undoImg = loadImage("undo.png");
  copyImg = loadImage("copy.png");
  drawImg2 = loadImage("draw2.png");
  undoImg2 = loadImage("undo2.png");
  copyImg2 = loadImage("copy2.png");
  font = createFont("arial", 20);
  cp5 = new ControlP5(this);
  fill(0);
  cp5.addTextfield("  ")
     .setPosition(350,250)
     .setSize(200,45)
     .setFont(font)
     .setFocus(true)
     .setColor(color(0,0,0))
     .setColorActive(color(0,0,0)) 
     .setColorBackground(color(255,255,255))
     .setColorCursor(color(100,100,100));
     ;
 output2 = createWriter("products.txt");
}
void setupMapMaking() {
  for (int i = 1; i <= imageNum; i++){
   PImage img = loadImage("images/" + i + ".jpg");
   images.add(img);
  }
  reader = createReader("products.txt");
  output = createWriter("finalProducts.txt");
    try {
      while( (line = reader.readLine() ) != null) {
        Product p = new Product(line);
        newProducts.add(p);
      }
    } catch(IOException e) {
      e.printStackTrace();
    }
}

void draw() {
  if (!mousePressed) {
    mousePress = false;
  }
  if (uploading) {
    background(220);
    noStroke();
    textSize(70);
    textAlign(CENTER);
    fill(0,0,0);
    text("Add Your Products!", 500, 80);
    textAlign(LEFT);
    textSize(32);
    text("Upload Image", 100, 150);
    text("Or Choose File", 100, 220);
    text("Add Name", 100, 280);
    if (imageUploaded) {
      image(uploadingImage, 600, 120, 300, 300); 
    }
    if (mouseX >= 350 && mouseX <= 550 && mouseY >= 190 && mouseY <= 235) {
      fill(255);
      rect(350, 190, 200, 45);
      fill(0,0,0);
      rect(440, 210, 20, 20);
      triangle(430, 210, 450, 195, 470, 210);
      if (mousePressed && !mousePress) {
          selectFolder("Select an image of your product:", "folderSelected");
          mousePress = true;
          //getNextImage();
      }
    } else {
      fill(0);
      rect(350, 190, 200, 45);
      fill(255);
      rect(440, 210, 20, 20);
      triangle(430, 210, 450, 195, 470, 210);
    }
    if (mouseX >= 350 && mouseX <= 550 && mouseY >= 120 && mouseY <= 165) {
      fill(255);
      rect(350, 120, 200, 45);
      fill(0,0,0);
      rect(440, 140, 20, 20);
      triangle(430, 140, 450, 125, 470, 140);
      if (mousePressed && !mousePress) {
          selectInput("Select an image of your product:", "fileSelected");
          mousePress = true;
      }
    } else {
      fill(0,0,0);
      rect(350, 120, 200, 45);
      fill(255);
      rect(440, 140, 20, 20);
      triangle(430, 140, 450, 125, 470, 140);
    }
    if (mouseX >= 350 && mouseX <= 550 && mouseY >= 320 && mouseY <= 370) {
      fill(255);
      rect(350,320,200,50);
      fill(0);
      textAlign(CENTER);
      text("Submit", 450, 355);
      if (mousePressed && !mousePress) {
        PImage partialSave = get(600,120,300,300);
        imageNum++;
        partialSave.save("images/" + imageNum + ".jpg");
        output2.println(cp5.get(Textfield.class,"  ").getText());
        imageUploaded = false;
        cp5.get(Textfield.class,"  ").clear();
        if (uploadingFile) {
          if (fileNum < filenames.length) {
            getNextImage();
          } else {
            uploadingFile = false;
          }
        }
      }
    } else {
      fill(0);
      rect(350,320,200,50);
      fill(255);
      textAlign(CENTER);
      text("Submit", 450, 355);
    }
    if (mouseX >= 100 && mouseX <= 300 && mouseY >= 320 && mouseY <= 370) {
      fill(255);
      rect(100,320,200,50);
      fill(0);
      textAlign(CENTER);
      text("Submit", 200, 355);
      if (mousePressed && !mousePress) {
        imageUploaded = false;
        cp5.get(Textfield.class,"  ").clear();
        if (fileNum < filenames.length) {
          getNextImage();
        } else {
          uploadingFile = false;
        }
      }
    } else {
      fill(0);
      rect(100,320,200,50);
      fill(255);
      textAlign(CENTER);
      text("Delete", 200, 355);
    }
    if (mouseX >= 300 && mouseX <= 700 && mouseY >= 450 && mouseY <= 550) {
      fill(255);
      rect(300, 450, 400, 100);
      fill(0);
      textSize(70);
      text("Done", 500, 520);
      if (mousePressed && !mousePress && imageNum >= 1) {
        output2.flush(); // Writes the remaining data to the file
        output2.close(); // Finishes the file
        uploading = false;
        cp5.get(Textfield.class,"  ").remove();
        setupMapMaking();
      }
    } else {
      fill(0);
      rect(300, 450, 400, 100);
      fill(255);
      textSize(70);
      text("Done", 500, 520);
    }
    //System.out.println(cp5.get(Textfield.class,"  ").getText());
  } else {
    background(255);
    if (usingImage) {
      image(map, 0, 0, 700, 600);
    } else {
      for (RegSection r : sectList) {
         r.drawSect(160,160,160,2); 
      }
      for (Wall w : walls) {
         w.drawWall(100,100,100,1); 
      }
    }
    for (Product p: setProducts) {
       p.drawProduct(0,0,0,2); 
    }
    if (duplicating) {
      if (mode == 1) {
        float x = mouseX;
        float y = mouseY;
        if (abs(duplicatingX - x) < 50) {
          x = duplicatingX;
        }
        if (abs(duplicatingY - y) < 50) {
          y = duplicatingY;
        }
        stroke(200);
        strokeWeight(10);
        line((duplicatingX2 - duplicatingX) + x, (duplicatingY2 - duplicatingY) + y,x,y);
        noStroke(); 
        
      } else {
        float x = mouseX;
        float y = mouseY;
        if (abs(duplicatingX - x) < 50) {
          x = duplicatingX;
        }
        if (abs(duplicatingY - y) < 50) {
          y = duplicatingY;
        }
        fill(230);
        rect(x,y, duplicatingW, duplicatingH); 
      }
    }
    if (clicked && mode != 3) {
      float x = mouseX;
      float y = mouseY;
      float xMod = x % 5;
      float yMod = y % 5;
      if (xMod > 3) {
         x += (5-xMod);
       } else {
         x -= xMod;
       }
       if (yMod > 3) {
         y += (5-yMod);
       } else {
         y -= yMod;
       }
      if (mode == 1) {
        stroke(200);
        strokeWeight(10);
        line(circX, circY,x,y);
        noStroke(); 
      } else if (mode == 2) {
         fill(230);
         if (circX <= x) {
           if (circY <= y) {
              rect(circX,circY, x - circX, y - circY); 
           } else {
              rect(circX, y, x - circX, circY - y); 
           }
         } else {
           if (circY <= y) {
              rect(x,circY, circX - x, y - circY); 
           } else {
              rect(x, y, circX - x, circY - y); 
           }
         }
      }
      fill(255,0,0);
      ellipse(x, y, 10, 10);
      fill(0,0,0);
      noStroke();
      ellipse(circX, circY, 10,10);
    }
    fill(0,0,0);
    rect(700,0,300,600);
    if (mode == 3) {
      int col = 0;
      int row = 0;
      if (images.size() > 0) {
        image(images.get(0), 710, 120, 280, 280);
      }
      //for (PImage img: images) {
      //  if (col < 2) {
      //    image(img, 707 + (col * 145), 100 + (row*145), 140, 140);
      //    row++;
      //    if (row == 3) {
      //      row = 0;
      //      col++;
      //    } 
      //  }
      //}
    }
    drawButton();
    if (mode == 3 && mouseX < 700) {
      fill(255,0,0);
      noStroke();
      ellipse(mouseX, mouseY, 10,10);
    }
    tutorialBox();
  }
}
void tutorialBox() {
  if (tBox == 1) {
    noStroke();
    textSize(32);
    textAlign(CENTER);
    fill(50);
    rect(10, 10, 680, 50);
    fill(255);
    text("Click and Drag to add map elements.", 300, 45);
    if (mouseX >= 600 && mouseX <= 680 && mouseY >= 15 && mouseY <= 55) {
      fill(50);
      rect(600, 15, 80, 40);
      fill(200);
      text("OK", 640, 50);
      if (mousePressed) {
          tBox++;
          mousePress = true;
      }
    } else {
      fill(200);
      rect(600, 15, 80, 40);
      fill(50);
      text("OK", 640, 50);
    }
  } else if (tBox == 2) {
    noStroke();
    textSize(32);
    textAlign(CENTER);
    fill(50);
    rect(10, 10, 680, 50);
    fill(255);
    text("Use Copy to Duplicate the last item.", 300, 45);
    if (mouseX >= 600 && mouseX <= 680 && mouseY >= 15 && mouseY <= 55 && !mousePress) {
      fill(50);
      rect(600, 15, 80, 40);
      fill(200);
      text("OK", 640, 50);
      if (mousePressed) {
          tBox++;
      }
    } else {
      fill(200);
      rect(600, 15, 80, 40);
      fill(50);
      text("OK", 640, 50);
    }
  }
  
}
void drawButton() {
  noStroke();
  textSize(32);
  textAlign(CENTER);
  if (mode !=3) {
    if ((mouseX >= 720 && mouseX <= 980 && mouseY >= 275 && mouseY <= 395) || !duplicating) {
      image(drawImg2, 720, 275);
    } else {
      image(drawImg, 720, 275);
    }
    if (mouseX >= 720 && mouseX <= 840 && mouseY >= 410 && mouseY <= 530) {
      image(undoImg2, 720, 410);
    } else {
      image(undoImg, 720, 410); 
    }
    if ((mouseX >= 860 && mouseX <= 980 && mouseY >= 410 && mouseY <= 530) || duplicating) {
      image(copyImg2, 860, 410); 
    } else {
      image(copyImg, 860, 410); 
    }  
  }
  if (mode == 1) {
    fill(255);
    text("Draw the outline\n of the store.", 850, 40);
    
    text("OR\nUpload a map!", 850, 140);
  } else if (mode == 2) {
    fill(255);
    text("Add shelves and\naisles.", 850, 40);
    
    text("OR\nUpload a map!", 850, 140);
  } else if (mode == 3) {
    fill(255);
    text("Place products\n on the map.", 850, 40);
  }
  if (mode != 3) {
    if (mouseX > 720 && mouseX < 980 && mouseY > 215 && mouseY < 260) {
      fill(100);
      rect(720, 215, 260, 45);
      fill(200);
      text("UPLOAD", 850, 250);
    } else {
      fill(200);
      rect(720, 215, 260, 45);
      fill(100);
       text("UPLOAD", 850,250);
    }
  }
  if (mouseX > 720 && mouseX < 980 && mouseY > 545 && mouseY < 590) {
    fill(100);
    rect(720, 545, 260, 45);
    fill(200);
    if (mode == 3) {
      text("Finish", 850,580);
    } else if (mode ==2) {
      text("Go To 3", 850, 580);
    }  else if (mode ==1) {
      text("Go To 2", 850, 580);
    }
  } else {
    fill(200);
    rect(720, 545, 260, 45);
    fill(100);
    if (mode == 3) {
      text("Finish", 850,580);
    } else {
      text("Next", 850, 580);
    }
  }
}

void keyReleased() {
 
}

void mousePressed() {
  if (uploading) {
    //uploading = false;
    //setupMapMaking();
  } else {
    if (mouseX >= 720 && mouseX <= 840 && mouseY >= 410 && mouseY <= 530) {
      if (! keyP) {
        if (mode == 2) {
          if (sectList.size() > 0) {
             sectList.remove(sectList.size() - 1); 
            }
        } else if (mode == 1) {
          if (walls.size() > 0) {
            walls.remove(walls.size() - 1);
          }
        }
         keyP = true;
      }
    }
    if (mouseX >= 720 && mouseX <= 980 && mouseY >= 275 && mouseY <= 395) {
      duplicating = false;
    } else if ((mouseX >= 860 && mouseX <= 980 && mouseY >= 410 && mouseY <= 530)) {
      if (sectList.size() > 0 && mode == 2) {
        duplicating = true;
        RegSection r = sectList.get(sectList.size() - 1);
        duplicatingX = r.getX();
        duplicatingY = r.getY();
        duplicatingW = r.getW();
        duplicatingH = r.getH();
      } else if (walls.size() > 0 && mode == 1) {
        duplicating = true;
        Wall w = walls.get(walls.size() - 1);
        duplicatingX = w.getX1();
        duplicatingY = w.getY1();
        duplicatingX2 = w.getX2();
        duplicatingY2 = w.getY2();
      }
    }else if (mouseX > 710 && mouseX < 990 && mouseY > 545 && mouseY < 590) {
      if (mode == 3) {
        for (Product p: setProducts) {
         output.println(p.getInfo());
        }
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file
        background(255);
        if (usingImage) {
          image(map, 0, 0, 700, 600);
        } else {
          for (RegSection r : sectList) {
             r.drawSect(160,160,160,2); 
          }
          for (Wall w : walls) {
             w.drawWall(100,100,100,1); 
          }
        }
       PImage partialSave = get(0,0,700,600);
       partialSave.save("map.jpg");
       exit();
      } else {
        mode++;
        duplicating = false;
      }
    } else if (mouseX > 720 && mouseX < 980 && mouseY > 215 && mouseY < 260) {
      selectInput("Select a file to process:", "fileSelected");
    } else if (duplicating && mouseX < 700 && ((tBox > 2 || mouseY > 60))) {
      float x = mouseX;
      float y = mouseY;
      if (abs(duplicatingX - x) < 50) {
        x = duplicatingX;
      }
      if (abs(duplicatingY - y) < 50) {
        y = duplicatingY;
      }
      if (mode == 1) {
        float x2 = (duplicatingX2 - duplicatingX) + x;
        float y2 = (duplicatingY2 - duplicatingY) + y;
        Wall wall = new Wall(x, y,x2, y2);
        walls.add(wall);
      } else {
        RegSection newR = new RegSection(x, y, duplicatingW, duplicatingH);
        sectList.add(newR);
      }
    } else if (!clicked && mouseX < 700  && (tBox > 2 || mouseY > 60)) {
      if (mode == 3 && images.size() > 0) {
        clicked = true;
        Product thisProduct = newProducts.get(selectedImg);
        newProducts.remove(selectedImg);
        thisProduct.setCoords(mouseX, mouseY);
        setProducts.add(thisProduct);
        images.remove(selectedImg);
      } else {
        //System.out.println("Clicked");
       clicked = true;
       firstX = mouseX;
       firstY = mouseY;
       circX = firstX;
       circY = firstY; 
      }
    }
  }
}
void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    java.io.File folder = new java.io.File(dataPath(selection.getAbsolutePath()));
    filenames = folder.list();
    fileNum = 0;
    uploadingFile = true;
    println(filenames.length + " jpg files in specified directory");
    for (int i = 0; i < filenames.length; i++) {
      filenames[i] = selection.getAbsolutePath() + "\\" + filenames[i];
      println(filenames[i]);
    }
    numCharsRemove = selection.getAbsolutePath().length();
    uploadingImage = loadImage(filenames[0]);
    imageUploaded = true;
    String name = filenames[fileNum];
    System.out.println(name);
      int charNum = 0;
      for (int i = 0; i < name.length(); i++) {
        if (name.charAt(i) == '.') {
          charNum = i;
        }
      }
      cp5.get(Textfield.class,"  ").setText(name.substring(numCharsRemove + 1,charNum));
      fileNum = 1;
      if (fileNum >= filenames.length) {
        uploadingFile = false;
      }
  }
}

void getNextImage() {
  uploadingImage = loadImage(filenames[fileNum]);
  imageUploaded = true;
  String name = filenames[fileNum];
  System.out.println(name);
      println(name.charAt(8));
      println(name.charAt(8) == '.');
      int charNum = 0;
      for (int i = 0; i < name.length(); i++) {
        if (name.charAt(i) == '.') {
          charNum = i;
        }
      }
      cp5.get(Textfield.class,"  ").setText(name.substring(numCharsRemove + 1,charNum));
      fileNum++;
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    if (uploading) {
      println("User selected " + selection.getAbsolutePath());
      uploadingImage = loadImage(selection.getAbsolutePath());
      imageUploaded = true;
      String name = selection.getName();
      System.out.println(name);
      println(name.charAt(8));
      println(name.charAt(8) == '.');
      int charNum = 0;
      for (int i = 0; i < name.length(); i++) {
        if (name.charAt(i) == '.') {
          charNum = i;
        }
      }
      cp5.get(Textfield.class,"  ").setText(name.substring(0,charNum));
    } else {
      println("User selected " + selection.getAbsolutePath());
      map = loadImage(selection.getAbsolutePath());
      usingImage = true;
      mode = 3;
      duplicating = false;
    }
  }
}


void mouseReleased() {
  mousePress = false;
  if (uploading) {
   
  } else {
    keyP = false;
    //System.out.println("Released");
    if (clicked) {
      if (mode == 2) {
        //System.out.println(firstX + " " + firstY);
        //System.out.println(mouseX + " " + mouseY);
        float mX = mouseX;
        float mY = mouseY;
        float mXMod = mX % 5;
         if (mXMod > 3) {
           mX += (5-mXMod);
         } else {
           mX -= mXMod;
         }
         float mYMod = mY % 5;
         if (mYMod > 3) {
           mY += (5-mYMod);
         } else {
           mY -= mYMod;
         }
        float w;
        float h;
        float x;
        float y;
        if (firstX < mX) {
          x = firstX;
          if (mX > 700) {
            w = 700 - firstX;
          } else {
            w = mX - firstX;
          }
          if (firstY < mY) {
            y = firstY;
             h = mY - firstY;
          } else {
            y = mY;
            h = firstY - mY;
          }
        } else {
          x = mX;
          if (mX > 700) {
            w = firstX - 700;
          } else {
            w = firstX - mX;
          }
          if (firstY < mY) {
            y = firstY;
             h = mY - firstY;
          } else {
            y = mY;
            h = firstY - mY;
          }
        }
        //System.out.println(x + " " + y + " " + w + " " + h);
        RegSection newR = new RegSection(x, y, w, h);
        sectList.add(newR);
      } else if (mode == 1) {
        float x = mouseX;
        float y = mouseY;
        if (abs(firstX - x) < abs(firstY - y)) {
           if(abs(firstX - x) < 50) {
             x = firstX;
           }
        } else {
          if (abs(firstY - y) < 50) {
            y = firstY;
          }
        }
        Wall w = new Wall(firstX, firstY,x, y);
        walls.add(w);
      }
      clicked = false;
    }
  }
}