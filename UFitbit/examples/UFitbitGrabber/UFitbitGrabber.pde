/********************

unlekker.data.fitbit - Marius Watz, 2013
GitHub: https://github.com/mariuswatz/teaching

Demonstrates downloading intraday Fitbit data, which is currently 
not available to regular users through the public Fitbit API. (For 
my comment on this ridiculous business decision, see this blog post:
http://workshop.evolutionzone.com/2012/04/07/fitbit-shame-on-you/)

By using Clay Gregory's jFitbit library (https://github.com/claygregory/jfitbit)
we are still able to get the detailed intraday data, through a backdoor of sorts. 
It turns out that the XML feeds that power the Flash-based graphs on the web 
dashboard use the intraday data, which jFitbit scrapes to give us the data we want.

This code downloads data day by day and saves local copies in a format readable
with the UFitbitDay class. You must supply login / pw and the folder location 
where you want the data to be saved. 

http://workshop.evolutionzone.com

Shared under Creative Commons "share-alike non-commercial use only" 
license.

*/
import processing.core.*;
import processing.data.*;
import processing.event.*;
import unlekker.data.fitbit.UFitbit;
import unlekker.data.fitbit.UFitbitDay;
import unlekker.modelbuilder.*;
import unlekker.util.UUtil;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.io.*;

import com.claygregory.jfitbit.*;

UFitbit fitbit;

// IMPORTANT: You must fill in your login/pw and folder
// to save data to.

String FOLDER="C:/Users/Marius/Dropbox/03 Code/Workshops/save/Fitbit/";
String LOGIN="";
String PASSWORD="";

public void setup() {
  size(600, 600);
  smooth();

  // create fitbit API object
  fitbit=new UFitbit( LOGIN, PASSWORD );
  
  // test that output folder is valid
  File folderTest=new File(FOLDER+"");
  if(!folderTest.exists()) {
    println("Not found: "+FOLDER);
    println("Storing files in sketch folder instead.");
    FOLDER=sketchPath;
  }

  char lastChar=FOLDER.charAt(FOLDER.length()-1);
  if(lastChar!='\\' && lastChar!='/') FOLDER=FOLDER+'/'; 
  println("FOLDER = "+FOLDER);

  // max number of days to fetch in one session
  int cnt=14;
  
  // the earliest date that we will download data for
  Calendar cal=Calendar.getInstance();
  cal.add(Calendar.DAY_OF_MONTH,-14);
  long earliestTime=cal.getTimeInMillis();

  long timestamp=UUtil.timestamp();

  while (cnt>0 && timestamp>earliestTime) {
    timestamp=UUtil.timestampStartOfDay(timestamp);
    UUtil.logDivider(UFitbit.DATETIMEFORMAT.format(timestamp));

    String filename=getFilename(timestamp);
    File f=new File(filename);

    UUtil.log(f.getAbsolutePath()+" "+f.exists());
    if(!f.exists()) {
      fitbit.addDayQuery(timestamp);
      cnt--;
    }

    timestamp-=24*60*60*1000;
  }
}

public void draw() {
  background(255);

  String msg[]=fitbit.log.log;
  fill(0);

  text(fitbit.toString(), 10, 20);
  int n=(int)min(20, msg.length);
  for (int i=0; i<n; i++) 
    if (msg[i]!=null) text(msg[i], 10, 40+i*15);


  UFitbitDay day=null;
  if (fitbit.days.size()>0) synchronized(fitbit.days) {
    day=fitbit.days.remove(0);
  }
  if (day!=null) day.toData().save(getFilename(day.timestamp));


  if (fitbit.queriesExecuted==fitbit.queriesAdded) {
    fitbit.dispose();
    exit();
  }
}

private String getFilename(long t) {
  String dateString=UFitbit.FILEDATEFORMAT.format(t);
  return FOLDER+"Fitbit "+dateString+".txt";
}

