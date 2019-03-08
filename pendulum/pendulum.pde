import lord_of_galaxy.timing_utils.*;

import grafica.*;
import javax.swing.*;

class Pendulum {

  PVector position;    // position of pendulum ball
  PVector origin;      // position of arm origin
  PVector start;
  float r;             // Length of arm
  float angle;         // Pendulum arm angle
  float aVelocity;     // Angle velocity
  float aAcceleration; // Angle acceleration
  

  float ballr;         // Ball radius
  float damping;       // Arbitary damping amount

  boolean dragging = false;

  // This constructor could be improved to allow a greater variety of pendulums
  Pendulum(PVector origin_, float r_) {
    // Fill all variables
    origin = origin_.get();
    position = new PVector();
    r = r_;
    angle = PI/4;

    aVelocity = 0.0;
    aAcceleration = 0.0;
    damping = 0.995;   // Arbitrary damping
    ballr = 48.0;      // Arbitrary ball radius
  }

  void go() {
    update();
    drag();    //for user interaction
    //display();
  }

  // Function to update position
  void update() {
    // As long as we aren't dragging the pendulum, let it swing!
    if (!dragging) {
      float gravity = 0.4;                              // Arbitrary constant
      aAcceleration = (-1 * gravity / r) * sin(angle);  // Calculate acceleration (see: http://www.myphysicslab.com/pendulum1.html)
      aVelocity += aAcceleration;                 // Increment velocity
      aVelocity *= damping;                       // Arbitrary damping
      angle += aVelocity;                         // Increment angle
    }
  }
  // The methods below are for mouse interaction

  // This checks to see if we clicked on the pendulum ball
  void clicked(int mx, int my) {
    float d = dist(mx, my, position.x, position.y);
    if (d < ballr) {
      dragging = true;
      aVelocity = 0;
    }
  }

  // This tells us we are not longer clicking on the ball
  void stopDragging() {
    if (dragging) {
      aVelocity = 0; // No velocity once you let go
      dragging = false;
    }
  }

  void drag() {
    // If we are draging the ball, we calculate the angle between the 
    // pendulum origin and mouse position
    // we assign that angle to the pendulum
    if (dragging) {
      PVector diff = PVector.sub(origin, new PVector(mouseX, mouseY));      // Difference between 2 points
      angle = atan2(-1*diff.y, diff.x) - radians(90);                      // Angle relative to vertical axis
    }
  }
}

class point{
  float xVal;
  float yVal;
  point(float xval, float yval){
    xVal = xval;
    yVal = yval;
  }
  
  void setx(float xValue){
    xVal = xValue;
  }
  
  void sety(float yValue){
    yVal = yValue;
  }
}

Pendulum p; 


public GPointsArray points = new GPointsArray();
public FloatList velocities = new FloatList();
public int reset;
public boolean hasMax = false;
public float period = 0; 
public Stopwatch time;
void setup() {
  size(1000,600);
  
  // Make a new Pendulum with an origin position and armlength
  p = new Pendulum(new PVector(320,0),175);
   time = new Stopwatch(this);
   
   time.start();
}

void draw() {
  int s = time.time();
  //println(time.time());
  background(232, 175, 78);
  p.go();
  p.position.set(p.r*sin(p.angle), p.r*cos(p.angle), 0);         // Polar to cartesian conversion
  p.position.add(p.origin);  // Make sure the position is relative to the pendulum's origin
    
   // println(angle);
   // println( position.x);
   // println("Y is: ", position.y);

    stroke(0);
    strokeWeight(2);
    // Draw the arm
    
    
    
    line(p.origin.x, p.origin.y, p.position.x, p.position.y);
    //line(position.x, position.y, 320, position.y);
    //line(origin.x, origin.y, 320, position.y);
    
    float secondRefLen = dist(p.origin.x, p.origin.y, 320, p.position.y);
    
    float armLen = dist(p.origin.x, p.origin.y, p.position.x, p.position.y);
    float refLen = dist(p.position.x, p.position.y, 320, p.position.y);
    float realAngle = atan(refLen/secondRefLen);
    
    ellipseMode(CENTER);
    fill(190);
    if (p.dragging) fill(0);
    ellipse(p.position.x, p.position.y, p.ballr, p.ballr);
    noFill();
    rect(120,p.origin.y,400,260);
 
    
 
  points.add(s, p.aVelocity);
  velocities.append(p.aVelocity);
  float max = velocities.max();
  float min = velocities.min();
  
  if(hasMax == false && p.aVelocity < 0 && s > 1500){
    float newPeriod = getPeriod(s);
    period = newPeriod;
    hasMax = true;
  }
  
  
  //println(period);
  
  float amplitude = (max - min)/2;
  int midLine = 0;
  if(velocities.get(0) < 0 && velocities.size() > 0){
    amplitude = amplitude * -1;
  }
  float b = (2 * PI) / period;
  
  String equation = "y = " + amplitude + "sin(" + b + "x) + " + midLine;
  
  println(equation);
  
  //println(numMax);
  
  // it is just 2000 milliseconds
  
  //println(period);
  
  
  //println(max);
  //println(velocities.min());


  // Create a new plot and set its position on the screen
  GPlot plot = new GPlot(this);
  plot.setPos(0, 300);
  plot.setDim(800,200);
  
  textSize(20);
  fill(0);
  text(equation, 200, 290);
  textSize(15);
  text("Velocity: " + p.aVelocity, 125, 240);
  text("Time(ms): " + s, 125, 255);
  text("Click and drag to change position", 125, 220);
  
  // or all in one go
  // GPlot plot = new GPlot(this, 25, 25);

  // Set the plot title and the axis labels
  plot.setTitleText("Velocity vs. Time");
  plot.getXAxis().setAxisLabelText("Time (Milliseconds)");
  plot.getYAxis().setAxisLabelText("Velocity(Pixels/S)");

  // Add the points
  
  if(velocities.size() <= 1000 && p.aVelocity != 0){
    plot.setPoints(points);
  }
  
  else if(velocities.size() > 1000){
    points = new GPointsArray();
    velocities = new FloatList();
  }
  
  if(p.aVelocity == 0 && p.dragging == true){
    points = new GPointsArray();
    velocities = new FloatList();
    hasMax = false;
    time.restart();
  }
  
  
  // Draw it!
  plot.defaultDraw();
  
}


float getPeriod(float time){
  float halfPeriod = time;
  float period = halfPeriod * 2.000;
  return period;
}


void mousePressed() {
  p.clicked(mouseX,mouseY);
}

void mouseReleased() {
  p.stopDragging();
}
