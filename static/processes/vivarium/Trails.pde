class Trail
{
  PVector[] points; // determines where to draw each trail segment
  int[] frames; // keeps track of when each point was added to points (by frameCount)
  Creature owner;
  int segments; // determines number of trail segments
  int maxAlpha = 200; // trails should always be semi-transparent
  int maxAge;
  
  Trail( Creature k )
  {
    owner = k;
    segments = owner.myFlock.trailSegs;
    points = new PVector[ segments ]; 
    frames = new int[ segments ];
    maxAge = owner.myFlock.framesPerPoint * segments;
    
    reset();
  }
  
  void reset()
  {
    for ( int i = 0; i < segments; i++ )
    {
      points[ i ] = new PVector( owner.pos.x, owner.pos.y );
      frames[ i ] = -1000;
    }
  }
  
  void update( float x, float y )
  {
    for ( int i = segments - 1; i > 0; i-- )
    {
      points[ i ] = points[ i - 1];
      frames[ i ] = frames[ i - 1 ];
    }
    points[ 0 ] = new PVector( x, y );
    frames[ 0 ] = frameCount;
  }
  
  void translateAll( PVector v )
  {
    for ( PVector p : points )
    {
      p.add( v );
    }
  }
  
  void draw()
  {
    strokeWeight( owner.r );
    strokeCap(SQUARE);
    PVector start = points[ segments -  1 ];
    for ( int i = segments - 2; i >= 0; i-- ) // draw 4 lines using points from the points list
    {
      PVector finish = points[ i ];
      float age = frameCount - frames[ i ];
      float alpha = map( age, 0, maxAge - owner.myFlock.framesPerPoint, 200, 0 ); // make each line more transparent with age
      stroke( owner.cfill, alpha );
      line( start.x, start.y, finish.x, finish.y );
      start = finish;
    }
    
    float age = frameCount - frames[ 0 ];
    float alpha = map( age, 0, maxAge - owner.myFlock.framesPerPoint, 200, 0 ); // make more transparent with age
    stroke( owner.cfill, alpha );
    line( start.x, start.y, owner.pos.x, owner.pos.y );
  }
  
}

