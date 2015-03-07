FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int currentColumn = 0;
int columnCount;

int yearMin, yearMax;
int[] years;

PFont plotFont;

int volumeInterval = 5;
int yearInterval = 1;
//int volumeIntervalMinor = 5;

float [] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

Integrator[] interpolators;

void setup(){
  size(920,605);
  
  data = new FloatTable("popProgramLang2.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length -1];
  
  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
  
  interpolators = new Integrator[rowCount];
  for(int row=0; row<rowCount; row++){
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.1; //Set lower than the default.
  }
  
  //Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);
  
  smooth();
}

void draw(){
  background(224);
  
  //Show the plot area as a white box. 
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
  
  drawTitleTabs();
  drawAxisLabels();
  
  for(int row=0; row<rowCount; row++){
    interpolators[row].update();
  }
  
  drawYearLabels();
  drawVolumeLabels();
  
  //Draw the title of the current plot.
  //fill(0);
  //textSize(20);
  //String title = data.getColumnName(currentColumn);
  //text(title, plotX1, plotY1 - 10);
  
  noStroke();
  //Draw the data for the first column.
  //fill(#07197F);  //#07197F
  drawDataArea(currentColumn);
  
//  float m = map(currentColumn, 0, 9, 0.0, 1.0);
//  
//  color from = color(7, 25, 127);
//  color to = color(167, 180, 255);
//  color colors = lerpColor(from, to, m);
  
 // fill(colors);
}

void drawTitleTabs(){
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  //String title = data.getColumnName(currentColumn);
  //text(title, plotX1, plotY1 - 10);
  
  //On first use of this method, allocate space for an array
  //to store the values for the left and right edges of hte tabs. 
  if (tabLeft == null){
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;
  
  for (int col=0; col<columnCount; col++){
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    
    //If the current tab, set its background white, otherwise use plae gray.
    fill(col == currentColumn ? 255 : 244);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    
    //If current tab, use black for the text, otherwise use dark gray.
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    
    runningX = tabRight[col];
  }
}

void mousePressed(){
  if (mouseY > tabTop && mouseY < tabBottom){
    for(int col=0; col<columnCount; col++){
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]){
        setCurrent(col);
      }
    }
  }
}

void setCurrent(int col){
  currentColumn = col;
  
  for(int row=0; row<rowCount; row++){
    interpolators[row].target(data.getFloat(row, col));
  }
}

void drawAxisLabels(){
  fill(0);
  textSize(13);
  textLeading(15);
  
  textAlign(CENTER, CENTER);
  //Use \n (aka enter or linefeed) to break the text into separate lines.
  text("Ratings\n(%)", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}

void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);
  
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
  
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + textAscent() + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}

void drawVolumeLabels(){
  fill(0);
  textSize(10);
  textAlign(RIGHT, CENTER);
  
  stroke(128);
  strokeWeight(1);
  
  for(float v = dataMin; v <= dataMax; v += volumeInterval){
    if (v % volumeInterval == 0){
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if(v % volumeInterval == 0){
        float textOffset = textAscent()/2;
        if(v == dataMin){
          textOffset = 0;
        }else if (v == dataMax){
          textOffset = textAscent();
        }
        text(floor(v), plotX1 - 10, y);
        line(plotX1 - 4, y, plotX1, y);
      } else {
        //line(plotX1 - 2, y, plotX1, y);
      }
    }
  }
}

//Draw the data as a series of points.
void drawDataArea(int col){
  float m = map(currentColumn, 0, 9, 0.0, 1.0);
  
  color from = color(3, 25, 255);
  color to = color(255, 95, 28);
  color colors = lerpColor(from, to, m);
  
  fill(colors);


  beginShape();
  //int rowCount = data.getRowCount();
  for(int row=0; row<rowCount; row++){
    if(data.isValid(row, col)){
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
  

}

//void keyPressed(){
//  if(key == '['){
//    currentColumn--;
//    if(currentColumn < 0){
//      currentColumn = columnCount - 1;
//    }
//  }else if(key == ']'){
//    currentColumn++;
//    if(currentColumn == columnCount){
//      currentColumn = 0;
//    }
//  }
//}


