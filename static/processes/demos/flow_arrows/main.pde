// PROGRAM GLOBALS //

ControlPanel controls;
FlowField perlinFlow;
Theme theme;


// MAIN SETUP AND DRAW //

void setup()
{
  size( 800, 500 );
  smooth();
  frameRate( 30 );
  
  theme = new Theme(); // 'import' color library
  controls = new ControlPanel(); // make native buttons
  perlinFlow = new FlowField( 25 ); // make vector field
}


void draw()
{
  background( 0 );

  perlinFlow.update();
  perlinFlow.draw();
  
  controls.update();
  controls.draw();
  
  //println( frameRate ); // benchmark
}
