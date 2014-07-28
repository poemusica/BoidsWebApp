
// bind javascript to processing instance

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

// access to processing (top-level functions only)

function toggleBorder()
{
	if ($("canvas#mysketch").css("border-width") == "0px")
	{ $("canvas#mysketch").css("border-width","5px"); }
	else { $("canvas#mysketch").css("border-width","0px"); }
}

function toggle(s)
{
	if (s == 'walls')
	{ toggleBorder(); }

	var pjs = Processing.getInstanceById("mysketch");
	pjs.handleClick(s);
}

// take a screenshot of the canvas
function saveImage()
{
	var canvas = $("canvas#mysketch")[0];
	var img = canvas.toDataURL("image/png");
	var myimg = $("#form-image")[0];
	myimg.src=img;

	var blackout = $('div#blackout-screen');
	blackout.show();
}

// close blackout screen
function hide_Blackout(){
	var blackout = $('div#blackout-screen');
	blackout.hide();
	return false;
}

// post form data to server
function postdata()
{
	var discoverer = $("#form-discoverer").val();
	var title = $("#form-title").val();
	var description = $("#form-description").val();
	var img = $("#form-image")[0].src;
	var formData = {discoverer:discoverer, title:title, description:description, image:img}; //Array 
	$.ajax
	({
		url : "/postdata",
		type: "POST",
		data : formData,
		success: function(data, textStatus, jqXHR)
		{
			console.log("post success", data); //debug line
			$("a#close-promotion").text('Close');
			$("div#promo-content").html(data);
		},
		error: function (jqXHR, textStatus, errorThrown)
		{
			console.log("post fail"); // debug line
		}
	});
}

// setup bindings
$(document).ready
(
	function()
	{
		bindJavascript();
		hide_Blackout();
		var close_promo_link = $("a#close-promotion");
		close_promo_link.click(hide_Blackout);
	}
);