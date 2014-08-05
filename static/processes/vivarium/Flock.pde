class Flock
{
  Creature[] creatures;
  int size; // determines number of creature. "size" of flock.
  int framesPerPoint, trailSegs; // determines trail length
  Behavior behavior;
  
  color theme1, theme2, ptheme;
  
  // these variables are all tuned to a specific emergent formation. very touchy.
  float localRange = 60; // creatures are only responsive to other creatures in their local range.
  float wanderStrength = 1;
  float aliStrength = 1;
  float cohStrength = 1;
  float sepStrength = 1.5;
  
  float seekStrength = cohStrength * 1.75;
  float fleeStrength = sepStrength * 1.75;
  
  float wallStrength = 2;
  float flowStrength = 0.5;
  float proxMin =  30; // don't be closer than 30 pixels away
  float proxMax = 45; // don't be farther than 45 pixels away
  
  Flock( int n )
  {
    size = n; // determines number of creature. "size" of flock.
    creatures = new Creature[ size ];    
    behavior = new Behavior( this ); // flocks have behaviors
    
    framesPerPoint = int( random( 2, 4 ) ); // how often creatures records their positions. inputs are tuned, but somewhat arbitrary
    trailSegs = int( random( 3, 10) ); // how many segments make up creatures' trails
   
    theme1 = theme.randomColor( 0, 255 );
    theme2 = theme.randomColor( 0, 255 );
    ptheme = theme.randomColor( 75, 255 - 75 );
    
    for ( int i = 0; i < size; i++ ) 
    {
      float x = random( width );
      float y = random( height );
      
      color fillColor = theme.lerpPerlinColor( i, theme1, theme2 );
      color strokeColor = theme.perlinColor( i, ptheme, 75 );
      
      Creature k = new Creature( x, y, fillColor, strokeColor, this );
      creatures[ i ] = k;
    }    
  }
    
  void draw()
  {
    for ( Creature k : creatures )
    {
      k.update();
      k.move();
      k.draw();
    }
  }
  
}

// creates multiple flocks
ArrayList<Flock> makeFlocks( int lo, int hi ) // args: min creatures per flock, max number of creatures on screen
{
  ArrayList<Flock> flocks;
 flocks = new ArrayList<Flock>(); 
  int i = hi;
  while ( i >= lo )
  {
    int num = int( ( random( lo, i ) ) );
    Flock f = new Flock( num );
    flocks.add( f );
    i -= num;
  }
  return flocks;
}
