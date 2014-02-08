import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

import processing.core.PApplet;

public class UTimeline {
  public SimpleDateFormat DATEFORMAT=new SimpleDateFormat("yyyy.MM.dd", Locale.US);
  public SimpleDateFormat TIMEFORMAT=new SimpleDateFormat("mm.HH", Locale.US);
  public SimpleDateFormat DATETIMEFORMAT=new SimpleDateFormat("yyyy.MM.dd HH.mm", Locale.US);

  // scrub
  // constant speed anim
  // draw all instances
  // adding events
  // 

  public ArrayList<UTimeEvent> ev;
  public long tmin=-1, tmax=-1, tD;
  public PApplet p;

  public UTimeline(PApplet p) {
    this.p=p;
    ev=new ArrayList<UTimeEvent>();

    DATEFORMAT.setTimeZone(TimeZone.getTimeZone("GMT+1"));
    TIMEFORMAT.setTimeZone(TimeZone.getTimeZone("GMT+1"));
    DATETIMEFORMAT.setTimeZone(TimeZone.getTimeZone("GMT+1"));
  }

  public void add(UTimeEvent event) {
    ev.add(event);
    updateBounds();
  }

  public long getTimestamp(
  int year, int month, int dayofmonth, 
  int hr, int min, int sec) {
    Calendar ctmp=Calendar.getInstance();
    ctmp.set(Calendar.MILLISECOND, 0);

    ctmp.set(year, month, dayofmonth, hr, min, sec);
    return ctmp.getTimeInMillis();
  }

  public void updateBounds() {  	
    if (ev.size()>0) updateBounds(ev.get(ev.size()-1));
  }

  public float fraction(long timestamp) {
    float f=PApplet.map(timestamp, tmin, tmax, 0, 1);
    f=(float)(timestamp-tmin)/(float)(tmax-tmin);
    return f;
  }

  public void printBounds() {
    System.out.println("Timeline events: "+ev.size());
    System.out.println("Earliest time: "+DATETIMEFORMAT.format(tmin)+" "+tmin+" "+fraction(tmin));
    System.out.println("Latest time: "+DATETIMEFORMAT.format(tmax)+" "+tmax+" "+fraction(tmax));
  }

  public void draw() {
    for (UTimeEvent event : ev) event.draw();
  }

  public void updateBounds(UTimeEvent event) {
    if (event.timestamp<0) return;

    if (tmin<0) {
      tmin=event.timestamp;
      tmax=event.timestamp;
    }
    else {
      if (event.timestamp<tmin) tmin=event.timestamp;
      if (event.timestamp>tmax) tmax=event.timestamp;
    }
    tD=tmax-tmin;
  }
}

