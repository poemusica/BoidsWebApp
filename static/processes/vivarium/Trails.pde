class Trail
{
  PVector[] points; // determines where to draw each trail segment
  int[] frames; // keeps track of when each point was added to points array (by frameCount)
  Creature owner;
  int segments; // determines number of trail segments
  int maxAlpha = 200; // lines start at maxAlpha and become more transparent over time.
  int maxAge; // determines alpha and how long to keep a point in the points array
  
  Trail( Creature k )
  {
    owner = k;
    segments = owner.myFlock.trailSegs; // creatures of same flock have same trail length
    points = new PVector[ segments ]; 
    frames = new int[ segments ];
    maxAge = owner.myFlock.framesPerPoint * ( segments  - 1 );
    
    reset(); 
  }
  
  void reset() // initialize points and frames arrays to avoid null pointer errors
  {
    for (  int i = 0; i < segments; i++ )
    {
      points[ i ] = new PVector( owner.pos.x, owner.pos.y );
      frames[ i ] = -1000;
    }
  }
  
  void update( float x, float y )
  {
    for ( int i = segments - 1; i > 0; i-- ) // start at the end of the arrays
    {
      points[ i ] = points[ i - 1 ]; // shift elements of points array back one
      frames[ i ] = frames[ i - 1 ]; // shift elements of frames array back one
    }
    points[ 0 ] = new PVector( x, y ); // add new point to beginning of points array
    frames[ 0 ] = frameCount; // add corresponding frameCount to beginning of frames array
  }
  
  // makes sure that trails wrap when owner wraps
  void translateAll( PVector v ) // arg: amount that owner's position was moved for screen wrap 
  {
    for ( PVector p : points )
    {
      p.add( v ); // move each point by the same amount. 
    }
  }
  
  void draw()
  {
    strokeWeight( owner.r );
    strokeCap(SQUARE);
    PVector start = points[ segments -  1 ]; // start from the end of the array and work forward
    for ( int i = segments - 2; i >= 0; i-- ) // draw 4 lines using points from the points array
    {
      PVector finish = points[ i ];
      float age = frameCount - frames[ i ];
      float alpha = map( age, 0, maxAge, maxAlpha, 0 ); // lines become more transparent with age
      stroke( owner.cfill, alpha );
      line( start.x, start.y, finish.x, finish.y );
      start = finish;
    }
    
    float age = frameCount - frames[ 0 ];
    float alpha = map( age, 0, maxAge, maxAlpha, 0 ); // make more transparent with age
    stroke( owner.cfill, alpha );
    line( start.x, start.y, owner.pos.x, owner.pos.y );
  }
  
}

