class FlowField
{
  int cellSize;
  int cols, rows;
  PVector [][] field;
  color lineColor;
  float fieldBias;
  float zoff = 0;
  
  FlowField( int csize )
  {
    cellSize = csize;
    lineColor = color(200);
    fieldBias = random( 1, 360 );
    cols = width / cellSize;
    rows = height / cellSize;
    field = new PVector [ cols ] [ rows ];
    reCompute();
  }
  
  void reCompute()
  {
    float xoff = 0;
    for ( int c = 0; c < cols; c++ )
    {
      float yoff = 0;
      for ( int r = 0; r < rows; r++ )
      { 
        float angle = map( noise( xoff, yoff, zoff ), 0, 1, 0, TWO_PI );
        angle += radians( fieldBias );
        PVector v = new PVector( 1, 0 ); // unit vector with angle 0
        v.rotate( angle );
        field[ c ][ r ] = v; 
        yoff += 0.1;
      }
      xoff += 0.1;
    }
    zoff += 0.1;
    fieldBias += random( -15, 15 );
  }
  
    void randomReCompute()
  {
    for ( int c = 0; c < cols; c++ )
    {
      for ( int r = 0; r < rows; r++ )
      { 
        float angle = radians( random( 0, 360 ) );
        field [ c ][ r ] = new PVector( cos( angle ), sin( angle ) );
      }
    }
  }
  
  
  void update()
  {
    if ( controls.buttons[(int)controls.buttonsIndex.get("flow")].state )
    { reCompute(); }
    else
   { randomReCompute(); } 
  }
  
  void draw()
  {
    stroke( lineColor );
    strokeWeight( 1 );
    PVector loc = new PVector( cellSize / 2, cellSize / 2 ); // middle of cell
    for ( int c = 0; c < cols; c++ )
    {
      loc.y = cellSize / 2;
      for ( int r=0; r < rows; r++ )
      {        
        pushMatrix();
        translate( loc.x, loc.y );
        rotate( field[c][r].heading() );
        line( -8, 0, 8, 0 );
        line( 3, -3, 8, 0 );
        line( 3, 3, 8, 0 );
        popMatrix();
        loc.y += cellSize;
      }
      loc.x += cellSize;
    }
  }
  
}
