
//"Wall" = cave walls
//"Space" = empty spaces
//"Water" = liquids

//Left mouse click to place down water
//Right mouse click to place down wall
//Middle mouse click to delete

//Reset button resets the canvas with random cave structure
//Clear button replaces every block on canvas with space
//Start button starts the actual animation

//Size of grid (100+ gets really laggy)
int cellX = 100;
int cellY = 100;

//For enabling debug mode
boolean debug = false;

//Viscosity of the fluid (lower = less viscis), little glitchy under 2.5
float viscosity = 2.5;

//FPS setting
int blinksPerSecond = 60;

//DONT TOUCH
String[][] cellsNow;
String[][] cellsNext;
String[][] waterMassNow;
String[][] waterMassNext;

float compression = 0.02;
float maxMass = 1;
float minMass = 0.001;
float minFlow = 0.01;

int caveCycles = 25;

float padding = 50;

float cellSizeX;
float cellSizeY;

int frameNumber;

boolean start;

//Buttons
float buttonY = padding / 2;
float buttonW = 150;
float buttonH = 40;

float buttonXStart = 450;
float buttonXReset = 650;
float buttonXClear = 850;

//Sets up initial values
void setup(){
  //fullScreen();
  size(2000, 2000);
  smooth();
  
  frameNumber = 0;
  
  start = false;
  cellsNow = new String[cellX][cellY];
  cellsNext = new String[cellX][cellY];
  waterMassNow = new String[cellX][cellY];
  waterMassNext = new String[cellX][cellY];
  
  cellSizeX = (width - padding * 2) / cellX;
  cellSizeY = (height - padding * 2) / cellY;
  
  setCellBlank();
  frameRate(120);
  createCave();

}

//Draws the visuals
void draw(){
  background(255, 255, 0);
  
  //Draws frame counter
  textAlign(LEFT);
  textSize(30);
  fill(0);
  text("Frame: " + frameNumber, 25, 35);
  
  //Draws buttons
  rectMode(CENTER);
  strokeWeight(2);
  fill(0);
  stroke(255, 0, 0);
  rect(buttonXStart, buttonY, buttonW, buttonH);
  rect(buttonXReset, buttonY, buttonW, buttonH);
  rect(buttonXClear, buttonY, buttonW, buttonH);
  
  //Writes text on buttons
  textAlign(CENTER, CENTER);
  fill(255);
  if (start == false){
    text("Start", buttonXStart, buttonY - 5);
  }
  else{
    text("Stop", buttonXStart, buttonY - 5);
  }
  text("Reset", buttonXReset, buttonY - 5);
  text("Clear", buttonXClear, buttonY - 5);
  
  //Adds some editional information if debug mode is on
  if (debug == true){
    strokeWeight(0.5);
    stroke(0);
  }
  
  //Draws walls, liquids, and spaces
  else{noStroke();}
  rectMode(CORNER);

  for (int i = 0; i < cellsNow.length; i++){
    for (int j = 0; j < cellsNow[0].length; j++){
      
      if (cellsNow[i][j] == "Wall"){fill(128, 132, 135);}
      else {fill(255);}
      float x = padding + i * cellSizeX;
      float y = padding + j * cellSizeY;
      
      if (cellsNow[i][j] != "Water"){
        rect(x, y, cellSizeX, cellSizeY);
      }
      else{
        if (waterMassNow[i][j] != null){
          float sizePercent = getWaterCellSize(i, j);
          color rgbColour = getWaterColour(i, j, sizePercent);
          fill(255);
          rect(x, y, cellSizeX, cellSizeY);
          fill(rgbColour);
          rect(x, y + cellSizeY * (1 - sizePercent), cellSizeX, cellSizeY);
        }
      }
      fill(0);
      
      if (debug == true){
        if (waterMassNow[i][j] != null){
          textSize(10);
          text(round(float(waterMassNow[i][j]) * 1000) / 1000.0, x + cellSizeX / 2, y + cellSizeY / 2);
        }
      }
    }
  }
  
  //Mouse commands for editing
  if (mousePressed){
      if ((mouseX > padding && mouseX < width - padding) && (mouseY > padding && mouseY < height - padding)){
        int [] indexes = getClickIndex();
        //println(indexes[0], indexes[1]);
        
        if (mouseButton == LEFT){
          if (cellsNow[indexes[0]][indexes[1]] == "Space"){
            cellsNext[indexes[0]][indexes[1]] = "Water";
            waterMassNext[indexes[0]][indexes[1]] = str(maxMass);
          }
        }
        else if (mouseButton == RIGHT){
          if (cellsNow[indexes[0]][indexes[1]] == "Space"){
            cellsNext[indexes[0]][indexes[1]] = "Wall";
            waterMassNext[indexes[0]][indexes[1]] = null;
          }
        }
        else{
          if ((cellsNow[indexes[0]][indexes[1]] == "Wall" || cellsNow[indexes[0]][indexes[1]] == "Water") && indexes[1] != cellY - 1){
            cellsNext[indexes[0]][indexes[1]] = "Space";
            waterMassNext[indexes[0]][indexes[1]] = "0";
          }
        }
        cellReplacement(waterMassNow, waterMassNext);
        blockTypeUpdate();
        cellReplacement(cellsNow, cellsNext);
      }
    } 

  //Updates all information for next frame
  if (start == true){
    updateWaterMassCell();
    blockTypeUpdate();
    cellReplacement(cellsNow, cellsNext);
    frameNumber++;
  }
}

//Gets RGB colour values based on water density (mass / volume)
color getWaterColour(int x, int y, float fillPercent){
  color rgb;
  float density = float(waterMassNow[x][y]) / fillPercent;
  if (density >= maxMass - 0.3){
    rgb = color(48, 165, 210);
  }
  else if (density > 0.50){
    rgb = color(78, 195, 240);
  }
  else if (density > 0.20){
    rgb = color(108, 225, 255);
  }
  else if (density > 0.05){
    rgb = color(138, 255, 255);
  }
  else{
    rgb = color(168, 255, 255);
  }
  return rgb;
}

//Updates block types depending on watermass array
void blockTypeUpdate(){
  for (int i = 0; i < cellsNow.length; i++){
    for (int j = 0; j < cellsNow[0].length; j++){
      if (waterMassNow[i][j] == null){
        cellsNext[i][j] = "Wall";
      }
      else if (float(waterMassNow[i][j]) > minMass){
        cellsNext[i][j] = "Water";
      }
      else{
        cellsNext[i][j] = "Space";
      }
    }
  }
}

//Gets the percentage water within a cell
float getWaterCellSize(int x, int y){
  try{
    if (cellsNow[x][y - 1] == "Water"){
      return maxMass;
    }
  }
  catch (ArrayIndexOutOfBoundsException e){}
  
  float size = float(waterMassNow[x][y]) / maxMass;
  return constrain(size, 0, maxMass);
}

//Replaces values in arrayNow with values in arrayNext
void cellReplacement(String [][] arrayNow, String [][] arrayNext){
  for (int i = 0; i < arrayNow.length; i++){
    for (int j = 0; j < arrayNow[0].length; j++){
      arrayNow[i][j] = arrayNext[i][j];
    }
  }
}

//Clears waterMass array
void setCellBlank(){
  for (int i = 0; i < cellsNow.length; i++){
    for (int j = 0; j < cellsNow[0].length - 1; j++){
      waterMassNext[i][j] = "0";
    }
  }
}

//Creates initial cave structure
void createCave(){
  setCellValuesRandomly();
  for (int i = 0; i < caveCycles; i++){
    cellReplacement(cellsNow, cellsNext);
    cellReplacement(waterMassNow, waterMassNext);
    updateCaveCell();
  }
  for (int i = 0; i < cellsNext.length; i++){
    cellsNext[i][cellY - 1] = "Wall";
    waterMassNext[i][cellY - 1] = null;
    cellReplacement(cellsNow, cellsNext);
    cellReplacement(waterMassNow, waterMassNext);
  }
}

//Changes the values from water mass depedning on flow
void flowChangeappender(int xNow,int yNow,int xNew,int yNew, float change){
  waterMassNext[xNow][yNow] = str(float(waterMassNext[xNow][yNow]) - change);
  waterMassNext[xNew][yNew] = str(float(waterMassNext[xNew][yNew]) + change);
}

//Calculates and updates mass of water in each cell
void updateWaterMassCell(){
  float flowChange = 0;
  float massRemaining;
  
  for (int i = 0; i < waterMassNow.length; i++){
    for (int j = waterMassNow[0].length - 1; j >= 0; j--){
      try{
        if (waterMassNow[i][j] != null){
          massRemaining = float(waterMassNow[i][j]);
          
          if (massRemaining <= 0){continue;}
               
          //Going down
          if (cellsNow[i][j + 1] != "Wall"){
            flowChange = maxMass - float(waterMassNext[i][j + 1]);
            
            //if (flowChange > minFlow){flowChange *= 0.5;}
            flowChange = constrain(flowChange, 0, massRemaining);

            flowChangeappender(i, j, i, j + 1, flowChange);
            massRemaining -= flowChange;
          }
          
          if (massRemaining <= 0){continue;}
                
          //Going left
          if (i != 0){
            if (cellsNow[i - 1][j] != "Wall"){
              flowChange = (float(waterMassNow[i][j]) - float(waterMassNow[i - 1][j])) / viscosity;
              
              //if (flowChange > minFlow){flowChange *= 0.5;}
              flowChange = constrain(flowChange, 0, massRemaining);
              
              flowChangeappender(i, j, i - 1, j, flowChange);
              massRemaining -= flowChange;
            }
          }
               
          //Going right
          if (cellsNow[i + 1][j] != "Wall"){
            flowChange = (float(waterMassNow[i][j]) - float(waterMassNow[i + 1][j])) / viscosity;
            
            //if (flowChange > minFlow){flowChange *= 0.5;}
            flowChange = constrain(flowChange, 0, massRemaining);
            
            flowChangeappender(i, j, i + 1, j, flowChange);
            massRemaining -= flowChange;
          }
        }
      }
      catch (ArrayIndexOutOfBoundsException e){}
    }
  }
  cellReplacement(waterMassNow, waterMassNext);
}

//Updates cellsNext with information of next generation (for cave walls)
void updateCaveCell(){
  for (int i = 0; i < cellsNow.length; i++){
    for (int j = 0; j < cellsNow[0].length; j++){
      int aliveNeighbours = countLivingNeighbours(i, j);
      //println(aliveNeighbours);
      
      if (cellsNow[i][j] == "Wall"){
        if (aliveNeighbours >= 4){
          cellsNext[i][j] = "Wall";
          waterMassNext[i][j] = null;
        }
        else{
          cellsNext[i][j] = "Space";
          waterMassNext[i][j] = "0";
        }
      }
      else{
        if (aliveNeighbours >= 5){
          cellsNext[i][j] = "Wall";
          waterMassNext[i][j] = null;
        }
        else{
          cellsNext[i][j] = "Space";
          waterMassNext[i][j] = "0";
        }
      }
    }
  }
}

//Triggers mouse click events
void mouseClicked(){
  if ((mouseX > buttonXStart - buttonW / 2 && mouseX < buttonXStart + buttonW / 2) && (mouseY > buttonY - buttonH / 2 && mouseY < buttonY + buttonH / 2)){
    if (start == true){
      start = false;
      frameRate(60);
    }
    else{
      start = true;
      frameRate(blinksPerSecond);
    }
    
  }
  else if ((mouseX > buttonXReset - buttonW / 2 && mouseX < buttonXReset + buttonW / 2) && (mouseY > buttonY - buttonH / 2 && mouseY < buttonY + buttonH / 2)){
    setup();
  }
  else if ((mouseX > buttonXClear - buttonW / 2 && mouseX < buttonXClear + buttonW / 2) && (mouseY > buttonY - buttonH / 2 && mouseY < buttonY + buttonH / 2)){
    setCellBlank();
    cellReplacement(waterMassNow, waterMassNext);
    blockTypeUpdate();
    cellReplacement(cellsNow, cellsNext);
  }
}

//Gets array index of clicked location
int [] getClickIndex(){
  int indexX = int((mouseX - padding) / cellSizeX);
  int indexY = int((mouseY - padding) / cellSizeY);
  int [] indexes = {indexX, indexY};
  return indexes;
}

//Counts number(s) of live neighbours 
int countLivingNeighbours(int x, int y){
  int count = 0;
  
  for (int i = -1; i <= 1; i++){
    for (int j = -1; j <= 1; j++){
      
      try {
        if ((cellsNow[x + j][y + i] == "Wall") && (j != 0 || i != 0)){
        count++;
        }
      }
      catch (ArrayIndexOutOfBoundsException e){}
    }
  }
  return count;
}

//Sets random initial values for Cave
void setCellValuesRandomly(){
  for (int i = 0; i < cellsNow.length; i++){
    
    for (int j = 0; j < cellsNow[0].length; j++){
      int x = round(random(0,100));
      
      if (x < 48){
        cellsNext[i][j] = "Wall";
        waterMassNext[i][j] = null;
      }
      else{
        cellsNext[i][j] = "Space";
        waterMassNow[i][j] = "0";
      }
    }
  }
}