final int KURO = 1;
final int SHIRO = -1;
final int AKI = 0;
final int SOTO = 255;
final int BANSIZE = 640;
final int CELLSIZE = BANSIZE / 8;
final int STONESIZE = round(CELLSIZE * 0.9);
 
final int HITO = 1;
final int COMP = 2;

final int MAXDEPTH = 2;

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
    
class Move {
  int x;
  int y;
  int value;
  Move() { x = y = value = 0; }
  Move(int ix, int iy) { x=ix; y=iy; value=0; }

}

int[][] ban;
int teban;
int sente;
int gote;
int passCount;
int moveCount;
 
int turnSub(int b[][], int c, int sx, int sy, int dx, int dy)
{
  int teki = -c;
  int result = 0;
 
  sx += dx;
  sy += dy;
  while( b[sx][sy] == teki )
  {
    sx += dx;
    sy += dy;
    result++;
  }
  if( b[sx][sy] == c )
    return result;
  else
    return 0;
}
 
int turn(int b[][], int c, int sx, int sy)
{
  int result;
  result = 0;
 
  if( b[sx][sy] != AKI )
    return 0;
 
  result += turnSub(b, c, sx, sy,  0,  1);
  result += turnSub(b, c, sx, sy,  0, -1);
  result += turnSub(b, c, sx, sy,  1, -1);
  result += turnSub(b, c, sx, sy,  1,  0);
  result += turnSub(b, c, sx, sy,  1,  1);
  result += turnSub(b, c, sx, sy, -1, -1);
  result += turnSub(b, c, sx, sy, -1,  0);
  result += turnSub(b, c, sx, sy, -1,  1);
 
  return result;
}  

int turnCount(int b[][], int c, int sx, int sy)
{
  int result;
  result = 0;
 
  if( b[sx][sy] != AKI )
    return 0;
  if( turnSub(b, c, sx, sy,  0,  1) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  0,  -1) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  1,  -1) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  1,  0) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  1,  1) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  -1,  -1) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  -1,  0) > 0 )
    result ++;
  if( turnSub(b, c, sx, sy,  -1,  1) > 0 )
    result ++;
 
  return result;
}  

 
int putSub(int b[][], int c, int sx, int sy, int dx, int dy)
{
  int count = 0;
  if( turnSub(b,c,sx,sy,dx,dy) == 0 )
    return 0;
  sx += dx;  // sx = sx + dx;
  sy += dy;
  while( b[sx][sy] == -c )
  {
    b[sx][sy] = c;
    count++;
    sx += dx;
    sy += dy;
  }
  return count; 
}
 
int put(int b[][], int c, int sx, int sy)
{
  int result;
  result = 0;
 
  if( turn(b,c,sx,sy) == 0 )
    return 0;
 
  b[sx][sy] = c;
  result += putSub(b, c, sx, sy,  0,  1);
  result += putSub(b, c, sx, sy,  0, -1);
  result += putSub(b, c, sx, sy,  1, -1);
  result += putSub(b, c, sx, sy,  1,  0);
  result += putSub(b, c, sx, sy,  1,  1);
  result += putSub(b, c, sx, sy, -1, -1);
  result += putSub(b, c, sx, sy, -1,  0);
  result += putSub(b, c, sx, sy, -1,  1);
 
  return result;     
}

// ************************ strategy *************************

void copyBan(int[][] src, int[][] dst)
{
  for(int y=0; y<10; y++)
    for(int x=0; x<10; x++)
      dst[x][y] = src[x][y];
}

int eval( int[][] b, int teban, int mx, int my)
{
  int[][] nextban;
  int count = 0;
  int aitenobasho, bashopoint, muki;
  nextban = new int[10][10];
  copyBan(b, nextban);
  put(nextban, teban, mx, my); // <- Tugi no sekai
  
  int result;
  int aitepoint = -999;
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      int c = turn(nextban, -teban, x, y);
      if( c > 0 )
      {
        count++;
        if( aitepoint < tensu[x][y] )
          aitepoint = tensu[x][y];
      }
    }
  }
  aitepoint = aitepoint * (-5);
  if( count == 0 )
    aitenobasho = 100;
  else
    aitenobasho = -count;
  bashopoint = tensu[mx][my] * 10;
  muki = turnCount(ban, teban, mx, my) * 2;
  
  result = aitenobasho + aitepoint + bashopoint + muki;
  
  println( mx, my, aitenobasho, aitepoint, bashopoint, muki, " = ", result);

  return result;
}

Move getMove6(int[][] b, int teban)
{
  Move result = new Move();
  int point = -99999;
  noLoop();

  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      if( turn(b, teban, x, y) > 0 )
      {
        int p = eval(b, teban, x, y);
        if( point < p )
        {
          point = p;
          result.x = x;
          result.y = y;
        }
      }
    }
  }

  loop();
  return result;
}

// ***********************************************************


void setup()
{
  teban = KURO;
  
  sente = COMP;
  gote = HITO;
 
  passCount = 0;
  moveCount = 0;
 
  size(640, 640);
  ban = new int[10][10];
  for(int y=0; y<10; y++)
  {
    for(int x=0; x<10; x++)
    {
      ban[x][y] = AKI;
      if( x==0 || x==9 || y==0 || y==9 )
      {
        ban[x][y] = SOTO;
      }
      else
      {
        ban[x][y] = AKI;
      }
    }
  }
  ban[4][4] = SHIRO;
  ban[5][5] = SHIRO;
  ban[4][5] = KURO;
  ban[5][4] = KURO;
}
 
void showBan(int[][] b)
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
      switch(b[x][y])
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
  while( !isPlacable(ban, teban) )
  {
    passCount++;
    teban = -teban;
    if( passCount >= 2)
    {
      gameEnd(ban);
      return;
    }
  }
 
  if( (teban==KURO && sente == COMP) || (teban==SHIRO && gote == COMP))
  {
    Move m;
//    if( moveCount < 10 )
//      m = getMove2(ban, teban);
//    else if( moveCount < 50 )
//      m = getMove4(ban, teban);
//    else
    m = getMoveR(ban, teban, MAXDEPTH, 0);

    println("Computer : (" + m.x + ","+ m.y + ")");
    put(ban, teban, m.x, m.y);
    passCount = 0;
    moveCount++;
    teban = -teban;
  } 
}
 
void gameEnd(int[][] b)
{
  int wc = 0;
  int bc = 0;
  
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      if(b[x][y] == KURO)
        bc++;
      if(b[x][y] == SHIRO)
        wc++;  
    }
  }
  println("Kuro: "+bc+" Shiro:"+wc);
  println("Game END\n");
  noLoop();
}
 
boolean isPlacable(int[][] b, int teban)
{
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      if(turn(b, teban, x, y) != 0)
      {
        return true;
      }
    }
  }
  return false;
}
 
 
 
Move getMove(int[][] b, int teban)
{
  // stop Display Loop
  noLoop();
 
  Move result = new Move();
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      if( turn(b, teban, x, y) != 0 )
      {
        result.x = x;
        result.y = y;
        if( random(1) < 0.2 )
        {
          loop();
          return result;
        }
      }
    }
  }
  loop();
  return result;
}

Move getMove2(int[][] b, int teban)
{
  // stop Display Loop
  noLoop();
  Move result = new Move();
  int point = 0;

  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      int p2 = turn(b, teban, x, y);
      if( p2 > point )
      {
        result.x = x;
        result.y = y;
        point = p2;
      }
    }
  }
  loop();
  return result;
}

Move getMove3(int[][] b, int teban)
{
  // stop Display Loop
  noLoop();
  Move result = new Move();
  int point = 1000;

  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      int p2 = turn(b, teban, x, y);
      if( p2 > 0 )
      {
        if( p2 < point )
        {
          result.x = x;
          result.y = y;
          point = p2;
        }
      }
    }
  }
  loop();
  return result;
}

Move getMove4(int[][] b, int teban)
{
  // stop Display Loop
  noLoop();
  Move result = new Move();
  int point = 0;

  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      int p2 = turn(b, teban, x, y);
      if( p2 > 0 )
      {
        if( tensu[x][y] > point )
        {
          result.x = x;
          result.y = y;
          point = tensu[x][y];
        }
      }
    }
  }
  loop();
  return result;
}

Move getMove5(int[][] b, int teban)
{
  // stop Display Loop
  noLoop();
  Move result = new Move();
  int point = 0;

  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      int p2 = turnCount(b, teban, x, y);
      if( p2 > 0 )
      {
        p2 += tensu[x][y]*10;
        if( p2 > point )
        {
          result.x = x;
          result.y = y;
          point = p2;
        }
      }
    }
  }
  loop();
  return result;
}

 
void mouseClicked()
{
  int gx = int(mouseX / CELLSIZE) + 1;
  int gy = int(mouseY / CELLSIZE) + 1;
 
  if( !((teban == KURO && sente == HITO )
          || (teban==SHIRO && gote == HITO))) {
            return;
  }
 
  if( turn(ban, teban, gx, gy) == 0 )
    return;
 
  put(ban, teban, gx, gy);
  passCount = 0;
  moveCount++;
  teban = -teban;
}

int banHyouka( int[][] ban, int teban )
{
  int result = 0;
  for( int y=1; y<=8; y++)
    for( int x=1; x<=8; x++)
    {
        if(ban[x][y] == teban )
          result += tensu[x][y];
        if(ban[x][y] == -teban )
          result -= tensu[x][y];
        if( (x == 1 || x == 8) && (y == 1 || y == 8 ))
        {
          if( ban[x][y] == teban )
            result += 100;
          if( ban[x][y] == -teban )
            result -= 100;
        }
    }
  return result;
}

Move getMoveR ( int [][] ban, int teban, int depth, int passcount )  // R は Recursive の R
{
  Move result = new Move();
  if( passcount >= 2 )
  {
    int kekka = 0;
    for( int y=1; y<=8; y++)
    for( int x=1; x<=8; x++)
    {
      if( ban[x][y] == teban )
        kekka ++;
      if( ban[x][y] == -teban )
        kekka --;
    }
    if( kekka > 0 )
      kekka += 10000;
    if( kekka < 0 )
      kekka -= 10000;
    result.value = kekka;
    return result;    
  }

  if( depth == 0 )
  {
    result.value = banHyouka( ban, teban );  // result の x,y には興味がない
    return result;          // 強制終了
  }

  result.value = -99999;
  for( int y=1; y<=8; y++)
  for( int x=1; x<=8; x++)
  {
    if( turn(ban, teban, x, y) != 0 )    // 打てる場所が見つかったら
    {
      int[][] nextban = new int[10][10];
      copyBan(ban, nextban);
      put(nextban, teban, x, y);   // 次の局面をつくる
      Move nextmove = getMoveR( nextban, -teban, depth-1, 0 );
        // 次の局面を相手の立場で評価する
      nextmove.value = -nextmove.value;
      if( depth == MAXDEPTH )
        println( depth, x, y,  nextmove.value );
      
      if( nextmove.value > result.value )
      {
        result.value = nextmove.value;
        result.x = x;
        result.y = y;
      }
    }
  }

  if( result.value == -99999 )    // どこもに打てなかったら
  {
    // 自分は打てないので、相手の手番として盤面を評価する
    result = getMoveR( ban, -teban, depth, passcount+1);
    // 相手の評価値をプラスマイナスひっくり返して自分の評価にする
    result.value = -result.value;
    result.value -= 10;    // パスを強制されたので評価にペナルティ
  }
  return result;
}

