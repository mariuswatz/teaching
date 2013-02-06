/* PinterestScrape - Marius Watz, Jan 2013
http://workshop.evolutionzone.com/
http://github.com/mariuswatz/teaching

Basic scraping of images + pin info from Pinterest
using JSoup (http://jsoup.org). Downloads pin info and 
images by crawling a profile page and setting up downloads
for that user's boards. The tool saves the current status
and so can be interrupted and re-started at will.

Data is put in "pinterest" folder, with index files in CSV format.
Images of pins end up in "pinterest/images". indexPins.csv contains 
the pin info.

Configure by filling in your username in URLBASEUSER.
Time between HTTP is defined by "timeout", change at your
own risk. Pinterest's Terms of Service implies that they frown
on scraping.

*/

import java.awt.image.BufferedImage;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.imageio.ImageIO;

import org.jsoup.*;
import org.jsoup.Connection.Response;
import org.jsoup.nodes.*;
import org.jsoup.select.*;

String URLBASE="http://pinterest.com/", 
URLBASEUSER=URLBASE+"watzmarius/", 
HREF="href", ABSHREF="abs:href";
String DATACLOSEUPURL="data-closeup-url";
String FOLDER;

int PROFILE=0, BOARD=1, IMAGE=2;
ArrayList<Doc> docs, imgIndex;
HashMap<String, Integer> failMap;

int docCnt, docDoneCnt, lastID;
Doc nextDoc;

long lastRead, timeout;
float textX, textY, textLeading;
private float textW;

public void setup() {
  size(1024, 768);

  FOLDER=sketchPath("pinterest")+"/";
//  FOLDER=sketchPath(;

  // check what files have been previously downloaded
  getFileList();

  // set timeout between each HTTP call
  timeout=10000;
  lastRead=System.currentTimeMillis()-timeout;

  PFont font=createFont("Courier", 12, false);
  textFont(font);
  textLeading=font.getSize();
  println(textLeading);
}

public void draw() {
  background(255);
  fill(255);

  long timeCheck=System.currentTimeMillis()-lastRead;

  drawDebug();

  fill(0);
  setTextPos(20, textLeading*1.5f);

  if (timeCheck>timeout) {
    if (nextDoc==null) getFileList();

    if (nextDoc!=null) {
      drawText("Loading document: "+nextDoc.url);

      nextDoc.download();
      lastRead=System.currentTimeMillis();
      nextDoc=null;
    }
  }
  else {
    drawText("Time to next load: "+((timeout-timeCheck)/1000)+" seconds.");
  }
}

public void drawDebug() {
  fill(255, 100, 0);
  setTextPos(20, textLeading*2.5f);
  drawText("----------------------------------");
  drawText("Index: "+docCnt+" documents, "+
    docDoneCnt+" done.");

  for (Doc d:docs) {
    if (d.done==0 && textX<width-200) {
      drawText(d.urlShort);
    }
  }

  fill(100);
  for (Doc d:docs) {    
    if (d.done>0 && textX<width-200) {
      drawText(d.urlShort);
    }
  }
}

public void setTextPos(float x, float y) {
  textX=x;
  textY=y;    
  textW=0;
}

public void drawText(String theText) {
  text(theText, textX, textY);
  textW=max(textW, textWidth(theText));
  textY+=textLeading;

  if (textY>height-textLeading*1.5f) {
    setTextPos(textX+textW+50, textLeading*2.5f);
  }
}



