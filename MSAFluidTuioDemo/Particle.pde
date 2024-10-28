class Particle {
  //float MAX_LIFESPAN = PARTICLES_LIFESPAN;
  
  PVector velocity;
  float lifespan;
  
  PShape part;
  float partSize;
  
  PVector gravity = new PVector(0,0.1);


  Particle() {
    partSize = random(10,PARTICLES_SIZE);
    part = createShape();
    part.beginShape(QUAD);
    part.noStroke();
    part.texture(sprite);
    part.normal(0, 0, 1);
    part.vertex(-partSize/2, -partSize/2, 0, 0);
    part.vertex(+partSize/2, -partSize/2, sprite.width, 0);
    part.vertex(+partSize/2, +partSize/2, sprite.width, sprite.height);
    part.vertex(-partSize/2, +partSize/2, 0, sprite.height);
    part.endShape();
    
    rebirth(width/2,height/2);
    lifespan = random(PARTICLES_LIFESPAN);
  }

  PShape getShape() {
    return part;
  }
  
  void rebirth(float x, float y) {
    float a = random(TWO_PI);
    float speed = random(0.5,PARTICLES_SPEED);
    velocity = new PVector(cos(a), sin(a));
    velocity.mult(speed);
    lifespan = random(PARTICLES_LIFESPAN);   
    part.resetMatrix();
    part.translate(x, y); 
  }
  
  boolean isDead() {
    if (lifespan < 0) {
     return true;
    } else {
     return false;
    } 
  }
  
  public void update() {
    update(gravity);
  }
  
  public void update(PVector vel) {
    lifespan = lifespan - 1;
    velocity.add(vel);
    //float speed = random(0.5,PARTICLES_SPEED);
    //velocity.mult(speed);
    
    part.setTint(color(255,lifespan));
    part.translate(velocity.x, velocity.y);
  }
}
