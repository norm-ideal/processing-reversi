
final int BANSIZE = 640;
final int CELLSIZE = BANSIZE / 8;
final int STONESIZE = round(CELLSIZE * 0.9);
 
final int HITO = 1;
final int COMP = 2;

final int MAXDEPTH = 5;
final boolean DEBUG = false;

final int[][] tensu =
  { {0,0,  0,0,0,0,0,  0,0,0},
    {0,9,  1,2,2,2,2,  1,9,0},
    {0,1,-10,2,2,2,2,-10,1,0},
    {0,2,  2,2,2,2,2,  2,2,0},
    {0,2,  2,2,2,2,2,  2,2,0},
    {0,2,  2,2,2,2,2,  2,2,0},
    {0,2,  2,2,2,2,2,  2,2,0},
    {0,1,-10,2,2,2,2,-10,1,0},
    {0,9,  1,2,2,2,2,  1,9,0},
    {0,0,  0,0,0,0,0,0,0,0} };
    
Ban ban = new Ban();
int teban;
int sente;
int gote;
int passCount;
int moveCount;
boolean redraw = true;
 
// ************************ strategy *************************

// ***********************************************************


void setup()
{
  teban = KURO;
  
  sente = COMP;
  gote = HITO;
 
  passCount = 0;
  moveCount = 0;
 
  size(640, 640);  // this needs to be constant for JavaScript
  ban = new Ban();
}
 
void showBan(Ban b)
{
  background(0,96,0);
  for(int i=0; i<9; i++)
  {
    line(0,i*CELLSIZE,BANSIZE,i*CELLSIZE);
    line(i*CELLSIZE,0,i*CELLSIZE,BANSIZE);
  }
 
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      switch(b.get()[x][y])
      {
        case SOTO:
          break;
        case AKI:
          break;
        case KURO:
          fill(0);
          ellipse( round((x-0.5)*CELLSIZE), round((y-0.5)*CELLSIZE), STONESIZE, STONESIZE );
          break;
        case SHIRO:
          fill(255);
          ellipse( round((x-0.5)*CELLSIZE), round((y-0.5)*CELLSIZE), STONESIZE, STONESIZE );
          break;
      }
    }
  }
}
 
void draw()
{
  showBan(ban);
  while( !ban.isPlacable(teban) )
  {
    passCount++;
    teban = -teban;
    if( passCount >= 2)
    {
      int[] gameResult = ban.gameEnd();
      println("Kuro: "+gameResult[0]+" Shiro:"+gameResult[1]);
      println("Game END\n");
      noLoop();
      return;
    }
  }
 
  if( (teban==KURO && sente == COMP) || (teban==SHIRO && gote == COMP))
  {
    // if redraw-flag is on, return once to draw the board.
    if( redraw )
    {
      redraw = false;
      return;
    }
    Move m;
    m = ban.getMoveR(teban, MAXDEPTH, 0);

    println("Computer : (" + m.x + ","+ m.y + ")");
    ban.put(teban, m.x, m.y);
    passCount = 0;
    moveCount++;
    teban = -teban;
    redraw = true;
  } 
}
  
void mouseClicked()
{
  int gx = int(mouseX / CELLSIZE) + 1;
  int gy = int(mouseY / CELLSIZE) + 1;
 
  if( !((teban == KURO && sente == HITO )
          || (teban==SHIRO && gote == HITO))) {
            return;
  }
 
  if( ban.turn(teban, gx, gy) == 0 )
    return;
 
  ban.put(teban, gx, gy);
  passCount = 0;
  moveCount++;
  teban = -teban;
}


