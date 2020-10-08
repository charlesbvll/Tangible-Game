//#############################################
//------------------DRAW GAME------------------
//#############################################
void drawGame() {
    gameSurface.beginDraw();
    basic_settings();
    drawBoard();
    drawSphere();
    drawParticleSystem();
    gameSurface.endDraw();
}


//#############################################
//--------------DRAW SCORE_BOARD---------------
//#############################################
void drawScoreBoard() {
  scoreBoard.beginDraw();
  scoreBoard.background(scoreColor);
  scoreBoard.text("Total Score : ", 10, 25);
  scoreBoard.text(Float.toString(getPoints()), 20, 45);
  scoreBoard.text("Velocity    : ", 10, 65);
  scoreBoard.text(Float.toString(playable_sphere.velocity.mag()), 20, 85);
  scoreBoard.text("Last score  : ", 10, 105);
  scoreBoard.text(Float.toString(getLastPoints()), 20, 125);
  scoreBoard.endDraw();
}


//#############################################
//----------------DRAW TOP_VEIW----------------
//#############################################
void drawTopView() {
  topView.beginDraw();
  topView.background(topViewBoard);
  
  float ellipseX = (playable_sphere.location().x + boxLength/2) * square_for_score/boxLength;
  float ellipseY = (playable_sphere.location().z + boxLength/2) * square_for_score/boxLength;
  float ellipseWidth = 2*radius_sphere*square_for_score/boxLength;
  float ellipseHeight = ellipseWidth;
  topView.fill(colorSphereTopView);
  topView.ellipse(ellipseX, ellipseY, ellipseWidth, ellipseHeight);

  if (particle_system!=null) {
    particle_system.particleTopView();
  }
  topView.endDraw();
}


//#############################################
//---------------DRAW BAR_CHART----------------
//#############################################
void   drawBarChart() {
  barChart.beginDraw();
  barChart.background(colorBarChart);
  barChart.rectMode(CORNER);
  barChart.fill(255);
  
  score_scale = 0.5 + hs_scroll_bar.getPos();
  rectIndex = 0;
  
  if (lastSecond != second() && !gamePaused) {
    scores.add(getPoints());
  }
  
  // Display the chart
  for (Float score_index : scores) {
    float scaling = (Math.abs(score_index) > 2) ? 2*(log(Math.abs(score_index))) : score_index;
    
    float dimRect = rectSize*score_scale;
    float coordX = rectIndex*rectSize*score_scale;
    
    for (int col = 0; col <= Math.abs(scaling); ++col) {
      float coordY = col*rectSize*score_scale;
      if(score_index < 0) {
        barChart.rect(coordX, coordY + score_graphic/2, dimRect, dimRect);
      } else {
        barChart.rect(coordX, -coordY + score_graphic/2, dimRect, dimRect);
      }
    }
    rectIndex++;
  }
  lastSecond = second();
  barChart.endDraw();
  
 }

//#############################################
//----------AUX METHODS FOR DRAW_GAME----------
//#############################################

//---------------BASIC SETTINGS----------------
void basic_settings(){
  gameSurface.noStroke();
  gameSurface.directionalLight(directionalColor.x, directionalColor.y, directionalColor.z, 0, 1, 0);
  gameSurface.ambientLight(ambientColor, ambientColor, ambientColor);
  gameSurface.background(backgroundColor);
}

//-------------SETUP OF THE BOARD--------------
void drawBoard(){
  gameSurface.translate(width/2, height/2, -score_graphic);
  gameSurface.rotateX(thetaX);
  gameSurface.rotateY(thetaY);
  gameSurface.rotateZ(thetaZ);
  gameSurface.fill(boardColor);
  gameSurface.box(boxLength, boxThickness, boxLength);
}

//------------SETUP OF THE SPHERE--------------
void drawSphere(){
  if(!gamePaused) {
    playable_sphere.update();
  }
  playable_sphere.checkEdges();
  playable_sphere.display();
}

//--------SETUP OF THE PARTICLE SYSTEM---------
void drawParticleSystem(){
  for (int i = particle_system.particles.size(); i > 0; --i) {
    PVector position = particle_system.particles.get(i-1);
    gameSurface.pushMatrix();
    gameSurface.translate(position.x,0 , position.z ); //translate origin back to left upper corner
    cylinder.display();
    gameSurface.popMatrix();
   }
  
  if(particle_system.origin != null) {
    gameSurface.pushMatrix();
    gameSurface.translate(particle_system.origin.x  , -cylinderHeight , particle_system.origin.z ); //translate origin back to left upper corner
    gameSurface.shape(robotnik);
    gameSurface.popMatrix();
  }
  
  if(!particle_system.particles.isEmpty() && !gamePaused) {
    particle_system.run();
  }
}
