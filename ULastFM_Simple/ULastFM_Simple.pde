/*

ULastFM_Simple.pde - Marius Watz, Feb 2014
http://workshop.evolutionzone.com/
http://mariuswatz.com/

Demonstrates how to parse and display CSV data exported from last.fm. Sample
data is included, Last.fm users can request a CSV export from their
account settings. Also see the Last.fm API for a more advanced approach to 
querying Last.fm's database for relationships between data points etc.:

  https://secure.last.fm/settings/dataexporter
  http://www.last.fm/api

This code presents the data as a view of either a single year or an arbitrary 
time interval. If "isASingleYear" is TRUE, data points with dates outside the
year specified by "YEAR" will be rejected during parsing. 

Set "isASingleYear" to FALSE to use the actual time interval, or set "YEAR" to 
a year you know can be found in the data set. Specifying another set time interval
will require some changes to the code, but would not be hard to do.

Time calculations are done with the UTimestamp class, provided here as a
standalone Java file.

*/

import java.util.*;
import java.text.*;

String filename;

boolean isASingleYear=true;
int YEAR=2013;
String YEARSTR=""+YEAR;

boolean colorByPlays=true;

UTimestamp start, end; // time range
int dayRange;

float w, h;
float xOffs,yOffs;
int stepX,stepY;



public void setup() {
  size(1024, 768);
  smooth();

  filename="2013 lastfm - MariusWatz.csv";
//  filename="2009-20140123 lastfm - MariusWatz.csv";
  
  simpleDate=new SimpleDateFormat("dd.MM.y");// "MMM dd");
  simpleTime=new SimpleDateFormat("MMM d, HH:mm",Locale.US);// "MMM dd");
  UTimestamp.setTimeFormatter(simpleTime);
  UTimestamp.setDateFormatter(simpleDate);
  
  xOffs=0;
  yOffs=80;
  w=width-xOffs*2;
  h=height-yOffs;
  yOffs=yOffs;
}

public void draw() {
  background(0);
  noStroke();

  translate(xOffs, yOffs); // translate to offset

  if (parseStatus!=0) {
    try{    
      parseLastFM();   
    } catch(Exception e) {
      e.printStackTrace();
      exit();
    }
  }
  
  drawDayText();

  if (song==null || song.size()<1) return;
  noStroke();
  
  resetSongMouseOver();

  int cnt=0;  
  for (Song tmp : song) {    
    if(mousePressed) fill(255,100);
    else fill(tmp.getColor(),200);
  
    tmp.draw();
    if(mouseIsOver) checkSongMouseOver(cnt,tmp); 
    cnt++; 
  }
  
  drawMouseOver();
}

