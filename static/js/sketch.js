
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
	var canvas = $("canvas#mysketch")[0];
	var img = canvas.toDataURL("image/png");
	var myimg = $("#form-image")[0];
	myimg.src=img;

	var blackout = $('div#blackout-screen');
	blackout.show();
}

function hide_Blackout(){
    var blackout = $('div#blackout-screen');
    blackout.hide();
    return false;
}

function postdata(){
	var discoverer = $("#form-discoverer").val();
	var title = $("#form-title").val();
	var description = $("#form-description").val();
	var img = $("#form-image");
	var formData = {discoverer:discoverer, title:title, description:description}; //Array 
	$.ajax({
    url : "/postdata",
    type: "POST",
    data : formData,
    success: function(data, textStatus, jqXHR)
    {
        console.log("post success");
        hide_Blackout();
    },
    error: function (jqXHR, textStatus, errorThrown)
    {
		console.log("post fail");
    }
});
}

$(document).ready(function(){
	bindJavascript();
	hide_Blackout();
	var close_promo_link = $("a#close-promotion");
	close_promo_link.click(hide_Blackout);
});