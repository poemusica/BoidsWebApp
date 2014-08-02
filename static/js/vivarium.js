
// bind javascript to processing instance

function bindJavascript()
{
	var pjs = Processing.getInstanceById("main-sketch");
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
	if ($("canvas#main-sketch").css("border-width") == "0px")
	{ $("canvas#main-sketch").css("border-width","7px"); }
	else { $("canvas#main-sketch").css("border-width","0px"); }
}

function toggle(s)
{
	if (s == 'walls')
	{ toggleBorder(); }

	var pjs = Processing.getInstanceById("main-sketch");
	pjs.handleClick(s);
}

// take a screenshot of the canvas
function saveImage()
{
	var canvas = $("canvas#main-sketch")[0];
	var img = canvas.toDataURL("image/jpg");

	$.ajax
	({
		url : "/getform",
		type: "GET",
		data : "form please",
		success: function(data, textStatus, jqXHR)
		{
			console.log("get success", data); //debug line
			$("div#form-content").html(data);
			var myimg = $("#form-image")[0];
			myimg.src=img;
			$("a#post-data-btn").show();
			$('.hidden-form').modal('show');				
		},
		error: function (jqXHR, textStatus, errorThrown)
		{
			console.log("get fail"); // debug line
		}
	});	
}

// close form
function hide_form(){
	$('.hidden-form').modal('hide');
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
			$("a#close-form").text('close');
			$("a#post-data-btn").hide();
			$("div#form-content").html(data);
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
		
		hide_form();

		var close_form_link = $("a#close-form");
		close_form_link.click(hide_form);

		var post_data_btn = $("a#post-data-btn");
		post_data_btn.click(postdata);

		var save_data_link = $("a#save-image-btn");
		save_data_link.on('click', saveImage);
	}
);