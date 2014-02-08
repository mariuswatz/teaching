ArrayList<UGeometry> days;

void loadData() {
  File f=new File(sketchPath+"/data");
  String filename[]=f.list();
  days=new ArrayList<UGeometry>();
  
  int cnt=0;
  for(int i=0; i<filename.length; i++) {
    if(filename[i].indexOf("Fitbit")>-1) {
      println(filename[i]);
      fb=UFitbitDay.parse(this, sketchPath+"/data/"+filename[i]);
//      println(fb.steps);
      build(fb);
      obj.writeSTL(this,filename[i]+".stl");
      obj.translate(0,0,(cnt++)*100+50);
      days.add(obj);
    }
  }
}

