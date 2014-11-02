// Replace the classes for the google code prettefier to work

$(document).ready(function() {

	$('pre').each(function(){ 
	    var class_name = $(this).attr('class');
	    $(this).className = $(this).attr('class', class_name.replace(/brush:/,'prettyprint lang-').replace(/;$/,'')); 
  	});
	
});