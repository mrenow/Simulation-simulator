//import System.Time;

//constants
final float BALLSIZE = 3;
float MOUSEPOWER = 100000;
float ATTRACT = 0.3;
float REPEL = 3;
final float MAX = 0.1;
final float AIR = 1;
final float ITERS = 20;

//control
int ADDING = 0, MASSADDING = 1, PUSHING = 2, ROTATING = 3;
boolean running = true, recording = false;
boolean leftPressed, rightPressed, upPressed, downPressed, plusPressed, minusPressed;
int state = 0;
float radius = 200;
float radians = 0.000001;
float speed = 1;
boolean draw = false;

ArrayList<Ball> balls;

//science
long timemillis = 0;
long calcTime = 0;
int time = 0;
double energyold;
double energychange;


//display variables
int WIDTH = 800, HEIGHT = 800;
int halfHeight;
float screenPosX, screenPosY;
float MOUSEX, MOUSEY;
float scale = 1;


//displays
PGraphics simulation;
PGraphics sidebar;

void setup() {
  size(1200, 800);
  screenPosX = -WIDTH/2;
  screenPosY = -HEIGHT/2;
  MOUSEPOWER/=ITERS;
  ATTRACT/=ITERS;
  REPEL/=ITERS;
  halfHeight = height/2;
  blank();
}

void blank() {
  simulation = createGraphics(height, height);
  sidebar = createGraphics(width-height, height);
  print("poop");
  fill(0, 0, 0, 10);
  sidebar.beginDraw();
  sidebar.textFont(createFont("Consolas", 20));
  sidebar.stroke(255);
  sidebar.endDraw();
  stroke(0);
  energyold = 0;
  energychange = 0;

  balls = new ArrayList<Ball>();
  /*for(int i = 0; i< 11; i++){
   for(int j = 0; j< 11; j++){
   balls.add(new Ball(i*20,j*20));
   }
   } */
}
void draw() {
  moveScreen();
  //text("hi guys", mouseX, MOUSEY);
  long t = millis();
  if (running) {
    for (int i = 0; i < ITERS*speed; i++) {
      update();  
      time++;
    }
  }
  calcTime = millis()-t;

  if (mousePressed && state== ROTATING) rotateArea();

  drawScreen();
  if (recording) {
    saveFrame("Screenshot" + System.currentTimeMillis());
  }

  MOUSEX = (mouseX-halfHeight)/scale - screenPosX;
  MOUSEY = (mouseY-halfHeight)/scale - screenPosY;
}

PVector reflectSurface(PVector incidence, float axis) {
  PVector reflection = incidence.copy();
  reflection.rotate(2*(axis- incidence.heading())+PI);
  return reflection;
}
float fmin(float a, float b) {
  if (a<b) {
    return a;
  }
  return b;
}
/*
void mousePressed(){
 balls.add(new Ball());
 fill(0);
 noStroke();
 
 
 }*/
void keyPressed() {
  switch(key) {
  case 'q':
    state ++;
    break;
  case 'e':
    state --;
    break;
  case 'r':
    blank();
    break;
  case 'p':
    running = !running;
    break;
  case '`':
    recording = !recording;
    break;
  case '.':
    draw = !draw;
    break;
  case '-':
    minusPressed = true;
    break;
  case '=':
    plusPressed = true;
    break;
  case 'a':
    leftPressed = true;
    break;
  case 'd':
    rightPressed = true;
    break;
  case 'w': 
    upPressed = true;
    break;
  case 's':
    downPressed = true;
    break;
  }
  switch(keyCode) {
  case LEFT:
    speed/=1.4;
    break;
  case RIGHT:

    speed*=1.4;
  }
  if (state > 3) state = 0;
  if (state < 0) state = 3 ;
  switch(state) {
  case 0:
    cursor(ARROW);
    break;
  case 1:
    cursor(CROSS);
    break;
  case 2:
    cursor(HAND);
    break;
  case 3:
    cursor(3);
  }
}
void keyReleased() {
  switch(key) {
  case 'a':
    leftPressed = false;
    break;
  case 'd':
    rightPressed = false;
    break;
  case 'w': 
    upPressed = false;
    break;
  case 's':
    downPressed = false;
    break;
  case '-':
    minusPressed = false;
    break;
  case '=':
    plusPressed = false;
    break;
  }
}
void moveScreen() {
  if (plusPressed) scale*=1.01;
  if (minusPressed) scale/=1.01;
  if (leftPressed) screenPosX +=5.0/scale;
  if (rightPressed) screenPosX -=5.0/scale;
  if (upPressed) screenPosY +=5.0/scale;
  if (downPressed) screenPosY -=5.0/scale;
}
void mouseMoved() {
  if (state == MASSADDING) {
    balls.add(new Ball());
  }
}
void mousePressed() {
  if (mouseButton == RIGHT) {
    for (Ball b : balls) {
      b.vel.set(0, 0);
    }
    energychange = 0;
    energyold = 0;
  } else if (state == ADDING) {
    balls.add(new Ball());
  }
}


void rotateArea() {
  Ball b;
  for (int i = 0; i<balls.size(); i++) {
    b = balls.get(i);
    PVector relpos = new PVector(b.pos.y-MOUSEY, -(b.pos.x-MOUSEX));
    float mag = relpos.mag();
    if (mag<radius) {
      b.vel.add( relpos.mult(mag*radians));
    }
  }
}
void update() {
  for (int i = 0; i<balls.size(); i++) {
    Ball b1 = balls.get(i);
    for (int j = i+1; j<balls.size(); j++) {
      Ball b2 = balls.get(j);
      float xdiff = b1.pos.x-b2.pos.x, ydiff = b1.pos.y-b2.pos.y;
      float dist = xdiff*xdiff + ydiff*ydiff;
      float mult = min((REPEL-ATTRACT*sqrt(dist))/(dist*dist), MAX);
      xdiff*=mult;
      ydiff*=mult;
      b1.vel.x+=xdiff;
      b1.vel.y+=ydiff;
      b2.vel.x-=xdiff;
      b2.vel.y-=ydiff;
    }
    if (state == PUSHING) {
      float xdiff = b1.pos.x-MOUSEX, ydiff = b1.pos.y-MOUSEY;
      float dist = xdiff*xdiff + ydiff*ydiff;
      float mult = MOUSEPOWER*REPEL/(dist*dist);
      b1.vel.x += mult*xdiff; 
      b1.vel.y += mult*ydiff;
    }
    b1.wallcheck();
    b1.pos.add(b1.vel);
  }
}
void drawScreen() {


  timemillis = millis();

  //PGraphics g = createGraphics(width,height);
  // g.beginDraw();

  double energy = 0;
  PVector momentum = new PVector(0, 0);
  if (draw) {
    simulation.beginDraw();
    simulation.noFill();
    simulation.translate(halfHeight, halfHeight);
    simulation.scale(scale);

    simulation.translate(screenPosX, screenPosY);

    simulation.background(0, 0, 0, 100);
    if (state == ROTATING) {
      simulation.strokeWeight(0);
      simulation.ellipse(MOUSEX, MOUSEY, 2*radius, 2*radius);
    }
    simulation.strokeWeight(1);
    simulation.stroke(255, 255, 255);
    for (Ball b : balls) {
      if (abs(b.pos.x+screenPosX)<=halfHeight/scale && abs(b.pos.y+screenPosY)<=halfHeight/scale) b.draw();
      energy += b.vel.magSq();
      momentum.add(b.vel);
    }
    simulation.line(0, HEIGHT, WIDTH, HEIGHT);
    simulation.line(WIDTH, HEIGHT, WIDTH, 0);
    simulation.line(WIDTH, 0, 0, 0);
    simulation.line(0, 0, 0, HEIGHT);
    simulation.endDraw();
    image(simulation, 0, 0);

    // g.endDraw();
    //image(g,0,0);
  } else {
    for (Ball b : balls) {
      energy += b.vel.magSq();
      momentum.add(b.vel);
    }
  }
  energychange = (energy-energyold)*0.01 + energychange*0.99;

  sidebar.beginDraw();
  sidebar.background(255, 150, 50);
  sidebar.fill(0, 0, 255);
  sidebar.text("Entities: "+balls.size(), 10, 40);
  sidebar.text("Time: "+time, 10, 80);
  sidebar.text(String.format("KE = %.2f KJ", energy*3.6), 10, 120);
  sidebar.text(String.format("ΔKE = %.2f KJ/s", energychange*216), 10, 160);
  sidebar.text(String.format("P = [%.2f,%.2f]", momentum.x*60, momentum.y*60), 10, 200);
  sidebar.text(String.format("Draw: %02dms | Calc: %02dms", millis()- timemillis, calcTime), 10, 240);

  sidebar.endDraw();
  image(sidebar, height, 0);
  energyold = energy;
}
int sign(float num) {
  if (num<0) {
    return -1;
  }
  return 1;
}
Ball b = new Ball(3, 2);
class Ball {
  PVector vel;
  PVector pos;

  Ball() {
    vel = new PVector(0, 0);
    pos = new PVector(MOUSEX, MOUSEY);
  }
  Ball(int x, int y) {
    vel = new PVector(0, 0);
    pos = new PVector(x, y);
  } 
  void draw() {
    //ellipse(pos.x,pos.y,BALLSIZE,BALLSIZE);
    simulation.line(pos.x, pos.y, pos.x-vel.x*ITERS, pos.y-vel.y*ITERS);
  }
  void wallcheck() {
    float offset;
    if ((offset = WIDTH-pos.x)<0||(offset = -pos.x)>0) {
      vel.x*=-1;
      pos.x+=2*offset;
    }
    if ((offset = HEIGHT-pos.y)<0||(offset = -pos.y)>0) {
      vel.y*=-1;
      pos.y+=2*offset;
    }    
    vel.mult(AIR);
  }
}