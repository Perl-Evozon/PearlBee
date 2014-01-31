jQuery(document).ready(function(){

	jQuery('#portfolio').isotope({
	  // options
	  itemSelector : '.item',
	  layoutMode : 'fitRows'
	});
	jQuery('.option-set').find('a').click(function(){
		  if ( jQuery(this).hasClass('selected') ) {
			  return false;
			}
			jQuery(this).parents('.option-set').find('.selected').removeClass('selected');
		   jQuery(this).addClass('selected');
	});   
	jQuery('#filters a').click(function(){
	  var selector = jQuery(this).attr('data-filter');
	  jQuery('#portfolio').isotope({ filter: selector });
	  return false;
	});

});
