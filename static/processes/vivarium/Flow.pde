class FlowField
{
  int cellSize;
  int cols, rows;
  PVector [][] field; // 2D array
  float fieldBias; // helps make directional changes more random
  float zoff = 0; // represents time

  FlowField( int csize )
  {
    cellSize = csize;
    fieldBias = random( 1, 360 );
    cols = width / cellSize; // width should be evenly divisible by cellSize
    rows = height / cellSize; // height should be evenly divisible by cellSize
    field = new PVector [ cols ] [ rows ];
    reCompute();
  }
  
  void reCompute()
  {
    float xoff = 0;
    for ( int c = 0; c < cols; c++ ) // loop through cols and rows of perlin grid
    {
      float yoff = 0;
      for ( int r = 0; r < rows; r++ )
      { 
        float angle = map( noise( xoff, yoff, zoff ), 0, 1, 0, TWO_PI ); // convert noise val to angle
        angle += radians( fieldBias ); // add fieldBias for directional shift. 
        PVector v = new PVector( 1, 0 ); // unit vector with angle 0
        v.rotate( angle );
        field[ c ][ r ] = v; 
        yoff += 0.1;
      }
      xoff += 0.1;
    }
    zoff += 0.1;
    fieldBias += random( -15, 15 ); // makes gradual directional change possible
  }
 
  PVector lookup( PVector loc )
  {
    int column = int( constrain( loc.x / cellSize, 0, cols - 1 ) ); // ensures that objects in buffer zone don't cause issues
    int row = int( constrain( loc.y / cellSize, 0, rows -1) );
    return field[column][row].get();
  }
 
  void update()
  {
    if ( frameCount % 10 == 0 ) { reCompute(); }
  }
  
}
