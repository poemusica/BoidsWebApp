// MAIN SETUP AND DRAWING //

// Bind Javascript
interface Javascript {}
Javascript javascript = null;
void bindJavascript( Javascript js ) { javascript = js; }

// Globals
ControlPanel controls;
FlowField perlinFlow;

// Setup the Processing Canvas
void setup()
{
  size( 800, 500 );
  smooth();
  frameRate( 30 );
  
  // make blobs
  for ( int i = 0; i < blobs.length; i++ ) 
  {
    float x = random( width );
    float y = random( height );
    Blob b = new Blob( x, y );
    blobs[ i ] = b;
  }
  
  // make buttons
  controls = new ControlPanel();
  
  // make vector field
  perlinFlow = new FlowField( 25 );
}

// Main draw loop
void draw()
{
  // benchmark
  //println( frameRate );
  
  // Background is now part of perlin flow.
  //if ( !controls.buttons[5].state ) { background( 0xFF33FFCC ); }
  
  // Draw flow field vectors to off-screen buffer
  if ( controls.buttons[(int)controls.buttonsIndex.get("flow")].state )
  { 
    perlinFlow.update();
    perlinFlow.draw();
  }
    
  // If javascript is not bound, draw buttons in processing.
  // Provides one second delay for binding.
  if ( javascript == null && frameCount > 30 )
  {
    controls.update();
    controls.draw();
  }
       
  for ( Blob b : blobs )
  {
    b.update();
    b.draw();
  }

}


// MOUSE EVENTS //
void mouseClicked( MouseEvent e )
{
  for (Button b : controls.buttons)
  {
    if ( b.contains(e.getX(), e.getY()) )
    { handleClick(b.label); } 
  }
}

// UTILITIES //

// Make a random color.
color randomColor() 
{
  return color( random(255), random(255), random(255), 220 );
}
