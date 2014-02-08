public void keyPressed( ) {
  if (key=='s') {
    String s=this.getClass().getSimpleName();
    int cnt=0;

    String filename;
    do {
      filename=s+" "+nf(cnt++, 3)+".png";
    } 
    while (new File (sketchPath (filename)).exists());

    saveFrame(filename);
    println("Saved "+filename);
  } 

  else colorByPlays=!colorByPlays;
}

int songClosestToMouse;
float songDistToMouse;
PVector mousePos=new PVector();
boolean mouseIsOver=false;

void drawMouseOver() {
  if (songClosestToMouse>-1) {
    Song theSong=song.get(songClosestToMouse);

    // LEFT CLICK to show lines to all other tracks by same artist
    // RIGHT CLICK to show track info for all other tracks by same artist
    if (mousePressed) {
      Artist a=theSong.artist;

      for (Song s:song) if (s.artist==a) {

        stroke(theSong.getColor(), 20);
        line(
        theSong.screenX, theSong.screenY, 
        s.screenX, s.screenY);

        noStroke();
        fill(theSong.getColor());
        rect(s.screenX-5, s.screenY, stepX+10, 1);


        if (mouseButton==RIGHT) s.drawInfo();
      }
    } 
    // show single track info
    theSong.drawInfo();
  }
}

void checkSongMouseOver(int id, Song song) {
  // calculate simplistic distance as (xD+yD), no need for sqrt 
  float simpleDist=
    abs(mousePos.x-(song.screenX))+
    abs(mousePos.y-song.screenY);

  if (simpleDist<5 && simpleDist<songDistToMouse) {
    songClosestToMouse=id;
    songDistToMouse=simpleDist;
  }
}

void resetSongMouseOver() {
  songClosestToMouse=-1;
  songDistToMouse=width;

  mousePos.set(mouseX, mouseY);

  mouseIsOver=(
  mousePos.x>=xOffs && mousePos.x<=(width-xOffs) &&
    mousePos.y>=yOffs && mousePos.y<=(yOffs+h));
  if (mouseIsOver) mousePos.sub(xOffs, yOffs, 0);
}



