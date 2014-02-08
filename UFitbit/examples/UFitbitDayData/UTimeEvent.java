import java.util.Calendar;

import processing.core.PApplet;
import unlekker.modelbuilder.UVec3;

public class UTimeEvent {
	public float SECPERHOUR=60*60;
	public float SECPERDAY=24*SECPERHOUR;
	public float MILLIPERDAY=24*SECPERHOUR*1000;
	public PApplet p;
	
  public long timestamp=-1;
  public UTimeline timeline;
  public Calendar cal;
  public float tPos; 
  public UVec3 pos;
  
  public UTimeEvent(UTimeline timeline) {
    this.timeline=timeline;
    p=timeline.p;
    timeline.add(this);
  }
  
  public void set(Calendar cal) {
  	this.cal=cal;
    timestamp=cal.getTimeInMillis();
    timeline.updateBounds(this);
  }

  public void set(long tt) {
    timestamp=tt;
    cal=Calendar.getInstance();
    cal.setTimeInMillis(timestamp);
    
    timeline.updateBounds(this);        
  }
  
  public void draw() {
  }
  
  public float fractionOfDay() {
    Calendar ctmp=Calendar.getInstance();
    ctmp.setTimeInMillis(timestamp);
    
    return PApplet.map(
    		ctmp.get(Calendar.HOUR_OF_DAY)*SECPERHOUR+
    		ctmp.get(Calendar.MINUTE)*60+ctmp.get(Calendar.SECOND),
    		0,SECPERDAY-1,0,1);
  }
  

  public float fractionOfMonth() {  	
  	float maxDay=cal.getMaximum(Calendar.DAY_OF_MONTH);
  	float minDay=cal.getMinimum(Calendar.DAY_OF_MONTH);
  	System.out.println("maxDay "+maxDay+" "+minDay+" month="+cal.get(Calendar.MONTH));
    return 0;
  }

  public float fractionOfYear() {
    return 0;
  }

  public float fractionOfWeek() {
    return 0;
  }

  
  public float fractionTimeline() {
    return timeline.fraction(timestamp);    
  }
}
