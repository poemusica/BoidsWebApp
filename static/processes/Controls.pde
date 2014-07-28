void mouseClicked( MouseEvent e )
{
  if ( javascript != null ) { return; }
  for (Button b : controls.buttons)
  {
    if ( b.contains(e.getX(), e.getY()) )
    { handleClick(b.label); } 
  }
}


class Cursor
{
  int r = 80;
  
  Cursor(){}
  
  void draw()
  {
    if ( controls.buttons[(int)controls.buttonsIndex.get("attract")].state )
    {
      fill( color( 255, 255, 255, 80 ) );
      noStroke();
      ellipse( mouseX, mouseY, r, r );
    }
    
    if ( controls.buttons[(int)controls.buttonsIndex.get("repel")].state )
    {
      fill( color( 0, 0, 0, 80 ) );
      noStroke();
      ellipse( mouseX, mouseY, r, r );
    }
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
    buttons = new Button[6];
    buttonsIndex = new HashMap<String,Integer>();
    buttons[0] = new Button( new PVector( 10 , height - 60 ), 50, 35, "flock", true );
    buttonsIndex.put( "flock", 0 );
    buttons[1] = new Button( new PVector( 70, height - 60 ), 50, 35, "flow", false );
    buttonsIndex.put( "flow", 1 );
    buttons[2] = new Button( new PVector( 130, height - 60 ), 50, 35, "walls", false );
    buttonsIndex.put( "walls", 2 );
    buttons[3] = new Button( new PVector( 190, height - 60 ), 50, 35, "attract", false );
    buttonsIndex.put( "attract", 3 );
    buttons[4] = new Button( new PVector( 250, height - 60 ), 50, 35, "repel", false );
    buttonsIndex.put( "repel", 4 );
    buttons[5] = new Button( new PVector( 310, height - 60 ), 50, 35, "trails", false );
    buttonsIndex.put( "trails", 5 );
    
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

  if (s == "attract")
  {
    b = controls.buttons[(int)controls.buttonsIndex.get("repel")];
    if ( b.state ) { b.state = false; b.swapColor(); }
  }
  
  else if (s == "repel")
  {
    b = controls.buttons[(int)controls.buttonsIndex.get("attract")];
    if ( b.state ) { b.state = false; b.swapColor(); }
  }
  
  controls.stale = true;
}
