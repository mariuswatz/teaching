// map of artists - use findArtist() to get a specific artist
HashMap<String, Artist> artistMap;

// list of all songs from file
ArrayList<Song> song;


//////////// SONG DATA

Artist mostPlayedArtist=null;
String mostPlayedSong=null;
HashMap<String,Integer> songCount;

public class Song {
  //  ISO time,unix,track,artist,album
  //  2014-01-14T06:50:38,1389682238,Sunshine of Your Love,Cream,Disraeli Gears Deluxe Edition

  Artist artist;
  String name, nameShort;
  UTimestamp t;
  float dayPos;
  float x, y; // normalized to [0..1], x=day, y=time of day
  float screenX, screenY;

  public Song(TableRow r) {
    t=new UTimestamp(r.getString(0));

    artist=findArtist(r.getString(3));
    artist.add(this);
    
    name=r.getString(4).trim();
    int val=0;
    if(songCount.containsKey(name)) val=songCount.get(name);
    songCount.put(name,val+1);
    
    // create shortened version of long names
    nameShort=(name.length()<30 ? name : name.substring(0, 30)+".."); 

    // calculate time as fraction of day, range [0..1]
    // we reverse the fraction so that AM==1 (bottom), PM==0 (top)
    dayPos=1-t.fractionOfDay(); 
//    if (song.size()%10==0) println("dayPos "+(int)(dayPos*1000)+" "+t.strTime());

    calcX();
  }

  void calcX() {
     // x is fraction of timeline [start..end]
    x=t.timelinePos(start, end);

    // calculate y as a function of time of day
    // dayPos = [-1..1]
    y=dayPos;//(dayPos*0.5f+0.5f);

    screenX=(int)(x*(w-stepX));
    screenY=(int)(y*(h-1));
    
//    println(screenX+" "+screenY);
  }
  
  
  void draw() {
      rect(screenX, screenY, stepX, stepY);
  }
  
  int getColor() {
    if(colorByPlays) return artist.colByPlays;
    return artist.col;
  }


  void drawInfo() {
    pushMatrix();
    translate(screenX, screenY);

    int fgCol=color(255);
    int bgCol=getColor();
    
    
    if(colorByPlays) fgCol=color(255,150,0);
    
    String str=nameShort;
    String str2=artist.name;
    
    textFont(fnt, 10);
    float wx=textWidth(str)+textWidth(str2)+5+4;
    
    
    float leftX=10;

    fill(bgCol); // line at top
    rect(leftX, -13, wx, 2);
    
    fill(bgCol, 150); // background
    rect(leftX, -11, wx, 26);


    textAlign(LEFT);

    leftX=12;
    fill(fgCol);
    text(str, leftX, 0);
    
    leftX+=textWidth(str)+3;
    fill(brightness(fgCol), 150);
    text(str2, leftX, 0);
    leftX=12;
    text(t.strTime(), leftX, 12);

    popMatrix();
  }
}

//////////// ARTIST DATA

public Artist findArtist(String name) {
  if (artistMap.containsKey(name)) return artistMap.get(name);
  Artist a=new Artist(name);
  artistMap.put(a.name, a);
  return a;
}


public class Artist {
  String name;
  ArrayList<Song> songs;
  int col,colByPlays;

  public Artist(String name) {
    this.name=name;
    songs=new ArrayList<Song>();

    // generate a random color for each artist so they have unique colors
    float a=random(255);
    float b=random(200, 255);

    int choice=(int)random(3000)%6;
    if (choice==0) col=color(a, b, 0);
    if (choice==1) col=color(b, a, 0);
    if (choice==2) col=color(0, a, b);
    if (choice==3) col=color(0, b, a);
    if (choice==4) col=color(a, 0, b);
    if (choice==5) col=color(b, 0, a);
  }

  public void add(Song s) {
    songs.add(s);
  }
}

