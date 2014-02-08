class Doc {

  String url, urlShort, board, ext;
  Doc parent=null;
  int ID, parentID=-1, done=0, type;
  long timestamp;
  String linkString="";
  ArrayList<Integer>linkID;
  ArrayList<String>links;
  PImage img;

  boolean isImage, SUCCESS=false;
  String typeStr[]=new String[] {
    "Profile", "Board", "Pin"
  };
  Document page= null;
  String pinInfo;

  public Doc(String url, int parentID, int type) {
    this.type=type;
    setUrl(url);      
    this.parentID=parentID;
  }

  private void setUrl(String url) {
    linkID=new ArrayList<Integer>();
    links=new ArrayList<String>();
    this.url=url;
    if (!url.endsWith("/") && url.lastIndexOf('.')>url.length()-10) {
      ext=url.substring(url.lastIndexOf('.')+1).toLowerCase();

      isImage=(ext.compareTo("jpg")==0 || ext.compareTo("jpeg")==0 ||
        ext.compareTo("gif")==0 || ext.compareTo("png")==0 );
      //        println("ext: "+ext+" isImage: "+isImage);

      urlShort=url;
      if (urlShort.length()>40) urlShort=".."+urlShort.substring(urlShort.length()-38);
    }
    else {
      urlShort=url.substring(URLBASEUSER.length());
      int pos=urlShort.indexOf('/');
      if (pos!=-1) board=urlShort.substring(0, pos);
      println("short: "+urlShort+" | "+board);
    }
  }

  public Doc() {
  }

  void parse(String parseStr) {

    try {
      String tok[]=split(parseStr, ','); 
      int tokCnt=0;

      type=parseInt(tok[tokCnt++]);
      setUrl(tok[tokCnt++]);

      ID=parseInt(tok[tokCnt++]);
      lastID=max(ID, lastID);

      parentID=parseInt(tok[tokCnt++]);
      done=parseInt(tok[tokCnt++]);

      if (done>0) {
        parseInt(tok[tokCnt++]);
        timestamp=dateFormat.parse(tok[tokCnt++]).getTime();
        linkString=tok[tokCnt++];      

        String l[]=split(linkString, '|');
        for (String ll:l) {
          int id=parseInt(ll);
          linkID.add(id);
        }
      }
    } 
    catch (Exception e) {
      SUCCESS=false;
      e.printStackTrace();
    }

    SUCCESS=true;
  }

  public void getLinks() {
    for (int id:linkID) links.add(getID(id).url);
  }

  void download() {

    try {
      println("-----------------------\n"+
        "Downloading: "+ID+"(p="+parentID+") "+url);
      if (isImage) type=2;
      else page=Jsoup.connect(url).get();


      println("Type of page: "+type+"="+typeStr[type]+" "+ID);
      if (type==0) parseProfile(page.select("div.board a.link"));
      else if (type==1) parseBoards();
      else parseImage();

      if (done>0) {
        timestamp=System.currentTimeMillis();
        saveFileList();
      }
    } 
    catch (Exception e) {

      // TODO Auto-generated catch block
      e.printStackTrace();
    }
  }

  public void parseImage() {
    Doc p=getID(parentID);      
    println(p.url);

    if (fetchImage(url, FOLDER+"/images/"+p.board+"/")) done=1;      
    else addFail(this);
  }

  public void parseBoards() {      
    Elements img= null;
    Element meta = page.select("meta[property=pinterestapp:pins]").first();
    int pinCnt=parseInt(meta.attr("content"));

    try {        
      img=page.select("div.pin");

      if (pinCnt>50 && img.size()>49) {
        String newurl;
        int pg=1;

        int queryPos=url.indexOf('?'); // is this a paged request?
        
        if (queryPos!=-1) {
          pg=parseInt(url.substring(url.indexOf('=')+1));
          newurl=url.substring(0, queryPos)+"?page="+(pg+1);
        }
        else newurl=url+"?page="+(pg+1);

        int boardID=-1;
        for (int i=0; i<docs.size() && boardID<0; i++) {
          Doc d=docs.get(i);
          if (d.type==BOARD && d.urlShort.startsWith(board)) boardID=i;
        }
        addDocToFileList(new Doc(newurl, boardID, BOARD));
        saveFileList();
      }

      if (img!=null && img.size()>0) {          
        String pinDat[]=new String[img.size()];

        for (int i=0; i<img.size(); i++) {
          Element el=img.get(i);
          String theUrl=el.attr(DATACLOSEUPURL);            
          Doc newDoc=new Doc(theUrl, this.ID, IMAGE);
          addDocToFileList(newDoc);            

          pinDat[i]=this.ID+"|"+ board;
          pinDat[i]+="|"+theUrl+"|"+el.select("a.pinImage").first().attr(ABSHREF);
          pinDat[i]+="|"+el.select("p.description").first().text();                
          pinDat[i]+="|"+el.select("p.stats").first().text();
        }        

        savePinInfo(pinDat);
      }

      //        checkInfiniteScroll(img);        

      done=1;
    } 
    catch (Exception e) {
      // TODO Auto-generated catch block
      println("parseBoards('"+url+") failed." +
        (img==null? "img==null" : "img=="+img.size()) );
      e.printStackTrace();
      exit();
    }
  }

  public void parseProfile(Elements boards) {      
    try {
      if (boards!=null && boards.size()>0) {
        for (int i=0; i<boards.size(); i++) {
          String theUrl=boards.get(i).attr(ABSHREF);

          if (i==0) linkString=theUrl;
          else linkString+="|"+theUrl;

          Doc newDoc=new Doc(theUrl, this.ID, BOARD);
          addDocToFileList(newDoc);
        }
      }

      done=1;
    } 
    catch (Exception e) {
      // TODO Auto-generated catch block
      println("parseProfile('"+url+") failed." +
        (boards==null? "boards==null" : "boards=="+boards.size()) );
      e.printStackTrace();
      exit();
    }
  }

  public String toString() {
    // url,id,parentID,done (0==no, 1==yes),date download,array of link urls

    String ids="";
    for (int id:linkID) {
      ids+=(id==0 ? "" : "|")+id;
    }
    String s=String.format("%d,%s,%d,%d,%d,%d,%s,%s", 
        type, 
        url, ID, parentID, done, 
        (links!=null) ? links.size() : -1, 
        timestamp>0 ? dateFormat.format(timestamp) : "null", 
        ids
      );

    return s;
  }
}

