//////////// PARSE

int parseSpeed=20; // Lines to parse per frame

int parseStatus=-1, rejected=0;
int parsedLines=0, linesTotal=0;
Table lastfmTable;

SimpleDateFormat simpleDate, simpleTime;

// intended to be threaded with thread()
void initParse() {
  try {    

    parseStatus=2;
    lastfmTable=loadTable(filename, "header");

    artistMap=new HashMap<String, Artist>();
    song=new ArrayList<Song>();  
    songCount=new HashMap<String, Integer>();

    parsedLines=0;
    linesTotal=lastfmTable.getRowCount();
    parseStatus--;

    // do calculations related to start/end timestamp
    // so we can calculate the x/y mapping parameters.

    // get timestamps for first and last entries
    String startStr=lastfmTable.getString(0, 0);
    String endStr=lastfmTable.getString(lastfmTable.getRowCount()-1, 0);

    // SINGLE YEAR OR DYNAMIC RANGE?
    if (isASingleYear) {
      if (!(startStr.startsWith(""+YEAR) && endStr.startsWith(""+YEAR))) {  
        println("WARNING: Input contains data not limited to the specified year");
        println("Data points not from "+YEAR+" will be ignored.");
      }

      start=new UTimestamp(YEAR+"-01-22 00:00:00");
      end=new UTimestamp(YEAR+"-12-31 00:00:00");
      println(start.toString()+" "+end.toString());

      Calendar cal=start.getCalendar();
      cal.set(
      Calendar.DAY_OF_YEAR, 
      cal.getActualMinimum(Calendar.DAY_OF_YEAR));
      start.set(cal.getTimeInMillis()).setStartOfDay();

      cal.set(
      Calendar.DAY_OF_YEAR, 
      cal.getActualMaximum(Calendar.DAY_OF_YEAR));
      end.set(cal.getTimeInMillis()).setEndOfDay();
    }
    else {

      start=new UTimestamp(startStr);
      end=new UTimestamp(endStr);
      if (end.isBefore(start)) {
        start=new UTimestamp(endStr);
        end=new UTimestamp(startStr);
      }
    }


    dayRange=start.distInDays(end)-1; // days in current time range 
    println("Days found: "+dayRange);

    stepX=max(2, (int)(w/(float)dayRange));
    if (stepX>1) stepX-=stepX%2;

    // use minutes in day to calculate y step
    stepY=max(1, (int)(h/(60*24f))); 

    println("---------- CSV loaded and ready for parsing. ms="+millis());
    println("Lines to parse: "+ linesTotal);
  } 
  catch(Exception e) {
    println("---------- initParse FAIL");

    e.printStackTrace();
    exit();
  }
}

public void parseLastFM() {
  if (parseStatus<0) {
    println("---------- Threaded parse started.");
    thread("initParse");
    return;
  }

  // can't proceed until the table has been loaded
  if (parseStatus<0 || parseStatus>1) return; 


  // parse "parseSpeed" rows per frame, until done.
  // if year filtering is on, parse up to 1000 lines 
  // until we've found "parseSpeed" valid entries.
  
  int speed=1000;
  int songCnt=song.size();  
  for (int i=0; i<speed && (song.size()-songCnt)<parseSpeed; i++) {
    // get rows last to first so the oldest draw first
    int thisRow=linesTotal-1-(parsedLines++);

    TableRow tmp=lastfmTable.getRow(thisRow);

    if (isASingleYear && !(tmp.getString(0).startsWith(YEARSTR))) {
      rejected++;
    }
    else {
      Song s=new Song(tmp);
      song.add(s);
    }

    if (parsedLines==linesTotal) {
      parseStatus--;
      break;
    }
  }

  if (song.size()>0) {
    if (mostPlayedArtist==null) mostPlayedArtist=song.get(0).artist;

    for (Artist a:artistMap.values()) {
      if (a.songs.size()>mostPlayedArtist.songs.size()) {
        mostPlayedArtist=a;
      }
    }

    // RECOLOR ARTIST ACCORDING TO NUMBER OF PLAYS
    float n=mostPlayedArtist.songs.size();
    for (Artist a:artistMap.values()) {
      a.colByPlays=lerpColor(
      color(150,150,100), 
      color(0, 180, 255), (float)a.songs.size()/n);
    }


    if (mostPlayedSong==null) mostPlayedSong=song.get(0).name;
    for (String s:songCount.keySet()) {
      if (songCount.get(mostPlayedSong) < songCount.get(s)) {
        mostPlayedSong=s;
      }
    }
  }

  if((parsedLines/parseSpeed)%50==0) {
    println("------- "+millis());
    println("Song data points: "+song.size()+" ("+rejected+" rejected)");
    println("Artists identified: "+artistMap.size());
    println("Time range: "+start.toString()+" > "+end.toString());
  }
}

