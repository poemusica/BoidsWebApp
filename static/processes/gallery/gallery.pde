// PROGRAM GLOBALS //

ArrayList<Flock> flockList;
FlowField perlinFlow;


// Bind Javascript
interface Javascript {}
Javascript javascript = null;
void bindJavascript( Javascript js ) { javascript = js; }


// MAIN SETUP AND DRAW //

void setup()
{
  size( 800, 500 );
  smooth();
  frameRate( 30 );
  
  flockList = makeFlocks( 20, 100 ); // min flock size, max total creatures.
  perlinFlow = new FlowField( 25 ); // make vector field
  
}

void draw()
{
  background( 0, 0, 0 );
  
  perlinFlow.update(); perlinFlow.draw();
    
  for ( Flock f : flockList ) { f.draw(); }

}

// FLOCK DEFINITIONS //

class Flock
{
  Creature[] creatures;
  int size, trailDelay, trailFade;
  Behavior behavior;
  
  PGraphics pg1, pg2;
  
  float localRange = 60;
  float wanderStrength = 1;
  float aliStrength = 1;
  float cohStrength = 1;
  float sepStrength = 1.5;
  
  float seekStrength = cohStrength * 1.75;
  float fleeStrength = sepStrength * 1.75;
  
  float wallStrength = 2;
  float flowStrength = 0.5;
  float proxMin =  30;
  float proxMax = 45;
  
  Flock( int n )
  {
    size = n;
    creatures = new Creature[ size ];    
    behavior = new Behavior( this );
    
    pg1 = createGraphics( width, height );
    pg2 = createGraphics( width, height );
    pg2.beginDraw(); pg2.endDraw();
    trailDelay = int( random( 1, 3 ) );
    trailFade = int( random( 150, 245 ) );
    
    for ( int i = 0; i < size; i++ ) 
    {
      float x = random( width );
      float y = random( height );
      
      color fillColor = color( 255, 255, 255 );
      color strokeColor = color( 255, 255, 255 );
      
      Creature k = new Creature( x, y, fillColor, strokeColor, this );
      creatures[ i ] = k;
    }    
  }
  
  void contrailsOn()
  {
    pg2.beginDraw();
    pg2.background( 0, 0, 0, 0 ); // clear
    pg2.tint( 255, trailFade );
    pg2.image( pg1.get(), 0, 0 ); 
    pg2.endDraw();
  }
  
  void contrailsOff()
  {
    pg1.beginDraw();
    pg1.background( 0, 0, 0, 0 );
    pg1.image( pg2.get(), 0, 0 );
    pg1.endDraw();
    
    pg2.beginDraw();
    pg2.background( 0, 0, 0, 0 );
    pg2.tint( 255, trailFade );
    pg2.image( pg1, 0, 0 );
    pg2.endDraw();
  }
  
  void draw()
  {
    if ( true && ( frameCount % trailDelay == 0 ) )
    {
      contrailsOn();
    }
    else if ( !true && frameCount % trailDelay == 0 ) // frameCount check makes trails disappear more slowly
    {
      contrailsOff();
    }
    
    pg1.beginDraw();
    pg1.background( 0, 0, 0, 0 );
    pg1.image( pg2, 0, 0 );
    pg1.tint( 255, 255 );
    for ( Creature k : creatures )
    {
      k.update();
      k.move();
      k.draw( pg1 );
    }
    pg1.endDraw();
    
    image( pg1, 0, 0 );
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

    
    // flow following 

    // applyForce( myFlock.behavior.followFlow( this ) );

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
      
  // draw    
  void draw( PGraphics pg )
  {
    float rotation = vel.heading();
    pg.stroke( 2 );
    pg.stroke( cstroke );
    pg.fill( cfill );
    
    pg.pushMatrix();
    pg.translate( pos.x, pos.y );
    pg.rotate( rotation );
    
    pg.triangle( -r, r/2, r, 0, -r, -r/2 );
    pg.popMatrix();
    
  }
}

// FLOW FIELD DEFINITIONS //
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
  
}
