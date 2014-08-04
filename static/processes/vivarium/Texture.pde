class Texture
{
  PImage pimage;
  color base, lo, hi;
  int numBuckets = 20; // determines the granularity of color variation in the background texture
  int bucketSize = 1 / numBuckets;
  int perlinZoom; // lower is zoomed out with many features, higher is zoomed in with fewer features.
  
  Texture()
  {
    pimage = createImage( width, height, RGB );
    base = color( random( 0, 255 ), random( 0, 255 ), random( 0, 255 ) );
    lo = lerpColor( base, color( 0 ), 0.5 );
    hi = lerpColor( base, color( 255 ), 0.75 ); // biased toward lighter colors
    perlinZoom = 1000; // 1000x zoom
    
    for ( int x = 0; x < width; x++ )
    {
      for ( int y = 0; y < height; y++ )
      {
        color pixelColor = perlinPixel( float( x ) / perlinZoom, float( y ) / perlinZoom );
        pimage.pixels[ ( y * width ) + x ] =  pixelColor; // pixels are a list. y * width gets you into desired row. + x gets you to desired column.
      }
    }
  }
  
  color perlinPixel( float x, float y )
  {
    float noiseVal = noise( x, y );
    int bucket = int ( map( noiseVal, 0, 1, 0, numBuckets ) ); // determines which color-bucket to use
    return lerpColor( lo, hi, bucket  * bucketSize );
  }
  
  void draw()
  {
    image( pimage, 0, 0 );
  }
}
