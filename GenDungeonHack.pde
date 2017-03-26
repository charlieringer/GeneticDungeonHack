GeneticDungeon dungeonMaker;
int xOff = 100;
int yOff = 100;
int gridSize = 15;
boolean noUI = false;
int maxGens = 30;
int numbGens = 0;


void setup()
{
  dungeonMaker = new GeneticDungeon();
  dungeonMaker.run();
  size(1000,5000);
  stroke(128);
}

void draw()
{
  if(noUI && numbGens < maxGens)
  {
    dungeonMaker.run();
    numbGens++;
  }
  background(0);
  pushMatrix();
  translate(xOff,yOff);
  dungeonMaker.drawBest(gridSize);
  popMatrix();
  PImage save = get(0,0,2000,2000);
  save.save(numbGens + ".png");
}

void keyPressed()
{
  if(noUI) return;
  if(key == ' ')
  {
    dungeonMaker.run();
  }
  if(key == 'w')
  {
    yOff+=gridSize;
  }
    if(key == 'a')
  {
    xOff+=gridSize;
  }
    if(key == 's')
  {
    yOff-=gridSize;
  }
    if(key == 'd')
  {
    xOff-=gridSize;
  }
      if(key == 'q')
  {
    if(gridSize > 6)gridSize-=4;
  }
      if(key == 'e')
  {
    gridSize+=4;
  }
}

void mousePressed()
{
  if(noUI) return;
  dungeonMaker.run();
}