void mouseClicked( MouseEvent e ) // deal with clicks in native mode
{
  if ( javascript != null ) { return; } // don't worry about native buttons unless javascript isn't bound
  
  Iterator i = controls.buttons.entrySet().iterator();  // Get an iterator 
  while ( i.hasNext() )
  {
    Map.Entry me = ( Map.Entry )i.next();
    Button b = (Button)me.getValue();
    if ( b.contains( e.getX(), e.getY() )) 
    { handleClick( b.label ); }
  }

}

void mouseMoved()
{
  cursor.mX = mouseX;
  cursor.mY = mouseY;
}

class Cursor
{
  int r = 80;
  float mX;
  float mY;
  
  Cursor(){}
  
  void reset() // move mouse shape offscreen
  { mX = -r * 3; mY = -r * 3; }
  
  void draw()
  {
    if ( ( (Button)controls.buttons.get("attract") ).state )
    {
      fill( color( 255, 255, 255, 80 ) );
      noStroke();
    }
    else if ( ( (Button)controls.buttons.get("repel") ).state )
    {
      fill( color( 0, 0, 0, 80 ) );
      noStroke();
    }
    else
    { reset(); }
    
    // prevents mouse from getting stuck at edges when user moves mouse out of bounds
    if ( mouseX < 2 || mouseY < 2 || mouseX > width - 2 || mouseY > height -2  )
    { reset(); } // if mouse gets close to edge of screen, move it off screen.
    
    ellipse( mX, mY, r, r ); 
  }
  
}

// dev buttons for native mode
class ControlPanel
{
  HashMap buttons;
  PGraphics pg;
  boolean stale;
  
  ControlPanel()
  {    
    buttons = new HashMap();
  
    buttons.put("flock", new Button( new PVector( 10 , height - 60 ), 50, 35, "flock", true ));
    buttons.put("flow", new Button( new PVector( 70, height - 60 ), 50, 35, "flow", false ));
    buttons.put("walls", new Button( new PVector( 130, height - 60 ), 50, 35, "walls", false ));
    buttons.put("attract", new Button( new PVector( 190, height - 60 ), 50, 35, "attract", false ));
    buttons.put("repel", new Button( new PVector( 250, height - 60 ), 50, 35, "repel", false ));
    buttons.put("trails", new Button( new PVector( 310, height - 60 ), 50, 35, "trails", false ));
       
    // fill buffer
    pg = createGraphics( width, height );
    stale = true; // has a button state been changed? do i need to update/refresh buffer?
  }
 
 void fillBuffer()
 {
   pg.beginDraw();
   pg.background( 0, 0, 0, 0 );
   
   Iterator i = buttons.entrySet().iterator();  // Get an iterator 
   while ( i.hasNext() )
   {
    Map.Entry me = ( Map.Entry )i.next();
    Button b = (Button)me.getValue();
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
  Button b = (Button)controls.buttons.get(s);
  b.state = !b.state;
  b.swapColor(); // this line is only relevant in native mode.

  // make sure attract and repel are mutually exclusive
  if (s == "attract")
  {
    b = (Button)controls.buttons.get("repel");
    if ( b.state ) { b.state = false; b.swapColor(); cursor.reset(); }
  }
  
  else if (s == "repel")
  {
    b = (Button)controls.buttons.get("attract");
    if ( b.state ) { b.state = false; b.swapColor(); cursor.reset(); }
  }
  
  controls.stale = true; // the state of a button changed, so it needs to be redrawn
}
