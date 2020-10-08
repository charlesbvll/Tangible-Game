final int     window_size_x = 800;
final int     window_size_y = 800;
final float   depth = -1000;
final int     score_graphic = 150;
final int     square_for_score = score_graphic-10;

// Colors drawGame
final color   backgroundColor = color(216, 223, 239);
final color   boardColor = color(78, 122, 207);
// Color bottom of window
final color   bottomColor = color(162, 165, 200);
// Color drawScore
final color   scoreColor = color(132, 60, 101);
// Color drawTopView
final color   topViewBoard = color(56, 91, 185);
final color   colorSphereTopView = color(0, 0, 0);
final color   colorVillainTopView = color(150,20,20);
// Color drawBarChart
final color   colorBarChart = color(125,128,190);
final PVector directionalColor = new PVector(50, 100, 200);
final float   ambientColor = 200;

final PVector topViewBoardColor = new PVector(56, 91, 185);
final int     fps = 60;

final float   boxLength = 500;
final float   boxThickness = 20;

final float   gravityConstant = 0.1;
final float   normalForce = 1;
final float   mu = 0.01;
final float   frictionMagnitude = normalForce * mu;

final float   radius_sphere = 25; 

float  angularSpeed = 1;
float  defaultGain = 1;
float  thetaX = 0;
float  thetaY = 0;
float  thetaZ = 0;
float  oldThetaX = 0;
float  oldThetaY = 0;
float  oldThetaZ = 0;

PShape robotnik;
PImage texture;

boolean gamePaused = false;
boolean shiftPressed = false;

float  score_scale = 1;
float  rectIndex = 0;
float  lastSecond = 0;
float  rectSize = 8;
