class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;

  //Rotation angles of the sphere
  float sphere_rotX = 0;
  float sphere_rotZ = 0;

  //Add textures
  private PImage img;
  private PShape globe;
  
  //Related to the geometry of the object and have an impact on its moment inertia
  final float K_INERTIA = 2/3;

  Mover() {
    location = new PVector(0, -(radius_sphere + boxThickness/2), 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);

    //Adding texture of a pool ball
    img = loadImage("PoolBall.jpeg");
    globe = createShape();
    globe = createShape(SPHERE, radius_sphere);
    globe.setStroke(false);
    globe.setTexture(img);
    
  }

  //#############################################
  // Update the position of the ball so that it has a real movement
  //#############################################
  void update() {
    gravityForce = new PVector(sin(thetaZ) * gravityConstant, 0, -sin(thetaX) * gravityConstant);
    velocity.add(gravityForce);
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(friction);
    location.add(velocity);
    
    //Update rotation angles of the sphere
    sphere_rotX = (-velocity.z)/radius_sphere;
    sphere_rotZ = (velocity.x)/radius_sphere;
    checkCylinderCollision();
  }
  
  //#############################################
  //Displays the ball and makes it move with real rolling effect
  //#############################################
  void display() {
    gameSurface.noStroke();
    gameSurface.pushMatrix();
    gameSurface.translate(location.x, location.y, location.z);
    //Add rolling effect to the ball
    if (!gamePaused) {
      gameSurface.rotateX(PI/2);
      globe.rotateX(sphere_rotX);
      globe.rotateY(sphere_rotZ);
    }
    gameSurface.shape(globe);
    gameSurface.popMatrix();
  }

  //#############################################
  //---AVOID THE BALL TO GO OUT OF THE BOARD-----
  //#############################################
  void checkEdges() {
    if (location.x + radius_sphere > boxLength/2) {
      velocity.x *= -1;
      location.x = boxLength/2 - radius_sphere;
    } else if (location.x - radius_sphere < -boxLength/2) {
      velocity.x *= -1;
      location.x = -boxLength/2 + radius_sphere;
    }

    if (location.z + radius_sphere > boxLength/2) {
      velocity.z *= -1;
      location.z = boxLength/2 - radius_sphere;
    } else if (location.z - radius_sphere < -boxLength/2) {
      velocity.z *= -1;
      location.z = -boxLength/2 + radius_sphere;
    }
  }

  //#############################################
  //-------CHECK COLLISIONS WITH CYLINDERS-------
  //#############################################
  void checkCylinderCollision() {
    for (int i = 0; i < particle_system.particles.size(); ++i) {
      PVector cylinderPosition = particle_system.particles.get(i);
      PVector ballCylVect = new PVector(location.x - cylinderPosition.x, 0, location.z - cylinderPosition.z);

      if (ballCylVect.mag() <= (radius_sphere + cylinderBaseSize)) {
        if (cylinderPosition == particle_system.origin) {
          particle_system.particles.clear();
          particle_system.origin = null;
        } else {
          //remove the cylinder if the ball hits it
          particle_system.particles.remove(i);
          PVector normal = ballCylVect.normalize();
          float veloNorm = PVector.dot(velocity, normal)*2;
          PVector vector = PVector.mult(normal, veloNorm);
          velocity = PVector.sub(velocity, vector);
          particle_system.points += defaultGain * playable_sphere.velocity.mag();;
        }
      }
    }
  }

  PVector location() {
    return location.copy();
  }
}
