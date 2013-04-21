UGeometry obj;

void build(UFitbitDay day) {
  obj=new UGeometry();
  for(int i=0; i<day.steps.length; i++) {
    float h=day.steps[i]+1;
    
    UGeometry box=UPrimitive.box(4.5,h,50);
    box.toOrigin().translate(10*i,0,0);
    obj.add(box);    
  }
  
  obj.center().toOrigin();
}

