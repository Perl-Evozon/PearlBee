
 
 


			var scrollSpeed = 100; 		// Speed in milliseconds
			var step = 1; 				// How many pixels to move per step
			var current = 0;			// The current pixel row
			var imageWidth = 2247;		// Background image width
			var headerWidth = 1280;		// How wide the header is.
			
			//The pixel row where to start a new loop
			var restartPosition = -(imageWidth - headerWidth);
			
			function scrollBg(){
				//Go to next pixel row.
				current -= step;
				
				//If at the end of the image, then go to the top.
				if (current == restartPosition){
					current = 0;
				}
				
				//Set the CSS of the header.
				$('#animated-bg,#animated-bg2,#animated-bg3,#animated-bg4,#animated-bg5,#animated-bg6,#animated-bg7, #animated-bg-inner').css("background-position",current+"px 0");
			}
			
			//Calls the scrolling function repeatedly
			var init = setInterval("scrollBg()", scrollSpeed);

			
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 