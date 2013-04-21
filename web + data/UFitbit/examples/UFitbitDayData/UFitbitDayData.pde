/********************

unlekker.data.fitbit - Marius Watz, 2013
GitHub: https://github.com/mariuswatz/teaching

Demonstrates reading UFitbitDay data downloaded with UFitbit.
Sample data files can be found in the "data" folder. The example
requires Processing 2.0b and the Modelbuilder library:
https://github.com/mariuswatz/modelbuilder

http://workshop.evolutionzone.com

Shared under Creative Commons "share-alike non-commercial use only" 
license.

*/


import unlekker.util.*;
import unlekker.modelbuilder.*;
import unlekker.modelbuilder.filter.*;
import ec.util.*;
import java.io.*;


  UFitbitDay fb;
  UTimeline tl;
  UNav3D nav;
  
  public void setup() {
    size(800, 600,P3D);
        
    nav=new UNav3D(this);
    nav.setTranslation(width/2,height/2,0);
    
    loadData();
  }

  public void draw() {
    background(255);

    // use 3D camera
    noStroke();
    fill(255,0,0);
    lights();
    nav.doTransforms();
    
    scale(0.1);
    for(UGeometry geo : days) {
      geo.draw(this);
    }
    
  }
  
  class FBEvent extends UTimeEvent {
    float activeScore;
    float steps;
    
    public FBEvent(UTimeline timeline) {
      super(timeline);
      // TODO Auto-generated constructor stub
    }
    
    public void draw() { 
      p.pushMatrix();
      p.translate(map(timeline.fraction(timestamp),0,1,0,width),0);
      p.fill(150);
      p.rect(0,0,1,activeScore*10);
      p.fill(0);
      p.rect(1,0,1,steps*2);
      p.popMatrix();
      
    }
  }

