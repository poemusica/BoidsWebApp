// LIBRARIES //
import java.util.Iterator;
import java.util.Map;

// PROGRAM GLOBALS //

ArrayList<Flock> flockList; // has flocks and flocks have creatures
ControlPanel controls; // has buttons
FlowField perlinFlow;
Theme theme; // color 'library'
Texture bgTexture;  // background art
Cursor cursor;
Debris debris; // has particles

// Bind Javascript.
// Lets processing determine whether it is running natively or in js. (for dev buttons) 
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
  flockList = makeFlocks( 10, 150 ); // args: min flock size, max total creatures.
  bgTexture = new Texture();
  controls = new ControlPanel(); // make dev buttons
  perlinFlow = new FlowField( 25 );
  cursor = new Cursor();
  debris = new Debris( 100 ); // arg: number of particles
  
}


void draw()
{
  bgTexture.draw();
  
  if ( ( (Button)controls.buttons.get("flow") ).state )
  { perlinFlow.update(); }
    
  if ( javascript == null && frameCount > 30 ) // display buttons in native mode  only
  { controls.update(); controls.draw(); }
  
  for ( Flock f : flockList ) { f.draw(); }
  
  debris.draw();
  
  cursor.draw();
  
  //println( frameRate ); // benchmark
}
