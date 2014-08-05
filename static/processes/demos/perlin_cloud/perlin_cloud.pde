class Texture
{
  PImage pimage;
  color base;
  int offset;
  float perlinZoom;
  
  Texture( color c )
  {
    pimage = createImage( width, height, RGB );
    base = c;
    offset = 75;
    perlinZoom = 100;
    
    
    for ( int x = 0; x < width; x++ )
    {
      for ( int y = 0; y < height; y++ )
      {
        color pixelColor = perlinPixel( float( x ) / perlinZoom, float( y ) / perlinZoom ); // 
        pimage.pixels[ y * width + x ] =  pixelColor;
      }
    }
  }
  
  color perlinPixel( float x, float y )
  {
    float noiseval = noise( x, y );
    
    int r1 = int( map( noiseval, 0, 1, -offset, offset ) );
    int g1 = int( map( noiseval, 0, 1, -offset, offset ) );
    int b1 = int( map( noiseval, 0, 1, -offset, offset ) );
    
    color c = color( red( base ) + r1, green( base ) + g1, blue( base ) + b1 );
    return c;
  }
  
  void draw()
  {
    image( pimage, 0, 0 );
  }
}
