// PROGRAM GLOBALS //

ArrayList<Flock> flockList;
ControlPanel controls;
FlowField perlinFlow;
Theme theme;
Texture bgTexture;  // this should eventually be a background art object.
Cursor cursor;

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
}


void draw()
{
  bgTexture.draw();
  
  if ( controls.buttons[(int)controls.buttonsIndex.get("flow")].state )
  { perlinFlow.update(); perlinFlow.draw(); }
    
  if ( javascript == null && frameCount > 30 ) // display buttons in native mode  only
  { controls.update(); controls.draw(); }
  
  for ( Flock f : flockList ) { f.draw(); }
  
  cursor.draw();
  
  //println( frameRate ); // benchmark
}


