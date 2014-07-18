class EmojiImg {
  PImage img;
  ArrayList<Integer> col;
  String code;
  
  
  EmojiImg(String filename) {
    code="u"+filename.substring(0, filename.length()-4);
    
    img=loadImage(path+filename);
    img.loadPixels();

    Histogram hist=Histogram.newFromARGBArray(
      img.pixels, img.pixels.length, tolerance, true);
    col=new ArrayList<Integer>();

    for (HistEntry e : hist.getEntries ()) {
      col.add(e.getColor().toARGB());
    }
  }
  
  void draw(int x,int y,int W) {
    pushMatrix();
    translate(x,y);
    
    stroke(200);
    fill(240);
    rect(-5,-5,W+10,W+15);
    
    image(img, 0,0,W,W);
    
    int W2=W/numColors;
    
    noStroke();
    for(int i=0; i<min(numColors,col.size()); i++) {
      fill(col.get(i));
      rect(i*W2,W+5, W2,5);
    }
    popMatrix();
  }
}



