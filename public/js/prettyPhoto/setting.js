			$(document).ready(function(){
				$("a[data-pretty^='prettyPhoto']").prettyPhoto();
				
				$(".video:first a[data-pretty^='prettyPhoto']").prettyPhoto({animation_speed:'normal',theme:'pp_default',slideshow:3000, autoplay_slideshow: false});
				$(".video:gt(0) a[data-pretty^='prettyPhoto']").prettyPhoto({animation_speed:'fast',slideshow:10000, hideflash: true});
		
			});