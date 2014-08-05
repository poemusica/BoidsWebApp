// PROGRAM GLOBALS //

Theme theme;
Texture bgTexture;  // this should eventually be a background art object.
color theme1, theme2;

// MAIN SETUP AND DRAW //

void setup()
{
  size( 800, 500 );
  smooth();
  frameRate( 30 );
  
  theme = new Theme(); // 'import' color library
  theme1 = theme.randomColor( 0, 255 );
  theme2 = theme.randomColor( 0, 255 );
  bgTexture = new Texture( theme.backgroundColor( theme1, theme2 ) ); // bg uses 1st flock's color complement
}


void draw()
{
  bgTexture.draw();
  //println( frameRate ); // benchmark
}
