// INDEX FILE UTILITIES

SimpleDateFormat dateFormat=new SimpleDateFormat("dd MMM yyyy - HH:mm", Locale.US);
String dataComment=
  "# Data: type,url,id,parentID,done (0==no, 1==yes),link cnt,timestamp,[link urls]";
String pinDataComment=
  "# board ID|url|description|pin stats";

public void getFileList() {
  lastID=-1;
  docs=new ArrayList<Doc>();
  if (failMap==null) failMap=new HashMap<String,Integer>();

  new File(sketchPath(FOLDER)).mkdirs();

  File index=new File(sketchPath(FOLDER+"index.csv"));
  nextDoc=null;

  try {
    if (index.exists()) {
      String dat[]=loadStrings(index);
  //    dataComment=dat[0];
      for (int i=1; i<dat.length; i++) {        
        Doc theDoc=new Doc();
        theDoc.parse(dat[i]);
        if (theDoc.SUCCESS) {
          docs.add(theDoc);
          lastID=max(lastID, theDoc.ID);
        }
      } 
  
      lastID++;
    }
  } catch(Exception e) {
    e.printStackTrace();
  }

  if (docs.size()<2) {
    new File(sketchPath(FOLDER+"indexPins.csv")).delete();
    Doc newDoc=new Doc(URLBASEUSER,-1,0);
    docs.add(newDoc);
    nextDoc=newDoc;
  }


  docCnt=docs.size();
  docDoneCnt=0;

  if (nextDoc==null) for (Doc d:docs) {
    println(d.toString());
    if(d.type==BOARD) d.getLinks();
    if (nextDoc==null && d.done==0) { // mark as next download
      nextDoc=d;
//      if (checkFail(nextDoc)>0) nextDoc=null;      
    }
    if (d.done>0) docDoneCnt++;
  }

  println("--------------\n");
  println("Loaded index: "+docCnt+" documents, "+
    docDoneCnt+" already done.");
  if (nextDoc!=null) { 
    println("Next doc to read: "+nextDoc.url);
  }
  else {
    println("All known documents downloaded. Exiting.");
    exit();
  }
}

public int checkFail(Doc doc) {
  int cnt=0;
  if (failMap.containsKey(doc.url)) {
    cnt=failMap.get(doc.url); 
    if (cnt>1) failMap.put(doc.url, cnt-1);
    else failMap.remove(doc.url);
  }

  return cnt;
}
public void addFail(Doc doc) {
  int cnt=0;
  if (failMap.containsKey(doc.url)) cnt=failMap.get(doc.url); 
  failMap.put(doc.url, cnt+(int)random(80,120));
}

public Doc getID(int ID) {
  for (Doc doc:docs) if (doc.ID==ID) return doc;

  return null;
}

public void saveFileList() {
  File index=new File(FOLDER+"index.csv");
  index.mkdirs();
  if (index.exists()) {
    // make a backup of index, just in case
    index.renameTo(new File(index.getAbsoluteFile()+".bak"));
  }
  
  String dat[]=new String[docs.size()+1];
  int cnt=0;
  
  // add header comment
  dat[cnt++]=dataComment;

  for (Doc doc:docs) {
    dat[cnt++]=doc.toString();
  }

  saveStrings(index, dat);
}

public void addDocToFileList(Doc newDoc) {
  addDocToFileList(newDoc, null);
}


public void addDocToFileList(Doc newDoc, Doc after) {
  // check for duplicates
  for (Doc cmp:docs) {
    if (cmp.url.compareTo(newDoc.url)==0) return;
  }

  newDoc.ID=(lastID++);    
  Doc p=getID(newDoc.parentID);
  if (p!=null) {
    p.links.add(newDoc.url);
    p.linkID.add(newDoc.ID);
  }

  if (after!=null) {
    docs.add(docs.indexOf(after)+1, newDoc);
  }
  else docs.add(newDoc);

  println(docs.size()+": New doc="+newDoc.url+" "+newDoc.ID);
}

public void savePinInfo(String info[]) {
  try {
    File index=new File(FOLDER+"indexPins.csv");
    String dat[], datNew[];
    
    if (index.exists()) { // load existing
      dat=loadStrings(index);
    }
    else { // init with header comment
      dat=new String [] {pinDataComment};
    }

    // concatenate dat + info strings    
    datNew=new String[dat.length+info.length];
    System.arraycopy(dat, 0, datNew, 0, dat.length);
    System.arraycopy(info, 0, datNew, dat.length, info.length);

    saveStrings(index, datNew);
  } 
  catch (Exception e) {
    // TODO Auto-generated catch block
    e.printStackTrace();
  }
}



// get image via HTTP - will work for any URL
public boolean fetchImage(String url, String folder) {
  // Open a URL Stream
  try {
    new File(folder).mkdirs();

    String filename=url.substring(url.lastIndexOf('/')+1);
    Response resultImageResponse=
      Jsoup.connect(url).ignoreContentType(true).execute();
    File imgfile=new java.io.File(folder+filename);

    if (!imgfile.exists()) {
      // output here
      FileOutputStream out=new FileOutputStream(imgfile);
      out.write(resultImageResponse.bodyAsBytes()); // image data as bytes
      out.close();
      println("Downloaded: "+filename+" "+new File(filename).length());
    }

    return true;
  } 
  catch (Exception e) {
    e.printStackTrace();
  }

  return false;
}

