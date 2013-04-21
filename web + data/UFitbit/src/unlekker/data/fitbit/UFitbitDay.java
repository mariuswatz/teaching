package unlekker.data.fitbit;

import java.security.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import processing.core.PApplet;

import unlekker.util.UDataText;
import unlekker.util.UUtil;

import com.claygregory.common.data.Duration;
import com.claygregory.jfitbit.*;

public class UFitbitDay {
	private FitbitQuery fbQuery;
	private Fitbit api;
	
	public long timestamp=-1,timestampEnd=-1,start;
	public int year,day,month;
	public String dateString,fileDateString;
	public long stepTime[],sleepTime[];
	
	public int stepsTotal,steps[],sleep[];
	public int floorsTotal,floors[];

	public int activeScoreTotal,activeScore[];
	public int activityLevel[];
	public String activityLevelDesc[];
	public int caloriesTotal,calories[];
	public boolean FAIL;
	private UFitbit fitbit;
	
	public UFitbitDay(int year,int month,int dayOfMonth) {
		init(UUtil.timestamp(year, month, dayOfMonth));		
	}
	
	public UFitbitDay(long time) {
		init(time);
	}

	public UFitbitDay() {
    // TODO Auto-generated constructor stub
  }
	
	
	
	// -------------------------------- PARSE
	
  public static UFitbitDay parse(PApplet p,String filename) {
    UFitbitDay d=null;
	  
    p.println("----------------------- "+filename);
    
	  try {
      String dat[]=p.loadStrings(filename);
      String tmp2,tmp[];
      int id,n;
      
      d=new UFitbitDay();

    	String dateStr=dat[0].substring(17,43);
    	d.timestamp=UFitbit.DATETIMEFORMAT.parse(dateStr).getTime();
    	d.timestampEnd=UFitbit.DATETIMEFORMAT.parse(dat[0].substring(45)).getTime();
    	System.out.println(UFitbit.DATETIMEFORMAT.format(new Date(d.timestamp)));
    	System.out.println(UFitbit.DATETIMEFORMAT.format(new Date(d.timestampEnd)));
      
      tmp=dat[2].split("\t");
      d.stepsTotal=p.parseInt(tmp[0]);
      d.activeScoreTotal=p.parseInt(tmp[1]);
      d.floorsTotal=p.parseInt(tmp[2]);
      d.caloriesTotal=p.parseInt(tmp[3]);
      
      id=parseSkipTo(dat, "ACTIVITY");
      d.activityLevel=new int[] {
          p.parseInt(p.split(dat[id++],"\t")[1]),
          p.parseInt(p.split(dat[id++],"\t")[1]),
          p.parseInt(p.split(dat[id++],"\t")[1])
      };
      
      id=parseSkipTo(dat, "STEPS")+1;
      n=parseSkipTo(dat, "SLEEP")-id-1;

      d.stepTime=new long[n];
      d.steps=new int[n];
      d.activeScore=new int[n];
      d.floors=new int[n];

      for(int i=0; i<n; i++) {
        tmp=p.split(dat[i+id],"\t");
        long t=UFitbit.TIMEFORMAT.parse(tmp[0]).getTime();
        
        d.stepTime[i]=t+d.timestamp;        
        d.steps[i]=p.parseInt(tmp[1]);
        d.activeScore[i]=p.parseInt(tmp[2]);
        d.floors[i]=p.parseInt(tmp[3]);        
      }
      
      
      id=parseSkipTo(dat, "SLEEP");
      if(dat[id].contains("sleep=0")) n=0;
      else {
        id++;
        n=dat.length-id;
      }

      d.sleep=new int[n];
      d.sleepTime=new long[n];
      
      if(n==0) p.println("No sleep: "+dat[id]);
      else {
//        p.println(n+" "+dat[id]);
//        p.println(dat[id+n-1]);
        for(int i=0; i<n; i++) {
          tmp=p.split(dat[i+id],"\t");
          d.sleepTime[i]=UFitbit.TIMEFORMAT.parse(tmp[0]).getTime();
          d.sleep[i]=p.parseInt(tmp[1]);
          
        }      
        
//        p.println(d.sleep);
//        p.println(UFitbit.TIMEFORMAT.format(d.sleepTime[n-1]));      
      }
    } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
	  
	  return d;
	}
	
    private static int parseSkipTo(String dat[],String section) {
      for(int i=0; i<dat.length; i++) 
        if(dat[i]!=null && dat[i].contains(section)) return i+1; 
      
      
      PApplet.println("parseSkipTo() failed: "+section);
      return -1;
    }
  
	private void init(long time) {
		timestamp=UUtil.timestampStartOfDay(time);
		timestampEnd=UUtil.timestampEndOfDay(timestamp);
		
		Calendar cal=Calendar.getInstance();
		year=cal.get(Calendar.YEAR);
		month=cal.get(Calendar.MONTH);
		day=cal.get(Calendar.DAY_OF_MONTH);
		 
		dateString=UFitbit.DATEFORMAT.format(timestamp);
		fileDateString=UFitbit.FILEDATEFORMAT.format(timestamp);
	}

	
	// steps, activity score = intraday
	public boolean queryData(UFitbit fitbit) {
		this.fitbit=fitbit;
		api=fitbit.fitbitAPI;
		start=System.currentTimeMillis();
		
		try {
			getDayTotals();
			getIntraday();
		} catch (Exception e) {
			FAIL=true;
			fitbit.log.log("FAIL: "+dateString);
			e.printStackTrace();
		}
		
		return false;
	}

	private void getDayTotals() {
		caloriesTotal=-1;
		activeScoreTotal=-1;
		stepsTotal=-1;
		floorsTotal=-1;
		activityLevel=new int[] {-1,-1,-1};
		
		fbQuery = FitbitQuery.create( )
			  .minimumTimestamp(timestamp-24*60*60*1000)
			  .maximumTimestamp(timestamp)
			  .resolution( FitbitResolution.DAILY);

		fitbit.log.log(queryToString(fbQuery));
	
		try {
			List<CalorieCount> calRes=api.calorieCount(fbQuery);
			if(calRes.size()>0) caloriesTotal=calRes.get(0).getCalories();			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
							
		try {
			List<ActivityLevel> activeLevelRes=api.activityLevel(fbQuery);
			if(activeLevelRes.size()>0) {
				ActivityLevel lev=activeLevelRes.get(0);
				activityLevel[UFitbit.LIGHTLYACTIVE]=(int)lev.getLightlyActive().asSeconds();
				activityLevel[UFitbit.FAIRLYACTIVE]=(int)lev.getFairlyActive().asSeconds();
				activityLevel[UFitbit.VERYACTIVE]=(int)lev.getVeryActive().asSeconds();
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		try {
			List<ActivityScore> activityRes=api.activityScore(fbQuery);
			if(activityRes.size()>0) 
				activeScoreTotal=activityRes.get(0).getScore();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		try {
			List<FloorCount> floorRes=api.floorCount(fbQuery);
			if(floorRes.size()>0) floorsTotal=floorRes.get(0).getFloors();
		} catch (Exception e) {
			floorsTotal=-1;
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			List<StepCount> stepRes=api.stepCount( fbQuery );
			if(stepRes.size()>0) stepsTotal=stepRes.get(0).getSteps();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		fitbit.log.log(elapsed()+" | Daily totals: "+
				stepsTotal+"|"+activeScoreTotal+"|"+floorsTotal+
				"|"+caloriesTotal+"|"+UUtil.toString(activityLevel));
	}

	private void getIntraday() {
		fbQuery = FitbitQuery.create( )
			  .maximumTimestamp( timestampEnd)
			  .minimumTimestamp( timestamp)
			  .resolution( FitbitResolution.INTRADAY);
		fitbit.log.log(queryToString(fbQuery));
		
		List<StepCount> stepRes=api.stepCount( fbQuery );
		fitbit.log.logDivider(elapsed()+" | steps = "+stepRes.size());
		
		List<ActivityScore> activityRes=api.activityScore(fbQuery);
		fitbit.log.logDivider(elapsed()+" | activity "+activityRes.size());

		List<FloorCount> floorRes=api.floorCount(fbQuery);
		fitbit.log.logDivider(elapsed()+" "+" | floor "+floorRes.size());

		List<SleepLevel> sleepRes=api.sleepLevel(fbQuery);
		fitbit.log.logDivider(elapsed()+" "+" | sleep "+sleepRes.size());

		activeScore=new int[activityRes.size()];
		for(int i=0; i<activeScore.length; i++) {
			activeScore[i]=activityRes.get(i).getScore();
		}
					
		floors=new int[floorRes.size()];
		for(int i=0; i<floors.length; i++) floors[i]=floorRes.get(i).getFloors();

		
		steps=new int[stepRes.size()];
		stepTime=new long[steps.length];
		for(int i=0; i<steps.length; i++) {
			StepCount res=stepRes.get(i);
			steps[i]=res.getSteps();
			stepTime[i]=res.getTimestamp();
		}


		
		sleep=new int[sleepRes.size()];
		sleepTime=new long[sleep.length];
		for(int i=0; i<sleep.length; i++) {
			SleepLevel res=sleepRes.get(i);
			sleep[i]=res.getLevel();
			sleepTime[i]=res.getTimestamp();
		}
	}

	private String queryToString(FitbitQuery fbQuery) {
		String s=fbQuery.getResolution()+" ["+
				UFitbit.DATETIMEFORMAT.format(fbQuery.getMinimumTimestamp())+" ->"+
				UFitbit.DATETIMEFORMAT.format(fbQuery.getMaximumTimestamp())+"]";
		return s;
	}

	private long elapsed() {		
		return System.currentTimeMillis()-start;
	}

	public UDataText toData() {
		UDataText txt=new UDataText();
		
		txt.add("UFitBit output: ").
			add(UFitbit.DATETIMEFORMAT.format(timestamp)+" "+
					UFitbit.DATETIMEFORMAT.format(timestampEnd)).endLn();
		txt.add("Timestamp:").add(timestamp).add(timestampEnd);
		
		txt.add("Steps").add("activescore").add("floors").
			add("calories").endLn();
		
		txt.add(stepsTotal).add(activeScoreTotal).add(floorsTotal).
			add(caloriesTotal).endLn();

		txt.addDivider("ACTIVITY");
		for(int j=0; j<3; j++)
			txt.add(UFitbit.ACTIVITYDESC[j]).
				add((activityLevel[j])).
				add(new Duration(activityLevel[j]).toString()).
				endLn();
		
		txt.addDivider("STEPS");
		txt.addLn("time\tsteps\tactivity, floors");
		
		for(int i=0; i<steps.length; i++) {
      txt.add(UFitbit.TIMEFORMAT.format(stepTime[i])).
				add(steps[i]).
				add(activeScore[i]).
				add(floors[i]).endLn();
		}

		txt.addDivider("SLEEP");
			if(sleep.length==0) txt.addLn("sleep="+sleep.length);		
			else {
				txt.addLn("time\tsleep level");		
				for(int i=0; i<sleep.length; i++) {
					txt.add(UFitbit.TIMEFORMAT.format(sleepTime[i])).
						add(sleep[i]).endLn();
			}
		}

		return txt;
	}

	private void initIntraDayTime(List<StepCount> stepRes) {
		stepTime=new long[stepRes.size()];
		for(int i=0; i<stepTime.length; i++) 
			stepTime[i]=stepRes.get(i).getTimestamp();
		
		// TODO Auto-generated method stub
		
	}
}
