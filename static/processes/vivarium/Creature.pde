class Creature
{  
  Flock myFlock; // creatures have a reference to their flock
  Trail myTrail; // creatures have a reference to their trail
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
  PVector checkWrap()
  {
    PVector v = new PVector( 0, 0 );
    float buffer = 2 * r; // buffer is the size of the creature  
    if ( pos.x < -r ) // if creature is halfway off the screen
    {
      pos.x += width + buffer; // move creature to halfway on the screen on the opposite side
      v.x = width + buffer; // save movement offset so that trails are also moved
    }
    else if ( pos.x > width + r )
    {
      pos.x -= width + buffer;
      v.x = -( width + buffer );
    }
    
    if ( pos.y < -r )
    {
      pos.y += height + buffer;
      v.y = height + buffer;
    }
    else if ( pos.y > height + r )
    {
      pos.y -= height + buffer;
      v.y = -( height + buffer );
    }
    return v;
  }
  
  // update
  void update()
  {
    // wandering
    applyForce( myFlock.behavior.wander( this ) );
    
    // flocking
    if ( ( (Button)controls.buttons.get("flock") ).state )
    {
      applyForce( myFlock.behavior.cohere( this ) );
      applyForce( myFlock.behavior.separate( this ) );
      applyForce( myFlock.behavior.align( this ) );  
    }
    
    // flow following 
    if ( ( (Button)controls.buttons.get("flow") ).state )
    {
     applyForce( myFlock.behavior.followFlow( this ) );
    }
    
    // attraction
    if ( ( (Button)controls.buttons.get("attract") ).state )
    {
      PVector target = new PVector( mouseX, mouseY );
      applyForce( myFlock.behavior.arrive( this, target ) );
    }
    
    // aversion
    if ( ( (Button)controls.buttons.get("repel") ).state )
    {
      PVector target = new PVector( mouseX, mouseY );
      applyForce( myFlock.behavior.flee( this, target ) );
    }
    
    // wall avoidance
    if ( ( (Button)controls.buttons.get("walls") ).state )
    { applyForce( myFlock.behavior.checkWall( this ) ); }
  }
  
  // movement magic
  void move()
  {
    acc.normalize();
    vel.add( acc );
    vel.limit( maxSpeed );
    pos.add( vel );
    acc.mult( 0 ); // reset acceleration
    
    if ( !( (Button)controls.buttons.get("walls") ).state )
    {
      PVector v = checkWrap();
      myTrail.translateAll( v ); // move each point in trails by the same amount as pos. 
    }
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
    
    boolean trailVal = ( (Button)controls.buttons.get("trails") ).state; // logic for trail fade out
    if ( trailVal )
    {
      if ( !trailsWereOn ) // if trails were just turned on 
      {
        myTrail.reset(); // reset trail points so that trail doesn't start at last recorded creature position
        trailsWereOn = true;
      } 
      if ( frameCount % myFlock.framesPerPoint == 0 ) // update trail point list with creature pos every so often. 
      { myTrail.update( pos.x, pos.y ); }  // update point list after updating creature pos to get most recent pos. 
    }
    else { trailsWereOn = false; }
  }
  
}
