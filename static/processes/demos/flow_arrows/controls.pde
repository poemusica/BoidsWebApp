void mouseClicked( MouseEvent e )
{
  //if ( javascript != null ) { return; }
  for (Button b : controls.buttons)
  {
    if ( b.contains(e.getX(), e.getY()) )
    { handleClick(b.label); } 
  }
}


class ControlPanel
{
  Button[] buttons;
  HashMap<String,Integer> buttonsIndex;
  PGraphics pg;
  boolean stale;
  
  ControlPanel()
  {
    buttons = new Button[1];
    buttonsIndex = new HashMap<String,Integer>();
    buttons[0] = new Button( new PVector( 10 , height - 60 ), 50, 35, "flow", true );
    buttonsIndex.put( "flow", 0 );
    
    // fill buffer
    pg = createGraphics( width, height );
    stale = true;
  }
 
 void fillBuffer()
 {
   pg.beginDraw();
   pg.background( 0, 0, 0, 0 );
   for ( Button b : buttons )
   {
     b.draw( pg );
   }
   pg.endDraw();
   stale = false;
 }
 
 void update()
 { 
   if ( stale ) { fillBuffer(); }
 }
 
 void draw()
 { image( pg, 0, 0 ); }
  
}


// Defines Button class
class Button
{
  float bwidth, bheight;
  PVector pos;
  color cstroke, cfill;
  String label;
  boolean state;
  
  Button ( PVector p, float w, float h, String l, boolean s)
  {
    bwidth = w;
    bheight = h;
    pos = p;
    label = l;
    state = s;
    cstroke = theme.randomColor( 0, 255 );
    cfill = theme.randomColor( 0, 255 );
  }
  
  boolean contains( int x, int y )
  { return pos.x < x && x < pos.x + bwidth && pos.y < y && y < pos.y + bheight; }
  
  void draw( PGraphics pg ) 
  {
    pg.strokeWeight( 3 );
    pg.stroke( cstroke );
    pg.fill( cfill );
    pg.rect( pos.x, pos.y, bwidth, bheight, 10 );
    pg.textSize( 12 );
    pg.fill( 0,0,0 );
    pg.text( label, pos.x + 5, pos.y + bheight/2 + 4 );
  }
  
  void swapColor()
  {
    color f = cfill;
    cfill = cstroke;
    cstroke = f;
  }
}


// Javascript Helper (must be top-level functions)
void handleClick(String s)
{
  Button b = controls.buttons[(int)controls.buttonsIndex.get(s)];
  b.state = !b.state;
  b.swapColor();
  
  controls.stale = true;
}
