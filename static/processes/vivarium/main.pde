// PROGRAM GLOBALS //

ArrayList<Flock> flockList;
ControlPanel controls;
FlowField perlinFlow;
Theme theme;
Texture bgTexture;  // this should eventually be a background art object.
Cursor cursor;
int trailFade; 

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
  
  theme = new Theme(); // 'import' color library
  flockList = makeFlocks( 20, 100 ); // min flock size, max total creatures.
  bgTexture = new Texture( theme.backgroundColor( flockList.get( 0 ).theme1, flockList.get( 0 ).theme2 ) ); // bg uses 1st flock's color complement
  controls = new ControlPanel(); // make native buttons
  perlinFlow = new FlowField( 25 ); // make vector field
  cursor = new Cursor();
  trailFade = int(random( 30, 200 ));
}


void draw()
{
  boolean trailVal = controls.buttons[(int)controls.buttonsIndex.get("trails")].state;
  if ( trailVal )
  {
    tint( 255, 50 );
  }
  bgTexture.draw();
  tint( 255, 255 );
  
  if ( controls.buttons[(int)controls.buttonsIndex.get("flow")].state )
  { perlinFlow.update(); perlinFlow.draw(); }
    
  if ( javascript == null && frameCount > 30 ) // display buttons in native mode  only
  { controls.update(); controls.draw(); }
  
  for ( Flock f : flockList ) { f.draw(); }
  
  if ( trailVal )
  {
    tint( 255, 60 );
  }
  cursor.draw();
  tint( 255, 255 );
  
  //println( frameRate ); // benchmark
}
