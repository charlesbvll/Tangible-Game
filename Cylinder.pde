final float   cylinderBaseSize = 20; 
final float   cylinderHeight = 50; 
final int     cylinderResolution = 40;
final color   defaultCylinderColour = color(220, 60, 60);

class Cylinder {
  PShape closedCylinder = new PShape();
  PShape openCylinder = new PShape(); 
  PShape topDisk = new PShape();
  
  //#############################################
  //-----------CONSTRUCTOR OF CYLINDER-----------
  //#############################################
  Cylinder(color cylinderColour) {
    
    // Initialise the Cylinder
    closedCylinder = new PShape();
    openCylinder = new PShape(); 
    topDisk = new PShape();
    
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] z = new float[cylinderResolution + 1];
    
    //Get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      z[i] = cos(angle) * cylinderBaseSize;
    }

    //#############################################
    //-----------SHAPE OF OPEN CYLINDER------------
    //#############################################
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    openCylinder.fill(cylinderColour);
    
    //Draw the border of the cylinder
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i] , 0, z[i]);
      openCylinder.vertex(x[i], -cylinderHeight, z[i]);
    }
    openCylinder.endShape();
          
    //#############################################
    //-----------DISK OF CLOSED CYLINDER-----------
    //#############################################
    topDisk = createShape();
    topDisk.beginShape(TRIANGLE_FAN);
    topDisk.fill(cylinderColour);
  
    for (int i = 0; i< x.length; i++) {
      topDisk.vertex(x[i], -cylinderHeight, z[i]);
    }
    topDisk.endShape();
  
    // MERGE TOP DISK WITH OPEN CYLINDER
    closedCylinder = createShape(GROUP);
    closedCylinder.addChild(openCylinder);
    closedCylinder.addChild(topDisk);
  }
  
  //#############################################
  //----------------DISPLAY METHOD---------------
  //#############################################
  void display() {
    gameSurface.shape(closedCylinder);
  }
}
