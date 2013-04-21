package unlekker.data.fitbit;

import java.sql.Array;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

import unlekker.util.*;

import com.claygregory.jfitbit.Fitbit;
import com.claygregory.jfitbit.FitbitAuthenticationException;

public class UFitbit implements Runnable {
	public static final int LIGHTLYACTIVE=0,FAIRLYACTIVE=1,VERYACTIVE=2;
	public static final String[] ACTIVITYDESC = new String[]{
		"Lightly active",
		"Fairly active",
		"Very active",
	};
	
	public static DateFormat TIMEFORMAT= new SimpleDateFormat( "HH:mm:ss" ,Locale.US);	
	public static DateFormat DATEFORMAT = new SimpleDateFormat( "EEE, MMM dd" ,Locale.US);
	public static DateFormat DATETIMEFORMAT = new SimpleDateFormat( "EEE, MMM dd yyyy - HH:mm:ss" ,Locale.US);
	public static DateFormat FILEDATEFORMAT = new SimpleDateFormat( "yyyyMMdd" ,Locale.US);

	public Fitbit fitbitAPI;
	
	public ArrayList<Long> dayQueryQueue;	
	public ArrayList<UFitbitDay> days;
	public ArrayList<String> statusMsg;	
	public Thread thread;
	
	public int queriesExecuted,queriesAdded;
	public long startTime,elapsedTime;
	public ULogUtil log;
	
	private boolean doExit;
	private String login,pw;
	
	public UFitbit(String login,String pw) {
		this.login=login;
		this.pw=pw;
		
		days=new ArrayList<UFitbitDay>();
		dayQueryQueue=new ArrayList<Long>();
		
		log=new ULogUtil();
		log.startLog(true);
		log.logStyle=UUtil.LOGSINCESTART;
		
		thread=new Thread(this);
		thread.start();
		
	}
	
	public void run() {
		startTime=System.currentTimeMillis();
		log.logDivider("UFitbit thread started.");

		try {
			log.log("Logging into Fitbit API.");
			fitbitAPI=new Fitbit( login,pw );
			
		} catch (FitbitAuthenticationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			dispose();
		}

		while(!doExit) {
			if(dayQueryQueue.size()>0) {
				long date=0;
				
				synchronized (dayQueryQueue) {
					date=dayQueryQueue.remove(0);					
				}
				
				UFitbitDay day=getDayStats(date);
				queriesExecuted++;
				if(!day.FAIL) synchronized (days) {
					log.log("Added day: "+day.dateString);
					days.add(day);
				}
			}
			
			try {
				thread.sleep(200);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		log.logDivider("UFitbit thread ended.");
		
		thread=null;
	}

	public void addDayQuery(long timestamp) {
		
		synchronized (dayQueryQueue) {
			log.log("addDayQuery: "+DATEFORMAT.format(timestamp)+
					" "+TIMEFORMAT.format(timestamp));
			dayQueryQueue.add(timestamp);
			queriesAdded++;
		}
	}

	public void addDayQuery(int year,int month,int dayOfMonth) {
		addDayQuery(UUtil.timestamp(year,month,dayOfMonth));
	}

	
	public UFitbitDay getDayStats(long date) {
		long start=System.currentTimeMillis();
		UFitbitDay day=null;
		
		day=new UFitbitDay(date);
		log.logDivider("getDayStats "+day.dateString);
		
		day.queryData(this);
		if(day.FAIL) {
			log.log("getDayStats failed ("+
					(System.currentTimeMillis()-start)+" msec)");
			day=null;
		}
		else log.log("getDayStats success ("+
				(System.currentTimeMillis()-start)+" msec)");
		
		
		
		return day;
	}

	public UFitbitDay getDayStats(int year,int month,int dayOfMonth) {
		
		return getDayStats(
				UUtil.timestamp(year, month, dayOfMonth));
	}
	
	public String toString() {
		elapsedTime=System.currentTimeMillis()-startTime;
		
		return "UFitbit | Queue: "+dayQueryQueue.size()+
				" | Executed: "+queriesExecuted+"/"+queriesAdded+
				" | Day data: "+days.size()+" days";
	}
	
	public void dispose() {
		log.log("dispose");
		doExit=true;
	}

}
