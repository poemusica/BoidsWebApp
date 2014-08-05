class Theme // threw these methods into a class for organizational purposes
{  
  Theme()
  {
  }
  
  color randomColor( int lo, int hi ) 
  {
    return color( random( lo, hi ), random( lo, hi ), random( lo, hi ) );
  }

  // first variant of perlin color. used for creature fill
  color lerpPerlinColor( float n, color t1, color t2 )
  {
    float amt = noise( red( t1 ) / 255 , n * 100 ); // tweak for web to produce variation
    amt = ( amt * 2 ) - 0.4; // tweak for web. attempt to widen and center output
    amt = constrain( amt, 0, 1 ); // keep manual adjustments in range
    return lerpColor( t1, t2, amt );
  }
  
  // second variant of perlin color. used for creature stroke
  // this method requires input color's rgb values to be constrained by offset.
  color perlinColor( int n, color t, int offset )  
  {
    // break input color into its rgb values
    float r0 = red( t );
    float g0 = green( t );
    float b0 = blue( t );
    
    float rval = noise( r0 / 255, n * 100 ); // tweaked for web to produce variation
    rval = ( rval * 2 ) - 0.4;  // tweaked for web. attempt to widen and center output
    rval = constrain( rval, 0, 1 ); // keeps manual adjustments in range
    int r1 = int( map( rval, 0, 1, -offset, offset ) );
    
    float gval = noise( g0 / 255, n * 100 );
    gval = ( gval * 2 ) - 0.4;
    gval = constrain( gval, 0, 1 );
    int g1 = int( map( gval, 0, 1, -offset, offset ) );
    
    float bval = noise( b0 / 255, n * 100 );
    bval = ( bval * 2 ) - 0.4;
    bval = constrain( bval, 0, 1 );
    int b1 = int( map( bval, 0, 1, -offset, offset ) );
    
    color c = color( r0 + r1, g0 + g1, b0 + b1, 255 ); // add perlin-generated value to base rgb values
    return c;
  }
}



