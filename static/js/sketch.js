
// Bind javascript to processing instance

function bindJavascript()
{
	var pjs = Processing.getInstanceById("mysketch");
	if (pjs)
	{
		try { pjs.bindJavascript(this); }
		catch(e) { console.log(e); }
	}
	else setTimeout(bindJavascript, 250);
}

// Access to processing (top-level functions only)

function toggle(s)
{
	var pjs = Processing.getInstanceById("mysketch");
	pjs.handleClick(s);
}

// Take a screenshot of the canvas.
function saveImage()
{
	var canvas = document.getElementById("mysketch");
	var img = canvas.toDataURL("image/png");
	var myimg = document.getElementById("myimage");
	myimg.src=img;

	var blackout = $('div#blackout-screen');
	blackout.show();
}

function hide_Blackout(){
    var blackout = $('div#blackout-screen');
    blackout.hide();
    return false;
}

$(document).ready(function(){
	bindJavascript();
	hide_Blackout();
	var close_promo_link = $("a#close-promotion");
	close_promo_link.click(hide_Blackout);
});