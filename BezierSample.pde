ArrayList points;
int N = 21;
int radius = 5;
boolean dragged;
int drag_id;
ImageButtons save_button;
PrintWriter output;
double sample_rate = 0.01;

void setup(){
  size(640, 480);
  points = new ArrayList();
  float radius = 100;
  for(int i=0; i<N; i++){
    float x = radius*cos(2*PI/(N)*(float)i)+width/2;
    float y = radius*sin(2*PI/(N)*(float)i)+height/2;
    points.add(new PVector(x, y));
  }
  
  dragged = false;
  drag_id = -1;  
  
  PImage b = loadImage("save.png");
  PImage r = loadImage("save.png");
  int x = 20;
  int y = 0;
  int w = b.width;
  int h = b.height;
  save_button = new ImageButtons(x, y, w, h, b, r);  
}

void draw(){
  background(255); 
 
  double step = N*sample_rate;
  for(double t=0.0; t<=(double)N; t+= step){
    drawSpline(t);
    //println(t);
  }  
  
  PVector p;
  float prev_x, prev_y;
  PVector prev_p;
  prev_p = (PVector)points.get(N-1);
  prev_x = prev_p.x;
  prev_y = prev_p.y;
  for (int i=0; i<points.size(); i++) {
    p = (PVector) points.get(i);
    strokeWeight(1);
    stroke(#808080);
    line(p.x, p.y, prev_x, prev_y);
    drawHandle(p.x, p.y);
    prev_x = p.x;
    prev_y = p.y;
  }
  if(mousePressed && !dragged){
    int id = pickupHandle(mouseX, mouseY);
    if(id >= 0){
       dragged = true;
       drag_id = id;
    }  
  }
  
  if(dragged){
    points.set(drag_id,  new PVector((float)mouseX, (float)mouseY));
  }
  
  if(!mousePressed){
     dragged = false;
     drag_id = -1;
  } 
  //int stepN = 100;
  
  
  save_button.update();
  save_button.display();
  if(save_button.pressed){
    println("save button");
    //canvas.savePolyLine();
    savePolyLine();
  }
}

void drawSpline(double t){
  int k=0;
  double x, y;
  double cn;
  PVector p;
  x=0.0;
  y=0.0;
  for(int i=-2; i<=N+2; i++){
    k=i;
    if(i<0){
      k=N+i;
    }
    if(i>N-1){
      k=i-(N);
    }
    //println(k);
    cn = coefficient(t-(double)i);

    //println(cn);
    p = (PVector)points.get(k);
    x += (p.x*cn); 
    y += (p.y*cn);
  }  
  strokeWeight(2);
  stroke(#111111);
  fill(#111111);
  ellipse((float)x, (float)y, 1, 1);
  
  //println(x+" "+y);
}

PVector getSpline(double t){
  int k=0;
  double x, y;
  double cn;
  PVector p;
  x=0.0;
  y=0.0;
  for(int i=-2; i<=N+2; i++){
    k=i;
    if(i<0){
      k=N+i;
    }
    if(i>N-1){
      k=i-(N);
    }
    //println(k);
    cn = coefficient(t-(double)i);

    //println(cn);
    p = (PVector)points.get(k);
    x += (p.x*cn); 
    y += (p.y*cn);
  }  

  return (new PVector((float)x, (float)y));
}

double coefficient(double t){
  double r, d;
  if(t < 0.0) {
    t = -t;
  }
  
  if(t < 1.0){
    r = (3.0 * t * t * t -6.0 * t * t + 4.0) / 6.0;
  }
  else if(t < 2.0) {
    d = t - 2.0;
    r = -d * d * d / 6.0;
  }
  else {
    r = 0.0;
  }

  return r;    
    
}

void drawHandle(float x, float y){
  strokeWeight(4);
  stroke(#111111);
  fill(#dd9977);
  ellipseMode( CENTER );
  ellipse(x, y, 10, 10);
}

int pickupHandle(int x, int y){
  PVector p;
  PVector mouseP = new PVector(x, y);
  for(int i=0; i<points.size(); i++){
    p = (PVector) points.get(i);
    if(mouseP.dist(p) < radius){
      return i;
    }
  }
  return -1;  
}

void savePolyLine(){
  double step = N*sample_rate;
    //int pointN = (int)((double)(N-1)/step)+1;
  int pointN = 0;
  for(double t=0.0; t<=(double)N-1; t+= step){
    pointN++;
  } 
    output = createWriter("polyline.ply");
    output.println("ply");
    output.println("format ascii 1.0");   
    output.println("element vertex "+pointN);
    output.println("property float x");
    output.println("property float y");
    output.println("property float z");
    output.println("element edge "+pointN);
    output.println("property int vertex1");
    output.println("property int vertex2");
    output.println("end_header");
    
   for(double t=0.0; t<=(double)N-1; t+= step){
     PVector p =getSpline(t);
     output.println(p.x + " " + (height-p.y) + " " + 0);
   }     

   for(int i=0; i<pointN; i++){
     int current = i;
     int next = i+1;
     if(next == pointN){
       next = 0; 
     }
     output.println(current + " " + next);
   }
   
   output.flush();
   output.close();  
}

class Button
{
  int x, y;
  int w, h;
  color basecolor, highlightcolor;
  color currentcolor;
  boolean over = false;
  boolean pressed = false;
  boolean prev_pressed = false;  
  
  void pressed() {
    prev_pressed = pressed;
    if(over && mousePressed) {
      pressed = true;
    } 
    else if(over && prev_pressed && !mousePressed){
        pressed = false;
    }
    else {
      pressed = false;
    }    
  }
  
  boolean overRect(int x, int y, int width, int height) {
    if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
     return true;
    } else {
      return false;
    }
  }
}

class ImageButtons extends Button {
 
  PImage base;
  PImage roll;
  PImage currentImage;
  
  ImageButtons(int _x, int _y, int _w, int _h, PImage _base, PImage _roll){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    base = _base;
    roll = _roll;
    currentImage = base;
  }
  
  void update(){
     over();
     pressed(); 
     if(over){
       currentImage = roll;
     }
     else{
       currentImage = base;
     }
  }
  
  void over(){
    if(overRect(x, y, w, h)){
     over = true;
    } 
    else{
     over = false; 
    }
  }
  
  void display(){
   image(currentImage, x, y); 
  }
  
}

