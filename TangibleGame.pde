PGraphics gameSurface; //<>//
PGraphics scoreBoard;
PGraphics topView;
PGraphics barChart;

Mover playable_sphere;
Cylinder cylinder;
ParticleSystem particle_system;
HScrollbar hs_scroll_bar;

ImageProcessing imgproc;

ArrayList<PVector> cylindersPosition = new ArrayList<PVector>();
ArrayList<Float> scores = new ArrayList<Float>();

void settings() {
  size(window_size_x, window_size_y, P3D);
}

void setup() {
  
  //has to be in the main game process
  //********Merge with ImgProcessing********
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  //********Merge with ImgProcessing********


  noStroke();
  frameRate(fps);

  playable_sphere = new Mover();
  cylinder = new Cylinder(defaultCylinderColour);
  particle_system = new ParticleSystem();

  gameSurface = createGraphics(width, height - score_graphic, P3D);
  scoreBoard = createGraphics(square_for_score, square_for_score, P2D);
  topView = createGraphics(square_for_score, square_for_score, P2D);
  barChart = createGraphics(width - 2*square_for_score - 20, square_for_score, P2D);
  hs_scroll_bar = new HScrollbar(2*score_graphic, height-25, score_graphic*3/4, 15);
}

void draw() {


  //has to be in the main game process
  //********Merge with ImgProcessing********
  PVector rotation = imgproc.getRotation();
  changeAngleForRotation(rotation);
  //********Merge with ImgProcessing********

  background(bottomColor);
  drawGame();
  image(gameSurface, 0, 0);
  drawScoreBoard();
  image(scoreBoard, 150, height-score_graphic+5);
  drawTopView();
  image(topView, 5, height-score_graphic+5);
  drawBarChart();
  image(barChart, 2*square_for_score+10+5, height-score_graphic+5);
  hs_scroll_bar.update(); 
  hs_scroll_bar.display();
}


void changeAngleForRotation(PVector rotation) 
{
  if (!shiftPressed) {
    thetaX = rotation.x;
    thetaZ = rotation.z;

    if (thetaX <= -PI/3) thetaX = -PI/3;
    else if (thetaX >= PI/3) thetaX = PI/3;

    if (thetaZ <= -PI/3) thetaZ = -PI/3;
    else if (thetaZ >= PI/3) thetaZ = PI/3;
  }
}

void mouseWheel(MouseEvent evenement) {
  float e = evenement.getCount();
  if (e < 1 ) {
    angularSpeed+=0.1;
  } else {
    angularSpeed-=0.1;
  }

  if (angularSpeed >= 1.5) {
    angularSpeed = 1.5;
  } else if (angularSpeed <= 0.3) {
    angularSpeed = 0.3;
  }
}

void mousePressed() {
  if (shiftPressed) {
    addCenterOfVillain();
  }
}

void keyPressed() {
  if (key == CODED && keyCode == SHIFT) {        
    shiftPressed = true;
    oldThetaX = thetaX;
    oldThetaY = thetaY;
    oldThetaZ = thetaZ;
    thetaX = -PI/2;
    thetaY = 0;
    thetaZ = 0;
    pauseGame();
  }
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT ) {  
    shiftPressed = false;
    thetaX = oldThetaX;
    thetaY = oldThetaY;
    thetaZ = oldThetaZ;
    resumeGame();
  }
}

void pauseGame() {
  gamePaused = true;
}

void resumeGame() {
  gamePaused = false;
}


//#############################################
// Getters for points & previousPoints variables
//#############################################
float getPoints() {
  if (particle_system == null) return 0;
  return particle_system.points;
}
float getLastPoints() {
  if (particle_system == null) return 0;
  return particle_system.previousPoints;
}
