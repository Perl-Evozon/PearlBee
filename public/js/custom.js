!(function ($) {

	$(document).ready(function () {
		/*
		Dropdown
		=========================== */
		$('ul li.dropdown').hover(function () {
				$(this).find('.dropdown-menu').stop(true, true).delay(200).fadeIn();
			}, function () {
				$(this).find('.dropdown-menu').stop(true, true).delay(200).fadeOut();
		});
		 
		/* Browse menu
		=========================== */	
		$("#browse-menu").hide();

			$('.open-menu a').click(function(){
				$("#browse-menu").slideToggle();
				return false; 
			});
			
		/*
		Bounce animated
		=========================== */	
		$(".e_bounce").hover(
			function () {
			$(this).addClass("animated bounce");
			},
			function () {
			$(this).removeClass("animated bounce");
			}
		);
		
		/*
		image hover
		=========================== */	
		$(".zoom, .image-title").css({'opacity':'0','filter':'alpha(opacity=0)'});
	   jQuery('.image-wrapper').mouseenter(function(e) {
		    jQuery(this).children('.image-caption').show().css('opacity', '1').stop().animate({top: '0', opacity : '1'}, 600);
			jQuery(this).children('.image-title').stop().animate({top: '0', opacity : '1'}, 600);
			jQuery(this).children('.zoom').show().css('opacity', '0').stop().animate({opacity : '1'}, 1000);
			jQuery(this).children('.portfolio-metta').show().css('opacity', '0').stop().animate({bottom: '54px', opacity : '1'}, 600);
	    }).mouseleave(function(e) {
	        jQuery(this).children('.image-caption').show().css('opacity', '1').stop().animate({top: '100%', opacity : '1'}, 600);
			jQuery(this).children('.image-title').stop().animate({top: '-65px', opacity : '0'}, 600);
			jQuery(this).children('.zoom').show().css('opacity', '0').stop().animate({opacity : '0'}, 1000);
			jQuery(this).children('.portfolio-metta').stop().animate({bottom: '-24px', opacity : '0'}, 600);
	    });	

		/*
		team hover
		=========================== */	
		$('.team-wrapper').hover(function(){
			$(".team-img", this).stop().animate({top:'-100%'},{queue:false,duration:550});
		}, function() {
			$(".team-img", this).stop().animate({top:'0'},{queue:false,duration:550});
		});	
	});


})(jQuery);