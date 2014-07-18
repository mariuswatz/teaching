String path="C:/Users/marius/Dropbox/03 Code/StevenApp/data/Emoji/";
String files[];
ArrayList<EmojiImg> images;

// Loads all files from a given path and parses them into EmojiImg data
public void load() {
  path=sketchPath+"/Emoji/";
  files=new File(path).list();

  int cnt=0;
  
  images=new ArrayList<EmojiImg>();
  for(String f : files) {
    images.add(new EmojiImg(f));
    if(cnt%50==0) println(cnt+"/"+files.length+" loaded.");
    cnt++;
  }
    
}

// Exports data from the ArrayList<EmojiImg> to a CSV tabular data format.
// numColors are saved as 6-digit hex strings, prefixed with "#" to avoid them  
// being parsed as numbers in Excel or similar.

public void export(String csvFilename) {
  Table tab=new Table();
  
  tab.addColumn("emojicode", Table.STRING);
  
  for(int i=0; i<numColors; i++) {
    tab.addColumn("col"+i, Table.STRING);
  }
  
  for(EmojiImg tmp : images) {
    TableRow row=tab.addRow();
    row.setString(0,tmp.code);
    
    for(int i=0; i<numColors; i++) {
      int c=0xFFFFFFFF; // white will be used if not enough numColors
      
      if(i<tmp.col.size()) c=tmp.col.get(i);
      row.setString(i+1, "#"+toHex(c));
    }
  }
  
  println("Saved '"+csvFilename+"' - "+images.size()+" entries.");
  saveTable(tab, csvFilename);
}


String toHex(int col) {
  String s="", tmp;

  int a=(col >> 24) & 0xff;
  //    if(a<255) s+=strPad(Integer.toHexString(a),2,'0');

  s+=strPad(Integer.toHexString((col>>16)&0xff), 2, '0');
  s+=strPad(Integer.toHexString((col>>8)&0xff), 2, '0');
  s+=strPad(Integer.toHexString((col)&0xff), 2, '0');

  s=s.toUpperCase();
  return s;
}

public String strPad(String s, int len, char c) {
  len-=s.length();
  while (len-->0) s+=c;

  return s;
}

