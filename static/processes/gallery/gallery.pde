// PROGRAM GLOBALS //

ArrayList<Flock> flockList;


// Bind Javascript
interface Javascript {}
Javascript javascript = null;
void bindJavascript( Javascript js ) { javascript = js; }


// MAIN SETUP AND DRAW //

void setup()
{
  doResize();
  smooth();
  frameRate( 15 );
  background(250);
  
  flockList = makeFlocks( 80, 80 ); // min flock size, max total creatures.
}

void draw()
{
  //background( 255, 255, 255 );
  if ( flockList != null )
  {
    for ( Flock f : flockList ) { f.draw(); }
  }

}

// JS RESIZE TO BROWSER //
function doResize()
{
    var setupHeight = Math.max($(document).height(), $(window).height());
    size($(window).width(), setupHeight);
}
$(window).resize(doResize);


// FLOCK DEFINITIONS //

class Flock
{
  Creature[] creatures;
  int size, trailDelay, trailFade;
  Behavior behavior;
    
  float localRange = 60;
  float wanderStrength = 1;
  float aliStrength = 1;
  float cohStrength = 1;
  float sepStrength = 1.5;
  
  float seekStrength = cohStrength * 1.75;
  float fleeStrength = sepStrength * 1.75;
  
  float wallStrength = 2;
  float proxMin =  30;
  float proxMax = 45;
  
  Flock( int n )
  {
    size = n;
    creatures = new Creature[ size ];    
    behavior = new Behavior( this );
    
    for ( int i = 0; i < size; i++ ) 
    {
      float x = random( width );
      float y = random( height );
      
      color fillColor = color( 200, 200, 200 );
      color strokeColor = color( 155, 155, 155 );
      
      Creature k = new Creature( x, y, fillColor, strokeColor, this );
      creatures[ i ] = k;
    }    
  }
  
  void draw()
  {
    fill( 250, 55 );
    rect( 0, 0, width, height );
    for ( Creature k : creatures )
    {
      k.update();
      k.move();
      k.draw();
    }
  }
  
}


ArrayList<Flock> makeFlocks( int lo, int hi )
{
  ArrayList<Flock> flocks;
 flocks = new ArrayList<Flock>(); 
  int i = hi;
  while ( i >= lo )
  {
    int num = int( random( lo, i ) );
    Flock f = new Flock( num );
    flocks.add( f );
    i -= num;
  }
  return flocks;
}

// CREATURE DEFINITIONS //

class Creature
{  
  Flock myFlock;
  PVector pos, vel, acc;
  float wanderAngle;
  color cstroke, cfill;
  float r; // radius of shape.
  float maxSpeed = 5, maxForce = 0.5;
  
  Creature ( float x, float y, color fc, color sc, Flock f ) 
  {
    myFlock = f;
    pos = new PVector( x, y );
    vel = PVector.random2D(); // PVector of length 1 pointing in a random direction.
    vel.setMag( 1.25 );
    acc = new PVector( 0, 0 );
    wanderAngle = random( 1, 360 );
    cstroke = sc;
    cfill = fc;
    r = 8; // or random size.
  }

  // apply force to acceleration
  void applyForce( PVector force)
  {
    acc.add( force );
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
  
  // update
  void update()
  {
    // wandering
    applyForce( myFlock.behavior.wander( this ) );
    
    // flocking

      applyForce( myFlock.behavior.cohere( this ) );
      applyForce( myFlock.behavior.separate( this ) );
      applyForce( myFlock.behavior.align( this ) );  

  }
  
  // movement magic
  void move()
  {
    acc.normalize();
    vel.add( acc );
    vel.limit( maxSpeed );
    pos.add( vel );
    acc.mult( 0 );
    
    checkWrap();
  }
      
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

// BEHAVIOR DEFINITIONS //

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
}
