class Theme
{  
  Theme()
  {
  }
  
  color backgroundColor( color t1, color t2 )
  {
    color t = lerpColor( t1, t2, 0.5 );
    return color( 255 - red( t ), 255 - green( t ), 255 - blue( t ), 255 );
  }
  
  color randomColor( int lo, int hi ) 
  {
    return color( random( lo, hi ), random( lo, hi ), random( lo, hi ) );
  }
  
  color lerpPerlinColor( float n, color t1, color t2 ) // first variant of perlin color
  {
    float amt = noise( red( t1 ), n );
    return lerpColor( t1, t2, amt );
  }
  
  color perlinColor( int n, color t, int offset ) // second variant of perlin color 
  {
    float r0 = red( t );
    float g0 = green( t );
    float b0 = blue( t );
    float rval = noise( r0, n );
    int r1 = int( map( rval, 0, 1, -offset, offset ) );
    float gval = noise( g0, n );
    int g1 = int( map( gval, 0, 1, -offset, offset ) );
    float bval = noise( b0, n );
    int b1 = int( map( bval, 0, 1, -offset, offset ) );
    color c = color( r0 + r1, g0 + g1, b0 + b1, 255 );
    return c;
  }
}



