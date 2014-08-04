class Particle
{
  PVector pos;
  PVector vel;
  int size;
  Debris myDebris;
  float mySpeed;
  
  Particle( Debris d ) 
  {
    myDebris = d;
    size = int( random( 4, myDebris.maxSize ) );
    mySpeed = myDebris.speed / size;
    pos = new PVector( random( 0, width ), random( 0, height ) );
    vel = PVector.mult( PVector.random2D(), mySpeed );
  }
  
  void checkWrap()
  {
    float buffer = 2 * size;   
    if ( pos.x < -size )
    { pos.x += width + buffer; }
    else if ( pos.x > width + size )
    { pos.x -= width + buffer; }
    
    if ( pos.y < -size )
    { pos.y += height + buffer; }
    else if ( pos.y > height + size )
    { pos.y -= height + buffer; }
  }
  
  void update()
  {
    PVector inertia = PVector.mult( vel, 0.5 ); // damped and scaled verson of current vel
    PVector drift = PVector.mult( PVector.random2D(), 0.5 ); // prevents particles of similar size from clumping
    PVector flowForce = perlinFlow.lookup( pos );
    
    vel = inertia;
    vel.add( drift );
    vel.add( flowForce );
    vel.setMag( mySpeed );
    pos.add( vel );
    
    checkWrap();
  }
  
  void draw()
  {
    fill( 255, 15 );
    noStroke();
    ellipse( pos.x, pos.y, size, size );
  }
}

class Debris
{
  Particle[] particles;
  int n, maxSize; // number of particles, max size of particles
  int speed = 20;
  
  Debris( int num )
  {
    n = num;
    maxSize = int( random( 4, 100 ) );
    particles = new Particle[ n ];
    for ( int i = 0; i < n; i++ )
    {
      particles[ i ] = new Particle( this );
    }
  }
  
  void draw()
  {
    for ( Particle p : particles )
    {
      p.update();
      p.draw();
    }
  }
  
}
