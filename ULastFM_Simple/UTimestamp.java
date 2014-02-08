import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public class UTimestamp {
  private long t;
  Calendar cal;
  public static processing.core.PApplet papplet;
  
  public static long TSEC=1000;
  public static long TMIN=60*TSEC;
  public static long THR=60*TMIN;
  public static long end4HR=24*THR;

  public static SimpleDateFormat dateMonthDayShortF=new SimpleDateFormat("MMM d",Locale.US);
  public static SimpleDateFormat dateF=new SimpleDateFormat("EEE, d MMM",Locale.US);
  public static SimpleDateFormat timeF=new SimpleDateFormat("HH:mm:ss",Locale.US);
  public static SimpleDateFormat datetimeF=new SimpleDateFormat("yyyyMMdd HH:mm:ss",Locale.US);
  
  public static ArrayList<SimpleDateFormat> dateFormats;
  
  static { 
    dateFormats=new ArrayList<SimpleDateFormat>();
    dateFormats.add(new SimpleDateFormat("yyyyMMdd HH:mm:ss",Locale.US));
    dateFormats.add(new SimpleDateFormat("yyyyMMdd'T'hhmmss"));
    dateFormats.add(new SimpleDateFormat("EEE, d MMM yy HH:mm:ss Z",Locale.US));
    dateFormats.add(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss",Locale.US));    
    dateFormats.add(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss",Locale.US));
    dateFormats.add(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US));
    dateFormats.add(new SimpleDateFormat("dd.MM.yy HH:mm:ss", Locale.US));
    dateFormats.add(new SimpleDateFormat("dd.MM.yy", Locale.US));
    dateFormats.add(new SimpleDateFormat("dd.MM", Locale.US));
  };
  
  public UTimestamp() {
    cal=Calendar.getInstance();
  }

  public UTimestamp(String timestr) {
    this();
    set(parseDate(timestr));    
  }

  public UTimestamp(long t) {
    this();
    this.set(t);    
  }
  
  public UTimestamp copy() {
    return new UTimestamp(this);
  }
  
  public UTimestamp(UTimestamp timestamp) {
    this(timestamp.get());
  }

  public long get() {
    return t;
  }

  public UTimestamp set(long tt) {
    t = tt;
    return this;
  }

  public Calendar getCalendar() {
    Calendar c=Calendar.getInstance();
    c.setTimeInMillis(get());
    return c;
  }
  

  public static UTimestamp getDay(int year,int month,int day) {
    UTimestamp d=new UTimestamp(0);
    return d.setDate(year, month, day);
  }
  
  /*
   * Assumes that January = 1, first day of month =1
   */
  public UTimestamp setDate(int year,int month,int day) {
    cal.setTimeInMillis(get());
    cal.set(Calendar.YEAR, year);
    cal.set(Calendar.MONTH, Calendar.JANUARY+(month-1));
    cal.set(Calendar.DAY_OF_MONTH, cal.getMinimum(Calendar.DAY_OF_MONTH)+(day-1));

    set(cal.getTimeInMillis());
    
    return this;
  }
  
  public UTimestamp setEndOfDay() {
    return setStartOfDay().addHour(24).addMillis(-1000);
  }

  public UTimestamp setStartOfDay() {
    return setTime(0, 0, 0);
    
  }

  public UTimestamp setTime(int hr,int min,int sec) {
    cal.setTimeInMillis(get());
    cal.set(Calendar.HOUR_OF_DAY, hr);
    cal.set(Calendar.MINUTE, min);
    cal.set(Calendar.SECOND, sec);
    cal.set(Calendar.MILLISECOND, 0);

    set(cal.getTimeInMillis());
    
    return this;
  }

  public int dayOfWeek() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.DAY_OF_WEEK);
  }

  public int dayOfMonth() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.DAY_OF_MONTH);
  }

  public int month() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.MONTH)+(1-Calendar.JANUARY);
  }

  public int year() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.YEAR);
  }

  public int week() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.WEEK_OF_YEAR);
  }

  public int hour() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.HOUR_OF_DAY);
  }

  public int minute() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.MINUTE);
  }

  public int sec() {
    cal.setTimeInMillis(get());
    return cal.get(Calendar.SECOND);
  }

  public long dist(UTimestamp end) {
    return end.get()-get();
  }

  public int distInDays(UTimestamp end) {
    cal.setTimeInMillis(get());
    
    Calendar cal2=Calendar.getInstance();
    cal2.setTimeInMillis(end.get());
    if(end.isBefore(this)) {
      Calendar tmp=cal;
      cal=cal2;
      cal2=tmp;
    }

    int dayCnt=0;
    while(cal.before(cal2)) {
      cal.add(Calendar.DAY_OF_YEAR, 1);
//      if(end.isBefore(this)) cal.add(Calendar.DAY_OF_YEAR, -1);
      dayCnt++;
    }
    return dayCnt-1;
  }
  
  public UTimestamp addMillis(long ms) {
    set(get()+ms);
    return this;
  }

  public UTimestamp addHour(int hourD) {
    cal.setTimeInMillis(get());
    cal.add(Calendar.HOUR_OF_DAY, hourD);
    set(cal.getTimeInMillis());
    
    return this;
  }
  
  public UTimestamp getDeltaDuration(long durationms) {
    return new UTimestamp(get()+durationms);
  }

  public static UTimestamp getDeltaDuration(UTimestamp start,long durationms) {
    return new UTimestamp(start.get()+durationms);
  }

//  public static long[] getBeforeAfter()
//      
//  }
//

  
  public boolean isSameDay(UTimestamp start) {
    cal.setTimeInMillis(get());
    int dat[]=new int[] {
        cal.get(Calendar.YEAR),
        cal.get(Calendar.MONTH),
        cal.get(Calendar.DAY_OF_MONTH)
    };
    
    cal.setTimeInMillis(start.get());
    return (dat[0]==cal.get(Calendar.YEAR) &&
        dat[1]==cal.get(Calendar.MONTH) &&
        dat[2]==cal.get(Calendar.DAY_OF_MONTH));
  }
  
  public boolean isBefore(UTimestamp start) {
    return start.get()>get();
  }

  public boolean inRange(UTimestamp start,UTimestamp end) {
    return (get()>= start.get() && get()<end.get());
  }

  public float timelinePos(UTimestamp start,UTimestamp end) {
    long tD=(end.get()>start.get() ? end.get()-start.get() : start.get()-end.get());
    long tmpT=(end.get()>start.get() ? get()-start.get() : get()-end.get());
    double T=papplet.map((float)tmpT, 0, tD-1, 0, 1f);

    return (float)T;
  }
  
  public static long parseDate(String input) {
    long res=Long.MIN_VALUE;
    
    if(input.indexOf(' ')==-1) try {
      res=Long.parseLong(input);
      return res;
    }catch (Exception e) {res=Long.MIN_VALUE;} 

    for(SimpleDateFormat df:dateFormats) {
      try {
        res=df.parse(input).getTime();
        return res;
      }catch (Exception e) {res=Long.MIN_VALUE;} 
    }
    
    if(res==Long.MIN_VALUE) {
      papplet.println("UTimestamp.parseLong failed: "+input);
      res=0;
    }
    
    return res;
  }
  

  public static void setDateTimeFormatter(SimpleDateFormat df) {
    datetimeF=df;
  }

  public static void setDateFormatter(SimpleDateFormat df) {
    dateF=df;
  }

  public static void setTimeFormatter(SimpleDateFormat df) {
    timeF=df;
  }

  public String strDate() {
    return dateF.format(new Date(get()));
  }

  public String strTime() {
    return timeF.format(new Date(get()));
  }

  public String toString() {
    return datetimeF.format(new Date(get()));
  }

  public long getTimeOfDay() {
    cal.setTimeInMillis(get());
    cal.set(Calendar.MILLISECOND,0);
    
    long tt=cal.get(Calendar.HOUR_OF_DAY)*THR+
        cal.get(Calendar.MINUTE)*TMIN+
        cal.get(Calendar.SECOND)*TSEC;
    
    return tt;
  }
  
  public float fractionOfDay() {
    return papplet.map(getTimeOfDay(),0,end4HR,0,1);
  }

}
