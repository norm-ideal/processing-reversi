final int KURO = 1;
final int SHIRO = -1;
final int AKI = 0;
final int SOTO = 255;

class Ban {
  private int[][] b;
  Ban()
  {
    b = new int[10][10];
    for(int y=0; y<10; y++)
    {
      for(int x=0; x<10; x++)
      {
        b[x][y] = AKI;
        if( x==0 || x==9 || y==0 || y==9 )
        {
          b[x][y] = SOTO;
        }
        else
        {
          b[x][y] = AKI;
        }
      }
    }
    b[4][4] = SHIRO;
    b[5][5] = SHIRO;
    b[4][5] = KURO;
    b[5][4] = KURO;
  }

  Ban( Ban org ) {
    // Normally we should call super() here, 
    // but it requires more time for unused initialization,
    // so we call "new int" again here;
    b = new int[10][10];
    for(int i=0; i<10; i++)
      for(int j=0; j<10; j++)
        b[i][j] = org.b[i][j];
  }
 /*
  Ban( int[][] value )
  {
    b = new int[10][10];
    for(int i=0; i<10; i++)
      for(int j=0; j<10; j++)
        b[i][j] = value[i][j];
  }
*/ 
  int[][] get()
  {
    return b;
  }
 
  int turnSub(int c, int sx, int sy, int dx, int dy)
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

 int turn(int c, int sx, int sy)
 {
  int result;
  result = 0;

  if( b[sx][sy] != AKI )
    return 0;
  
  result += turnSub(c, sx, sy,  0,  1);
  result += turnSub(c, sx, sy,  0, -1);
  result += turnSub(c, sx, sy,  1, -1);
  result += turnSub(c, sx, sy,  1,  0);
  result += turnSub(c, sx, sy,  1,  1);
  result += turnSub(c, sx, sy, -1, -1);
  result += turnSub(c, sx, sy, -1,  0);
  result += turnSub(c, sx, sy, -1,  1);

  return result;
 }  

 int putSub(int c, int sx, int sy, int dx, int dy)
 {
  int count = 0;
  if( turnSub(c,sx,sy,dx,dy) == 0 )
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

 int put(int c, int sx, int sy)
 {
  int result;
  result = 0;
  
  if( turn(c,sx,sy) == 0 )
    return 0;

  b[sx][sy] = c;
  result += putSub(c, sx, sy,  0,  1);
  result += putSub(c, sx, sy,  0, -1);
  result += putSub(c, sx, sy,  1, -1);
  result += putSub(c, sx, sy,  1,  0);
  result += putSub(c, sx, sy,  1,  1);
  result += putSub(c, sx, sy, -1, -1);
  result += putSub(c, sx, sy, -1,  0);
  result += putSub(c, sx, sy, -1,  1);

  return result;     
 } 
 
 
 boolean isPlacable(int teban)
 {
   for(int y=1; y<=8; y++)
   {
     for(int x=1; x<=8; x++)
     {
       if(turn(teban, x, y) != 0)
       {
         return true;
       }
     }
   }
   return false;
 }
 
  int turnCount(int c, int sx, int sy)
  {
    int result;
    result = 0;
     
    if( b[sx][sy] != AKI )
      return 0;
    if( turnSub(c, sx, sy,  0,  1) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  0,  -1) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  1,  -1) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  1,  0) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  1,  1) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  -1,  -1) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  -1,  0) > 0 )
      result ++;
    if( turnSub(c, sx, sy,  -1,  1) > 0 )
      result ++;
     
    return result;
  }  



  Move getMoveR (int teban, int depth, int passcount )  // R は Recursive の R
  {
    Move result = new Move();
    if( DEBUG )
    {
      if( depth > MAXDEPTH - 3 )
      {
        for(int i=0; i<MAXDEPTH-depth; i++)
          print("-");
        println(passcount);
      }
    }
    if( passcount >= 2 )
    {
      int kekka = 0;
      for( int y=1; y<=8; y++)
        for( int x=1; x<=8; x++)
        {
          if( b[x][y] == teban )
            kekka ++;
          if( b[x][y] == -teban )
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
      result.value = banHyouka( teban );  // result の x,y には興味がない
      return result;          // 強制終了
    }
  
    result.value = -99999;
    for( int y=1; y<=8; y++)
      for( int x=1; x<=8; x++)
      {
        if( turn(teban, x, y) != 0 )    // 打てる場所が見つかったら
        {
          Ban nextban = new Ban(this);
          nextban.put(teban, x, y);   // 次の局面をつくる
          Move nextmove = nextban.getMoveR(-teban, depth-1, 0 );
            // 次の局面を相手の立場で評価する
          nextmove.value = -nextmove.value;
          if( depth == MAXDEPTH )
            println( depth, x, y,  nextmove.value );
          
          if( result.value < nextmove.value )
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
      result = getMoveR(-teban, depth, passcount+1);
      // 相手の評価値をプラスマイナスひっくり返して自分の評価にする
      result.value = -result.value;
      result.value -= 10;    // パスを強制されたので評価にペナルティ
    }
    return result;
  }
  
  int[] gameEnd()
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
    return new int[] {bc, wc};
  }
  
  int banHyouka(int teban )
  {
    int result = 0;
    for( int y=1; y<=8; y++)
      for( int x=1; x<=8; x++)
      {
          if(b[x][y] == teban )
            result += tensu[x][y];
          if(b[x][y] == -teban )
            result -= tensu[x][y];
          if( (x == 1 || x == 8) && (y == 1 || y == 8 ))
          {
            if( b[x][y] == teban )
              result += 100;
            if( b[x][y] == -teban )
              result -= 100;
          }
      }
    return result;
  }
  
  int eval(int teban, int mx, int my)
  {
    Ban nextban = new Ban(this);
    int count = 0;
    int aitenobasho, bashopoint, muki;
    nextban.put(teban, mx, my); // <- Tugi no sekai
    
    int result;
    int aitepoint = -999;
    for(int y=1; y<=8; y++)
    {
      for(int x=1; x<=8; x++)
      {
        int c = nextban.turn(-teban, x, y);
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
    muki = this.turnCount(teban, mx, my) * 2;
    
    result = aitenobasho + aitepoint + bashopoint + muki;
    
    println( mx, my, aitenobasho, aitepoint, bashopoint, muki, " = ", result);
  
    return result;
  }
}
