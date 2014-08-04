class Creature
{  
  Flock myFlock;
  Trail myTrail;
  PVector pos, vel, acc;
  float wanderAngle;
  color cstroke, cfill;
  float r; // radius of shape.
  float maxSpeed = 5, maxForce = 0.5;
  boolean trailsWereOn = false; // value of trails button state at last frame. initialized to false since trails start turned off.
  
  Creature ( float x, float y, color fc, color sc, Flock f ) 
  {
    myFlock = f;
    pos = new PVector( x, y );
    myTrail = new Trail( this ); // Trail constructor relies on pos
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
    if ( pos.x < -r )
    {
      pos.x += width + buffer;
      myTrail.translateAll( new PVector( width + buffer, 0 ) ); // translate trails according to new creature pos
    }
    else if ( pos.x > width + r )
    {
      pos.x -= width + buffer;
      myTrail.translateAll( new PVector( -( width + buffer ), 0 ) );
    }
    
    if ( pos.y < -r )
    {
      pos.y += height + buffer;
      myTrail.translateAll( new PVector( 0, height + buffer ) );
    }
    else if ( pos.y > height + r )
    {
      pos.y -= height + buffer;
      myTrail.translateAll( new PVector( 0, -( height + buffer ) ) );
    }
  }
  
  // update
  void update()
  {
    // wandering
    applyForce( myFlock.behavior.wander( this ) );
    
    // flocking
    if ( controls.buttons[(int)controls.buttonsIndex.get("flock")].state )
    {
      applyForce( myFlock.behavior.cohere( this ) );
      applyForce( myFlock.behavior.separate( this ) );
      applyForce( myFlock.behavior.align( this ) );  
    }
    
    // flow following 
    if ( controls.buttons[(int)controls.buttonsIndex.get("flow")].state )
    {
     applyForce( myFlock.behavior.followFlow( this ) );
    }
    
    // attraction
    if ( controls.buttons[(int)controls.buttonsIndex.get("attract")].state )
    {
      PVector target = new PVector( mouseX, mouseY );
      applyForce( myFlock.behavior.arrive( this, target ) );
    }
    
    // aversion
    if ( controls.buttons[(int)controls.buttonsIndex.get("repel")].state )
    {
      PVector target = new PVector( mouseX, mouseY );
      applyForce( myFlock.behavior.flee( this, target ) );
    }
    
    // wall avoidance
    if ( controls.buttons[(int)controls.buttonsIndex.get("walls")].state )
    { applyForce( myFlock.behavior.checkWall( this ) ); }
  }
  
  // movement magic
  void move()
  {
    acc.normalize();
    vel.add( acc );
    vel.limit( maxSpeed );
    pos.add( vel );
    acc.mult( 0 );
    
    if ( !controls.buttons[(int)controls.buttonsIndex.get("walls")].state )
    { checkWrap(); }
  }
      
  // draw    
  void draw()
  {    
    float rotation = vel.heading();
    
    myTrail.draw(); // draw trail first so that it doesn't cover creature

    strokeWeight( 2 );
    stroke( cstroke );
    fill( cfill );
    
    pushMatrix();
    translate( pos.x, pos.y );
    rotate( rotation );    
    triangle( -r, r/2, r, 0, -r, -r/2 ); // draw creature
    popMatrix();
    
    boolean trailVal = controls.buttons[(int)controls.buttonsIndex.get("trails")].state; // logic for trail fade out
    if ( trailVal )
    {
      if ( !trailsWereOn ) 
      {
        myTrail.reset();
        trailsWereOn = true;
      } 
      if ( frameCount % myFlock.framesPerPoint == 0 ) // update trail point list with creature pos every so often. 
      { myTrail.update( pos.x, pos.y ); }  // update point list after updating creature pos to get most recent pos. 
    }
    else { trailsWereOn = false; }
  }
  
}
