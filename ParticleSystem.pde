final PVector normalX = new PVector(1, 0, 0);
  
class ParticleSystem {
  ArrayList<PVector> particles;
  PVector originVillain;
  PVector origin;
  
  float points;
  float previousPoints = 0;
  
  ParticleSystem() {
   originVillain = new PVector(0,-boxThickness/2 - cylinderHeight,0);
   particles = new ArrayList<PVector>();
   setupVillain();
  }
  
  //#############################################
  //------------SETUP OF THE VILLAIN------------
  //#############################################
  void setupVillain() {
        points = 0;
        
        robotnik = loadShape("robotnik.obj");
        robotnik.scale(50);
        robotnik.rotateX(PI);
        texture = loadImage("robotnik.png");
        robotnik.setTexture(texture);
  }
  
  //#############################################
  // Main method that will add and adjacent cylinder to the whole system
  //#############################################
  void addParticle() {
    PVector center;
    int numAttempts = 100;
    for(int i=0; i<numAttempts; i++) {
      // Pick a cylinder and its center.
      int index = int(random(particles.size()));
      center = particles.get(index).copy();
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*cylinderBaseSize;
      center.z += cos(angle) * 2*cylinderBaseSize;
      if(checkPosition(center)) {
        particles.add(new PVector(center.x , 0, center.z));
        points -= 1;
        break;
      }
    }
 }
 
  //#############################################
  // Check if a position is available, i.e.
  //   - would not overlap with particles that are already created
  //      (for each particle, call checkOverlap())
  //   - is inside the board boundaries
  //#############################################
   boolean checkPosition(PVector center) {
     boolean result = true;
     pushMatrix();
     translate(width/2, height/2);
     if ( (center.x > (boxLength/2 - cylinderBaseSize)) || (center.x <  - boxLength/2 + cylinderBaseSize)  || (center.z > (boxLength/2 - cylinderBaseSize)) || (center.z < - boxLength/2 + cylinderBaseSize) ) result = false;
     for(PVector v : particles)
       if (checkOverlap(v, center)) result = false;   
     popMatrix();
     return result;
  }
  
  //#############################################
  // Check if a particle with center c1 and another particle with center c2 overlap.
  //#############################################
  boolean checkOverlap(PVector c1, PVector c2) {
    double distance = sqrt((c1.x - c2.x)*(c1.x - c2.x) + (c1.z - c2.z)*(c1.z - c2.z));
    return distance < 2*cylinderBaseSize;
  }
  
  //#############################################
  // Do the following two things :
  //    - Add a new cylinder at a regular time interval
  //    - Move the bad guy so that it always faces the movement of the ball 
  //#############################################
  void run() {
    playable_sphere.checkCylinderCollision();
    if(frameCount % 30 == 0 ) {
      addParticle(); //interval set to 0.5 seconds
    }
    
    // Rotation of the villain according to the position of the ball
    float sphereZ = playable_sphere.location().z - originVillain.copy().z;
    float sphereX = playable_sphere.location().x - originVillain.copy().x;
    float posNormZ = normalX.copy().normalize().z;
    float posNormX = normalX.copy().normalize().x;
    float angleVillain = (float) Math.atan2(sphereX*posNormZ - sphereZ*posNormX, sphereX*posNormX + sphereZ*posNormZ);
    normalX.x = playable_sphere.location().x - originVillain.x;
    normalX.z = playable_sphere.location().z - originVillain.z;
    normalX.y = playable_sphere.location().y - originVillain.y;
    robotnik.rotateY(angleVillain);
  }
  
  //#############################################
  // Draw the position of the cylinder in the square top view box
  //#############################################
  void particleTopView() {
    topView.noStroke();
    
    for (int i = 0; i < particles.size(); ++i){
      PVector particle_vector = particles.get(i);
      float ellipseX = (particle_vector.x + boxLength/2) * square_for_score/boxLength;
      float ellipseY = (particle_vector.z + boxLength/2) * square_for_score/boxLength;
      float ellipseDim = (2*cylinderBaseSize) * square_for_score/boxLength;
      if(i==0){
        topView.fill(colorVillainTopView);
        topView.ellipse(ellipseX, ellipseY, ellipseDim, ellipseDim);
      } else {
        topView.fill(defaultCylinderColour);
        topView.ellipse(ellipseX, ellipseY, ellipseDim, ellipseDim);
      }
    }
  }
}

//#############################################
// Checks if we can add a cylinder given a x and y coordinates
//#############################################
boolean canAddCylinder(float x, float y) {
  return !( (x > (width/2 + boxLength/2 - cylinderBaseSize)) || (x < width/2 - boxLength/2 + cylinderBaseSize) || (y > (height/2 + boxLength/2 - cylinderBaseSize))  || (y < height/2 - boxLength/2 + cylinderBaseSize) );
}

//#############################################
// Set up the origin of the villain in order to place it on the board.
//#############################################
void addCenterOfVillain() {
  //when a new origin is set, remove all the cylinders and add a new cylinder at the origin
  particle_system.particles.clear();
  particle_system.previousPoints = particle_system.points;
  particle_system.points = 0;
  scores = new ArrayList<Float>();
  
  if(canAddCylinder(mouseX, mouseY)){ 
    PVector origin = new PVector(mouseX - width/2 , 0 , mouseY - height/2);  //origin in upper left corner
    particle_system.particles.add(origin); 
    particle_system.origin = origin;
  } else {
    particle_system.origin = null;
  }
}
