class Behavior
{
  Flock flock;
  
  Behavior( Flock f )
  {
    flock = f;
  }
  
  // wander instinct
  PVector wander( Creature c )
  {
    PVector futpos = PVector.add( c.pos, PVector.mult( c.vel, c.maxSpeed * 3 ) );
    PVector offset = PVector.mult( c.vel, 2 );
    float limit = 90;
    
    c.wanderAngle = random( c.wanderAngle - limit, c.wanderAngle + limit );
    offset.rotate( radians( c.wanderAngle ) );
    
    PVector target = PVector.add( futpos, offset );
    PVector desired = PVector.sub( target, c.pos );
    desired.setMag( c.maxSpeed );
    
    PVector steer = PVector.sub( desired, c.vel );
    steer.limit( c.maxForce );
    steer.mult( flock.wanderStrength );
    return steer;
  }
    
  // separation
  PVector separate( Creature c )
  {
    int tooNear = 0;
    PVector desired = new PVector( 0 , 0 );
    for ( Creature k : flock.creatures )
    {
      if ( k == c ) { continue; }
      
      float d = PVector.dist( c.pos, k.pos );
      
      if ( d < flock.proxMax )
      { 
        PVector diff = PVector.sub( c.pos, k.pos );
        diff.setMag( 1 / d );
        desired.add( diff );
        tooNear++;
      }  
    }
    
    PVector steer = new PVector( 0, 0 );
    if ( tooNear > 0 )
    {
      desired.div( tooNear ); 
      desired.setMag( c.maxSpeed );
      steer = PVector.sub( desired, c.vel ); 
      steer.limit( c.maxForce );  
    }
     steer.mult( flock.sepStrength ); 
     return steer;
  }
  
  // cohesion
  PVector cohere( Creature c )
  {
    int tooFar = 0;
    PVector desired = new PVector( 0, 0 );
    for ( Creature k : flock.creatures )
    {
      if ( k == c ) { continue; }
      
      float d = PVector.dist(c.pos, k.pos );
      
      if ( d < flock.localRange && d > flock.proxMin  )
      {
        PVector diff = PVector.sub( k.pos, c.pos );
        diff.setMag( map( d, flock.proxMin, flock.localRange, 0, 1 ) );
        desired.add( diff );
        tooFar++;
      }
     }
     
     PVector steer = new PVector( 0, 0 );
     if ( tooFar > 0 )
     {
       desired.div( tooFar );
       desired.setMag( c.maxSpeed );
       steer = PVector.sub( desired, c.vel );
       steer.limit( c.maxForce ); 
     }
     steer.mult( flock.cohStrength ); 
     return steer;
  }
  
  // alignment
  PVector align( Creature c )
  {
    int local = 0;
    PVector desired = new PVector( 0, 0 );
    for ( Creature k : flock.creatures )
    {
      if ( k == c ) { continue; }
      
      float d = PVector.dist( c.pos, k.pos );
      if ( d > flock.localRange ) { continue; }
     
      desired.add( k.vel );
      local++;
     }
     
     PVector steer = new PVector( 0, 0 );
     if ( local > 0 )
     {
       desired.div( local );
       desired.setMag( c.maxSpeed );
       steer = PVector.sub( desired, c.vel );
       steer.limit( c.maxForce );
     }
     steer.mult( flock.aliStrength ); 
     return steer;       
  }
  
  // arrival at a target
  PVector arrive( Creature c, PVector target )
  {
    PVector steer = new PVector( 0, 0 );
    float d = PVector.dist( c.pos, target );
    if ( d < flock.localRange )
    {
      PVector desired = PVector.sub( target, c.pos );
      float dm = desired.mag();
      if ( dm < flock.localRange / 2 )
      {
        float m = map( dm, 0, flock.localRange / 2, 0, c.maxSpeed );
        desired.setMag( m );
      }
      else { desired.setMag( c.maxSpeed ); }
      steer = PVector.sub( desired, c.vel );
      steer.limit( c.maxForce );  
    }
    steer.mult( flock.seekStrength ); 
    return steer;
  }
    
  // attraction to a target
  PVector seek( Creature c, PVector target )
  {
    PVector steer = new PVector( 0, 0 );
    float d = PVector.dist( c.pos, target );
    if ( d < flock.localRange )
    {
      PVector desired = PVector.sub( target, c.pos );
      desired.setMag( c.maxSpeed );
      steer = PVector.sub( desired, c.vel );
      steer.limit( c.maxForce );
    }
    steer.mult( flock.seekStrength ); 
    return steer;
  }
  
  // aversion to a target
  PVector flee( Creature c, PVector target )
  {
    PVector steer = new PVector( 0, 0 );
    float d = PVector.dist( c.pos, target );
    if ( d < flock.localRange )
    {
      PVector desired = PVector.sub( c.pos, target );
      desired.setMag( c.maxSpeed );
      steer = PVector.sub( desired, c.vel);
      steer.limit( c.maxForce );
    }
    steer.mult( flock.fleeStrength ); 
    return steer;
  }
  
  // flow following
  PVector followFlow( Creature c )
  {
    PVector desired = perlinFlow.lookup( c.pos ); //perlinFlow is global
    desired.setMag( c.maxSpeed );
    PVector steer = PVector.sub( desired, c.vel );
    steer.limit( c.maxForce );
    steer.mult( flock.flowStrength );
    return steer;
  }
  
  // wall avoidance
  PVector checkWall( Creature c )
  {
    float buffer = 25;  // should this be a flock property?
    int count = 0;
    PVector desired = new PVector( 0, 0 );
    if ( c.pos.x < buffer ) // left
    { 
      PVector dx = new PVector( c.maxSpeed, c.vel.y );
      desired.add( dx );
      count++;
    }
    else if ( c.pos.x > width - buffer ) // right
    {
      PVector dx = new PVector( -c.maxSpeed, c.vel.y );
      desired.add( dx );
      count++;
    }
    if ( c.pos.y < buffer ) // top
    {
      PVector dy = new PVector( c.vel.x, c.maxSpeed );
      desired.add( dy );
      count++;
    }
    else if ( c.pos.y > height - buffer ) // bottom
    {
      PVector dy = new PVector( c.vel.x, -c.maxSpeed );
      desired.add( dy );
      count++;
    }
    PVector steer = new PVector( 0, 0 );
    if ( count > 0 ) 
    { 
      desired.div( count );
      desired.limit( c.maxSpeed );
      steer = PVector.sub( desired, c.vel );
      steer.setMag( flock.wallStrength );
    }
      return steer;
  }
  
}
