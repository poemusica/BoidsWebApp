// Globals

Blob[] blobs = new Blob[ 80 ];

static float LOCAL_RANGE = 60;
static float WANDER_STRENGTH = 1;
static float ALI_STRENGTH = 1;
static float COH_STRENGTH = 1;
static float SEP_STRENGTH = 1.5;

static float SEEK_STRENGTH = COH_STRENGTH * 1.75;
static float FLEE_STRENGTH = SEP_STRENGTH * 1.75;

static float WALL_STRENGTH = 2;
static float PROX_MIN =  30;
static float PROX_MAX = 45;

// Defines Blob class
class Blob
{  
  PVector pos, vel, acc;
  float maxSpeed = 5, maxForce = 0.5;
  float wanderAngle = random( 1, 360 );
  color cstroke, cfill;
  float r; // radius of shape. can also be used as a visualizer for mass. 
  
  // Constructor
  Blob ( float x, float y ) 
  {
    pos = new PVector( x, y );
    vel = PVector.random2D(); // creates a PVector of length 1 pointing in a random direction.
    vel.setMag( 1.25 );
    acc = new PVector( 0, 0 );
    //r = random(5, 15);
    r = 8;
    
    cstroke = randomColor();
    cfill = randomColor();
  }
  
  // solid walls
  PVector checkWall()
  {
    float buffer = 25;
    int count = 0;
    PVector desired = new PVector( 0, 0 );
    if ( pos.x < buffer ) // left
    { 
      PVector dx = new PVector( maxSpeed, vel.y );
      //float m = map( buffer - pos.x, 0, buffer, 0, 1 );
      //dx.mult( m );
      desired.add( dx );
      count++;
    }
    else if ( pos.x > width - buffer ) // right
    {
      PVector dx = new PVector( -maxSpeed, vel.y );
      //float m = map( pos.x, width + buffer, width, 0, 1 );
      //dx.mult( m );
      desired.add( dx );
      count++;
    }
    if ( pos.y < buffer ) // top
    {
      PVector dy = new PVector( vel.x, maxSpeed );
      //float m = map( buffer - pos.y, 0, buffer, 0, 1 );
      //dy.mult( m );
      desired.add( dy );
      count++;
    }
    else if ( pos.y > height - buffer ) // bottom
    {
      PVector dy = new PVector( vel.x, -maxSpeed );
      //float m = map( pos.y, height + buffer, height, 0, 1 );
      //dy.mult( m );
      desired.add( dy );
      count++;
    }
    
    PVector steer = new PVector( 0, 0 );
    if ( count > 0 ) 
    { 
      desired.div( count );
      desired.limit( maxSpeed );
      steer = PVector.sub( desired, vel );
      steer.setMag( WALL_STRENGTH );
    }
      return steer;
  }
  
  // screen wrap
  void checkWrap()
  {
    float buffer = 2 * r;   
    if ( pos.x < -r ) { pos.x += width + buffer; }
    else if ( pos.x > width + r ) { pos.x -= width + buffer; }
    
    if ( pos.y < -r ) { pos.y += height + buffer; }
    else if ( pos.y > height + r ) { pos.y -= height + buffer; }
  }
    
  // Apply force to acceleration
  void applyForce( PVector force)
  {
    acc.add( force );
  }
    
  // Wandering steering.
  PVector wander()
  {
    PVector futpos = PVector.add( pos, PVector.mult( vel, 15 ) );
    PVector offset = PVector.mult( vel, 2 );
    float limit = ( 90 );
    
    wanderAngle = random( wanderAngle - limit, wanderAngle + limit );
    offset.rotate( radians( wanderAngle ) );
    
    PVector target = PVector.add( futpos, offset );
    PVector desired = PVector.sub( target, pos );
    desired.setMag( maxSpeed );
    
    PVector steer = PVector.sub( desired, vel );
    steer.limit( maxForce );
    return steer;
  }
    
  // Separation steering
  PVector separate()
  {
    int tooNear = 0;
    PVector desired = new PVector( 0 , 0 );
    for ( Blob b : blobs )
    {
      if ( b == this ) { continue; }
      
      float d = PVector.dist( pos, b.pos );
      
      if ( d < PROX_MAX )
      { 
        PVector diff = PVector.sub( pos, b.pos );
        diff.setMag( 1 / d );
        desired.add( diff );
        tooNear++;
      }  
    }
    
    PVector steer = new PVector( 0, 0 );
    if ( tooNear > 0 )
    {
      desired.div( tooNear ); 
      desired.setMag( maxSpeed );
      steer = PVector.sub( desired, vel ); 
      steer.limit( maxForce );   
    }
     return steer;
  }
  
  // Cohesion steering
  PVector cohere()
  {
    int tooFar = 0;
    PVector desired = new PVector( 0, 0 );
    for ( Blob b : blobs )
    {
      if ( b == this ) { continue; }
      
      float d = pos.dist( b.pos );
      
      if ( d < LOCAL_RANGE && d > PROX_MIN  )
      {
        PVector diff = PVector.sub( b.pos, pos );
        diff.setMag( map( d, PROX_MIN, LOCAL_RANGE, 0, 1 ) );
        desired.add( diff );
        tooFar++;
      }
     }
     
     PVector steer = new PVector( 0, 0 );
     if ( tooFar > 0 )
     {
       desired.div( tooFar );
       desired.setMag( maxSpeed );
       steer = PVector.sub( desired, vel );
       steer.limit( maxForce ); 
     }
     return steer;
  }
  
  // Alignment steering
  PVector align()
  {
    int local = 0;
    PVector desired = new PVector( 0, 0 );
    for ( Blob b : blobs )
    {
      if ( b == this ) { continue; }
      
      float d = pos.dist( b.pos );
      if ( d > LOCAL_RANGE ) { continue; }
     
      desired.add( b.vel );
      local++;
     }
     
     PVector steer = new PVector( 0, 0 );
     if ( local > 0 )
     {
       desired.div( local );
       desired.setMag( maxSpeed );
       steer = PVector.sub( desired, vel );
       steer.limit( maxForce );
     }
     return steer;       
  }
  
  // Arrival steering
  PVector arrive(PVector target )
  {
    PVector steer = new PVector( 0, 0 );
    float d = pos.dist( target );
    if ( d < LOCAL_RANGE )
    {
      PVector desired = PVector.sub( target, pos );
      float dm = desired.mag();
      if ( dm < LOCAL_RANGE / 2 )
      {
        float m = map( dm, 0, LOCAL_RANGE / 2, 0, maxSpeed );
        desired.setMag( m );
      }
      else { desired.setMag( maxSpeed ); }
      steer = PVector.sub( desired, vel );
      steer.limit( maxForce );  
    }
    return steer;
  }
    
  // Attraction steering
  PVector seek(PVector target)
  {
    PVector steer = new PVector( 0, 0 );
    float d = pos.dist( target );
    if ( d < LOCAL_RANGE )
    {
      PVector desired = PVector.sub( target, pos );
      desired.setMag( maxSpeed );
      steer = PVector.sub( desired, vel );
      steer.limit( maxForce );
    }
    return steer;
  }
  
  // Aversion steering
  PVector flee(PVector target)
  {
    PVector steer = new PVector( 0, 0 );
    float d = pos.dist( target );
    if ( d < LOCAL_RANGE )
    {
      PVector desired = PVector.sub( pos, target );
      desired.setMag( maxSpeed );
      steer = PVector.sub( desired, vel);
      steer.limit( maxForce );
    }
    return steer;
  }
  
  // Go with the flow
  PVector followFlow()
  {
    PVector desired = perlinFlow.lookup( pos );
    desired.setMag( maxSpeed );
    PVector steer = PVector.sub( desired, vel );
    steer.limit( maxForce );
    return steer;
  }
  
  // Update
  void update()
  {
    //random motion
    applyForce( PVector.mult( wander(), WANDER_STRENGTH ) );
    
    // flocking
    if ( controls.buttons[(int)controls.buttonsIndex.get("flock")].state )
    {
      applyForce( PVector.mult( cohere(), COH_STRENGTH ) );
      applyForce( PVector.mult( separate(), SEP_STRENGTH) );
      applyForce( PVector.mult( align(), ALI_STRENGTH) );
      
    }
    
    // follow flow 
    if ( controls.buttons[(int)controls.buttonsIndex.get("flow")].state )
    {
     applyForce( PVector.mult( followFlow(), 0.5 ) );
     //applyForce( PVector.mult( separate(), SEP_STRENGTH) ); 
    }
    
    // attraction
    if ( controls.buttons[(int)controls.buttonsIndex.get("attract")].state )
    {
      PVector target = new PVector( mouseX, mouseY );
      applyForce( PVector.mult( arrive( target ), SEEK_STRENGTH ) );
    }
    
    // aversion
    if ( controls.buttons[(int)controls.buttonsIndex.get("repel")].state )
    {
      PVector target = new PVector( mouseX, mouseY );
      applyForce( PVector.mult( flee( target ), FLEE_STRENGTH ) );
    }
    
    if ( controls.buttons[(int)controls.buttonsIndex.get("walls")].state )
    { applyForce( checkWall() ); }
    
    // velocity and position change
    acc.normalize();
    vel.add( acc );
    vel.limit( maxSpeed );
    pos.add( vel );
    acc.mult( 0 );
    
    // debugging
    //if ( this == blobs[ 0 ] ) { println( pos, vel, flockButton.state ); }
    
    // screen wrap
    if ( !controls.buttons[(int)controls.buttonsIndex.get("walls")].state )
    { checkWrap(); }
  }
      
  // Draw    
  void draw()
  {
    float rotation = vel.heading();
    stroke( 2 );
    stroke( cstroke );
    fill( cfill );
    
    pushMatrix();
    translate( pos.x, pos.y );
    rotate( rotation );
    
    triangle( -r, r/2, r, 0, -r, -r/2 );
    popMatrix();
    
  }
}
