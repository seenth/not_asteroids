Player player;
Attractor planet;
Attractor planet2;
Attractor planet3;
Particle[] stone = new Particle[7];
int score = 0;
int stage;

void setup() {
  fullScreen();
  noCursor();
  stage = 1;
  reset();
  
}

void draw() {
  background(0);
  score();    
    
    if (stage == 1) {
      clickStart();    
    }
    if (stage == -1) {
      gameStart();        
    }  
}

/* game setup */
void clickStart(){
  fill(255);
  pushMatrix();
    textAlign(CENTER);
    textSize(12);
    String gameinfo = "";
    gameinfo += "\nclick to start/reset";
    gameinfo += "\n<, ^, > arrows to move";
    translate( width/2, height/2);
    textLeading(30);
    text(gameinfo,0,-25);
  popMatrix();
}

void gameStart() {
    planet.display();
    planet2.display();
    planet3.display();
    planet.move();
    planet3.move();
    planet.collision();
    planet3.collision();
    PVector f = planet2.attract(player);
    planet2.attract(player);
          
    player.applyForce(f);
    player.move();
    player.render();
    player.collision();
    
    //controls
        if (keyPressed) {
          if (key == CODED && keyCode == LEFT) {
            player.turn(-0.03);
          } else if (key == CODED && keyCode == RIGHT) {
            player.turn(0.03);
          } else if (key == CODED && keyCode == UP) {
            player.thrust(); 
          }
        }
        
    //object collision    
    if (planet.isTouching(player)) {
          player.velocity.x *= -1;
          player.velocity.y *= -1;
          reset();
    }
    if (planet2.isTouching(player)) {
          player.velocity.x *= -1;
          player.velocity.y *= -1;
          reset();
    }
    if (planet3.isTouching(player)) {
          player.velocity.x *= -1;
          player.velocity.y *= -1;
          reset();
    }
    for (int i = 0; i < stone.length; i++){
        stone[i].run();        
        if (stone[i].isTouching(planet)){
          stone[i].velocity.x *=-1;
          stone[i].velocity.y *=-1;
        } 
        if (stone[i].isTouching(planet2)){
          stone[i].velocity.x *=-1;
          stone[i].velocity.y *=-1;
        }
        if (stone[i].isTouching(planet3)){
          stone[i].velocity.x *=-1;
          stone[i].velocity.y *=-1;
        }
        else if (stone[i].isTouching(player)){
          stone[i].life = 0;
          score ++;
        }
    }
}

void reset() {
  score = 0;
  player = new Player(2, 10, height/2);
  planet = new Attractor(random(170,450), random(height), random(20,40), .001, .001);
  planet2 = new Attractor(random(400,850), random(height), random(18,38), 0, 0);
  planet3 = new Attractor(random(800,1200), random(height), random(15,36),-.001, -.001);
  for (int i = 0; i < stone.length; i++) {
   stone[i] = new Particle(new PVector(0, 0));
  }
}

void score() {
  fill(255);
  textAlign(LEFT);
  textSize(12);
  String gameinfo = "";
  gameinfo += "\nScore : "  + score;
  text(gameinfo, 10, 0);
}

void mousePressed() {
stage *=-1;
reset();
}

/* game objects */

class Player {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector side1;
  PVector side2;
  PVector side3;
  float rx, ry, mass;
  float heading = 0;
  float damping = .995;
  float topspeed = 4;
  
  Player(float m, float x, float y) {
    mass = m;
    rx = 5.0;
    ry = 5.0; 
    location = new PVector(x, y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    side1 = new PVector(0,-ry*2);
    side2 = new PVector(-rx,ry*2);
    side3 = new PVector(rx, ry*2);   
  }
  
  void move() {
      //motion
      velocity.add(acceleration);//speed up
      velocity.mult(damping);//slow down over time
      velocity.limit(topspeed); //limit speed
      location.add(velocity);//move
      acceleration.mult(0);//prevent insane speeds
  }
  
  void applyForce(PVector force) {
    //use the force
    PVector f = force.copy();
    f.div(mass); 
    acceleration.add(f);
  }
  
  void turn(float a) {
    heading += a;
  }
  
  void thrust() {
    float angle = heading - PI/2;
    PVector force = new PVector(cos(angle),sin(angle));
    force.mult(0.1);
    applyForce(force);
  }
  
  void render() {    
    fill(0);
    stroke(255);
    pushMatrix();
      translate(location.x, location.y);
      rotate(heading);
      beginShape(TRIANGLES);
      vertex(side1.x, side1.y);
      vertex(side2.x, side2.y);
      vertex(side3.x, side3.y);
      endShape();
    popMatrix();
  }
  
  void collision(){
        //pass through wall
        if (location.x > width)  {
        location.x = 0;
        } else if (location.x < 0) {
        location.x = width;
        }
        if (location.y > height) {
        location.y = 0;
        } else if (location.y < 0) {
        location.y = height;
        }
    }
}

class Attractor {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r, radius, mass, G;
  
  Attractor(float x, float y, float r_, float dirX, float dirY) {
      r = r_;
      mass = r*.1;
      radius = mass*r;
      G = .02;
      location = new PVector(x, y);
      velocity = new PVector(0,0);
      acceleration = new PVector(dirX,dirY);
  }
  
  boolean isTouching(Player player) {
      float r = radius;
      PVector dist = PVector.sub(player.location, location); 
      float distMag = dist.mag();
        if (distMag < r/2+5) {
          return true;
        }else{
          return false;
        } 
  }
  PVector attract(Player player) {
      PVector force = PVector.sub(location, player.location);
      float distance = force.mag();
      distance = constrain(distance, .01, 8);//limit player's distance from attractor
      force.normalize();
      float strength = (G * mass * player.mass) / (distance * distance);
      force.mult(strength);
      return force;
  }
  
  void move() {
    velocity.add(acceleration);
    location.add(velocity); 
  }
  
  void display() {
      stroke(255);
      fill(0);
      ellipse(location.x, location.y, radius, radius);
  }
  
  void collision(){
        //pass through wall
        if (location.x > width)  {
        location.x = 0;
        } else if (location.x < 0) {
        location.x = width;
        }
        if (location.y > height) {
        location.y = 0;
        } else if (location.y < 0) {
        location.y = height;
        }
    }
}
    
class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float radius, life;
  
  Particle(PVector l) {
    radius = 8;
    location = l.copy();
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-2,2),random(-2,2));
    life = 255;
  }
  
 void run() {
   update();
   display();
   collision();
 }
 
  boolean isTouching(Attractor planet) {
      Float r2 = planet.radius;
      PVector dist = PVector.sub(planet.location, location); 
      float distMag = dist.mag();
      if (distMag < radius/2 + r2/2) {
        return true;
      }else{
        return false;
      }
  }
  
  boolean isTouching(Player player) {
      PVector dist = PVector.sub(player.location, location); 
      float distMag = dist.mag();
      if (distMag < radius/2 + 10) {
        return true;
      }else{
        return false;
      }
  }
  
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    life += .2;
  }
 
  void display() {
    stroke(0, life);
    fill(200, life);
    ellipse(location.x,location.y,radius,radius);
  }
 
  void collision(){
        //pass through wall
        if (location.x > width)  {
        location.x = 0;
        } else if (location.x < 0) {
        location.x = width;
        }
        if (location.y > height) {
        location.y = 0;
        } else if (location.y < 0) {
        location.y = height;
        }
    }
}    