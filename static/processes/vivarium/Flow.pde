class FlowField
{
  int cellSize;
  int cols, rows, bookmark;
  PVector [][] field;
  color lineColor;
  float fieldBias;
  float zoff = 0;
  PGraphics workingBuffer;
  PGraphics visibleBuffer;
  
  FlowField( int csize )
  {
    cellSize = csize;
    lineColor = color(200);
    fieldBias = random( 1, 360 );
    cols = width / cellSize;
    rows = height / cellSize;
    bookmark = 0;
    field = new PVector [ cols ] [ rows ];
    workingBuffer = createGraphics(width, height);
    visibleBuffer = createGraphics(width, height);
    visibleBuffer.beginDraw();
    visibleBuffer.background( 0, 0, 0, 0 );
    visibleBuffer.endDraw();
    workingBuffer.beginDraw();
    workingBuffer.background( 0, 0, 0, 0 );
    workingBuffer.endDraw();
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
        field [ c ][ r ] = new PVector( cos( angle ), sin( angle ) );
        yoff += 0.1;
      }
      xoff += 0.1;
    }
    zoff += 0.1;
    fieldBias += random( -15, 15 );
  }
 
  PVector lookup( PVector loc )
  {
    int column = int( constrain( loc.x / cellSize, 0, cols - 1 ) );
    int row = int( constrain( loc.y / cellSize, 0, rows -1) );
    return field[column][row].get();
  }
 
  void update()
  {
    if ( frameCount % 10 == 0 ) { reCompute(); }
  }
  
  void draw()
  {
    if ( frameCount % 10 == 0 ) { image( visibleBuffer, 0, 0 ); }
    int stoppingPoint = bookmark + cols / 8;
    if ( stoppingPoint > cols ) { stoppingPoint = cols; }
    
    workingBuffer.beginDraw();
    workingBuffer.stroke( lineColor );
    workingBuffer.strokeWeight( 1 );
    PVector loc = new PVector( bookmark * cellSize + cellSize / 2, cellSize / 2 );
    for ( int c = bookmark; c < stoppingPoint; c++ )
    {
      loc.y = cellSize / 2;
      for ( int r=0; r < rows; r++ )
      {        
        workingBuffer.pushMatrix();
        workingBuffer.translate(loc.x, loc.y);
        workingBuffer.rotate(field[c][r].heading());
       
        workingBuffer.line( -8, 0, 8, 0 );
        workingBuffer.line( 3, -3, 8, 0 );
        workingBuffer.line( 3, 3, 8, 0 );
       
        workingBuffer.popMatrix();
        loc.y += cellSize;
      }
      loc.x += cellSize;
    }
    workingBuffer.endDraw();
    bookmark = stoppingPoint;
    
    if (stoppingPoint == cols)
    {
      PGraphics temp = visibleBuffer;
      visibleBuffer = workingBuffer;
      workingBuffer = temp;
      workingBuffer.beginDraw();
      workingBuffer.background( 0, 0, 0, 0 );
      workingBuffer.endDraw();
      bookmark = 0;
    }
    image(visibleBuffer, 0, 0);
  }
  
}
