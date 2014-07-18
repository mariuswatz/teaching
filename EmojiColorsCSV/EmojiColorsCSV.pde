import toxi.color.Histogram;
import java.util.Iterator;

/**
 * EmojiColorsCSV.pde - Marius Watz, 2014
 * http://workshop.evolutionzone.com
 * 
 * Download the file "Emoji.zip" from this URL:
 * 
 * The archive must be unzipped before running so that the images end
 * up in a subfolder "Emoji".
 *
 * ---------------------------------------------
 *
 * Requires Toxiclibs: http://toxiclibs.org/
 *
 * Based on ImageColors.pde from Toxiclibs.
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * Creating image based color palettes and color decimation through means
 * of using a histogram.
 *
 * This variant shows how to extract dominant color from a set of emoji and 
 * save a list of those colors to a CSV file.
 */



import toxi.color.*;
import toxi.math.*;

// color tolerance
float tolerance=0.25;

// number of colors to save 
int numColors=12;


void setup() {
  size(520, 620);

  load();
  export("EmojiColors.csv");
}

void draw() {
  background(255);
  
  int index=0;
  int offset=(int)map(mouseX, 0,width-1, 0,images.size()-50);
  
  for(int i=0; i<100; i++) {
    EmojiImg tmp=images.get((offset+i)%images.size());
    tmp.draw(10+(i%10)*50,10+(i/10)*60, 40);
  }
}


