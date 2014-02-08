float monthX[];
String monthName[];

PFont fnt;

void drawDayText() {
  if (start==null) return;

  if (monthX==null || !isASingleYear) calcLayoutData() ;
  float leftX=6;

  fill(10);//255,255,0);
  rect(0, -20, w, 20);
  fill(6);
  rect(0, 0, w, h*0.5);
  fill(0, 4, 8);
  rect(0, h*0.5, w, h*0.5);


  String str;

  if (parseStatus>0) {
    str="Parsed: "+parsedLines+"/"+linesTotal;
  }
  else {
    str=String.format("%s | %d unique artists | %d tracks played", 
    (isASingleYear ? ""+start.year() : start.year()+" - "+end.year()), 
    artistMap.size(), song.size());
  }

  textAlign(LEFT);
  textFont(fnt, 18);
  fill(255);
  text(str, leftX, -yOffs+20);

  if (mostPlayedSong!=null) {
    textAlign(RIGHT);
    textFont(fnt, 12);

    str=String.format("Most played track: %s [%d]", 
    mostPlayedSong, 
    songCount.get(mostPlayedSong));


    str=str+"  "+String.format("Artist: %s [%d]", 
    mostPlayedArtist.name, 
    mostPlayedArtist.songs.size());
    text(str, w-leftX, -yOffs+20);
  } 

  textAlign(LEFT);

  float fntH=48;
  textFont(fnt, (int)fntH);
  fill(255, 10);
  text("PM", max(leftX, fntH*0.25), fntH);
  text("AM", max(leftX, fntH*0.25), h-fntH*0.25);

  textAlign(LEFT);
  textFont(fnt, 10);

  int cnt=0;
  stroke(150);
  fill(150);

  for (float x:monthX) {
    line(x, -20, x, h);
    if (cnt<12) text(monthName[cnt++], x+leftX, -10);
  }
}

void calcLayoutData() {
  fnt=createFont("arial", 48);
  monthX=new float[13];

  UTimestamp t=start.copy();

  if (isASingleYear) {    
    monthName=new DateFormatSymbols(Locale.US).getMonths();
    for (int i=0; i<12; i++) monthX[i]=map(i, 0, 12, 0, w-1);
  }
  else {
    float tD=end.get()-start.get();
    monthName=new String[13];

    for (int i=0; i<13; i++) {
      monthX[i]=map(i, 0, 12, 0, 1);
      t.set(start.get()+(long)(tD*monthX[i]));
      monthX[i]*=w;
      monthName[i]=t.strDate();
    }
  }

  monthX[12]=w;
}

