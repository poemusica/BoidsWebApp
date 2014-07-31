// Bind Javascript
interface Javascript {}
Javascript javascript = null;
void bindJavascript( Javascript js ) { javascript = js; }

// MAIN SETUP AND DRAW //

void setup()
{
  doResize();
  smooth();
  frameRate( 30 );
}

void draw()
{
  background( 0 );
  fill( 255 );
  ellipse( width/2, height/2, 100, 100 );
}

function doResize()
{
    var setupHeight = Math.max($(document).height(), $(window).height());
    $('#gallerysketch').width($(window).width());
    $('#gallerysketch').height(setupHeight);

    size($(window).width(), setupHeight);
}

$(window).resize(doResize);
