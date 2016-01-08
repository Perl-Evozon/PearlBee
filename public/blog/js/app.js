// Replace the classes for the google code prettefier to work

$(document).ready(function() {

    $("#header_onion_logo").on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        window.location = window.location.protocol + "//" + window.location.host + "/";
    }).on('mouseover', function (e) {
        $("#header_onion_logo").css('cursor','pointer');
    });

    $('pre').each(function(){ 
        var class_name = $(this).attr('class');
        $(this).className = $(this).attr('class', class_name.replace(/brush:/,'prettyprint lang-').replace(/;$/,''));
    });

    $(".reply_comment_div").each(function(){
        $(this).hide();
        $(this).find('form').prepend('<input type="hidden" value="' + this.id + '" name="in_reply_to" />');
        $(this).find('div .title').replaceWith( "<h5>Reply</h5>" );

        if ($(this).attr('id') == $(this).attr('div_set')) {
            // repopulate the submitted form
            $(this).find('input[id=name]').val($(this).attr('field_fullname'));
            $(this).find('input[id=email]').val($(this).attr('field_email'));
            $(this).find('input[id=website]').val($(this).attr('field_website'));
            $(this).find('textarea[name=comment]').val($(this).attr('field_comment'));
            $( this ).show(); //if this was submitted, show it again
        } else {
            //clear info from this kind of fields
            $(this).find('input[id=name]').val('');
            $(this).find('input[id=email]').val('');
            $(this).find('input[id=website]').val('');
            $(this).find('textarea[name=comment]').val('');
        }
    });

    $(".comment_reply").on('click', function( aaa ){
        var reply_comm = this.id + '_div';

        if ($("#" + reply_comm).is(":visible")) {
             $( "#" + reply_comm ).hide();
        } else {
            $( "#" + reply_comm ).show();
        }
    });


    // Leave a comment for a blog post
    $("#reply_post_comment_button").on('click', function (e){
        e.preventDefault();
        e.stopPropagation();
        var comment = $("#reply_post_comment_textarea").val();
        $.ajax({
            method: "POST",
            url: window.location.protocol + "//" + window.location.host + "/comments",
            data: { comment: comment }
        })
        .done(function( msg ) {

            console.log( "Data Saved: ", msg );
        });
    });



//    Truncate Post content

  $(".truncate").dotdotdot({
    ellipsis  : '... ',
  });


//    Register
  $("#confirmPasswordRegister").keyup(function() {
    if( $(this).val() !== $("#passwordRegister").val() ){
        $("#confirmPasswordRegister").addClass('error');
    } else {
        $("#confirmPasswordRegister").removeClass('error');
    }
  });

//Form Register validation

  function validationForm(event) {
      var email = $("#emailRegister").val();
      var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
      var username = $("#usernameRegister").val();
      var name = $("#displayNameRegister").val();
      var password = $("#passwordRegister").val();
      var confirmPassword = $("#confirmPasswordRegister").val();
      var terms = $("#confirmTerms").is(":checked");
      var errors = 0;

//      Email validation
      $('#register_form input').css('border-color' , '#CCC').removeClass('error');

      if (email.length < 1) { //      Email validation
        $('.change_error').text('Email field is necesary').css('color' , 'red');
        $('#emailRegister').css('border-color' , 'red');
        errors++;

      } else if (!(email).match(emailReg)) { //  Email Regex validation
        $('.change_error').text('Invalid Email').css('color' , 'red');
        $('#emailRegister').addClass('error');
        errors++;

      } else if (username.length < 3) { //      Username validation
        $('.change_error').text('Username field is necesary').css('color' , 'red');
        $('#usernameRegister').css('border-color' , 'red');
        errors++;

      }
      else if (name.length < 3) { //      Display name validation
        $('.change_error').text('Display name field is necesary').css('color' , 'red');
        $('#displayNameRegister').css('border-color' , 'red');
        errors++;

      }
      else if (password.length < 3) { //      Password validation
        $('.change_error').text('Password is necesary').css('color' , 'red');
        $('#passwordRegister').css('border-color' , 'red');
        errors++;

      }
      else if (confirmPassword !== password) { //      Confirm password validation
        $('.change_error').text("Confirm password doesn't mach with password").css('color' , 'red');
        $('#confirmPasswordRegister').css('border-color' , 'red');
        errors++;

      }
      else if (!terms) { //      Checkbox validation
        $('.change_error').text("Terms and conditions checkbox is necesary").css('color' , 'red');
        errors++;

      }

      if (errors === 0) {
        return true
      }
      return false;
    }

  $("#register_form").on('submit', function() {
    if (validationForm()) // Calling validation function.
      {
        $("#register_form").submit(); // Form submission.
      } else {
      return false;
      }
    });

    function getCookie(c_name) {
		if (document.cookie.length>0) {
			 c_start=document.cookie.indexOf(c_name + "=");
			 if (c_start!=-1) {
        		c_start=c_start + c_name.length+1 ;
        		c_end=document.cookie.indexOf(";",c_start);
        		if (c_end==-1) c_end=document.cookie.length
        				return unescape(document.cookie.substring(c_start,c_end));
            }
        }
		return ""
    }

//	Blog start overlay
    if ( getCookie('first_visit') != 1) {
    	if ($(".blog-start").hasClass("show") ) {
            console.log('>>>>>>' + getCookie('first_visit'));
    		$("body").addClass("active-overlay");
    	}
    } else {
        $(".blog-start").removeClass("show");
        $(".blog-start").addClass("hide");
        $("body").removeClass("active-overlay");
    }

	$("#close_overlay").on('click', function() {
		$(".blog-start").slideToggle( "slow" );
		$(".blog-start").removeClass("show");
		$("body").removeClass("active-overlay");
        document.cookie='first_visit' + "=" + 1;
	});
    $("#signin").on('click', function() {
        $(".blog-start").slideToggle( "slow" );
        $(".blog-start").removeClass("show");
        $("body").removeClass("active-overlay");
        document.cookie='first_visit' + "=" + 1;
    });
    $("#register").on('click', function() {
        $(".blog-start").slideToggle( "slow" );
        $(".blog-start").removeClass("show");
        $("body").removeClass("active-overlay");
        document.cookie='first_visit' + "=" + 1;
    });

//	$('.blog-start').css('min-height',$(window).height() * 0.3);
//	$(window).resize(function(){
//	  $('.blog-start').css('min-height',$(window).height() * 0.3);
//	});

//	Sign up
	$('.sign-up').css('min-height',$(window).height()-80);
	$(window).resize(function(){
	  $('.sign-up').css('min-height',$(window).height()-80);
	});

});

$(window).resize(function(){
  $(".truncate").dotdotdot({
    ellipsis  : '... ',
  });


//	Header
	if ($(window).width() <= 800){
		$("body").removeClass("active-overlay");
		$(".search-label").addClass("hidden");
		$(".header .user").removeClass("hidden");
		$(".blog-start").addClass("hidden");
		$(".header .user").click(function(){
			$(".blog-start").toggleClass("hidden");
			$("body").toggleClass("active-overlay");
		});
	}
	else {
		$(".header .user").addClass("hidden");
		$(".blog-start").removeClass("hidden");
	}


	if ($(window).width() >= 801){
		$("#close_overlay").click(function(){
			$(".user").removeClass("hidden");
		});
		if( $(".blog-start").hasClass("show")) {
			$(".user").addClass("hidden");
		} else {
			$(".user").removeClass("hidden");
		}
//		$(".user").click(function(){
//			$(".blog-start").toggleClass("hidden");
//			$("body").toggleClass("active-overlay");
//		});
	}

	$(".input-group, .links-group:first").on('click',function(event){
		event.stopPropagation();
	});

});

//Back to top at refresh
$(window).on('beforeunload', function() {
    $(window).scrollTop(0);
});

//If No Posts
if ($(".no-posts").length > 0){
  $(".view-more").addClass("cut");
  } else {
  $(".view-more").removeClass("cut");
}

//Close search
$("#close_search").on('click', function (e) {
    e.preventDefault();
    e.stopPropagation();
    window.location = window.location.protocol + "//" + window.location.host + "/";
});

//click on search
//$(".header-icon").on('click', function (e) {
//    e.preventDefault();
//    e.stopPropagation();
//    window.location = window.location.protocol + "//" + window.location.host + "/search/user-posts"; 
//});

//Tabs label align, tabs & search min-height
$( ".tabs label" ).first().css( "margin-left", "10px" );

$('.tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
$(window).resize(function(){
    $('.tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
});

//$('.input-search').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".header").outerHeight(true));
//$(window).resize(function(){
//    $('.input-search').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".header").outerHeight(true));
//});


//$('#search').keypress(function (e) {
//      var key = e.which;
//      if(key == 13) {
//      $(".search-top").removeClass("hidden");
//    }
//});

//button MORE - for listing page
$('#more-posts').click(function() {
    var button = $(this),
        pageNumber =  +(button.attr("data-page-number")) + 1;

    $('.progressloader').show();

    $.ajax({
        // Assuming an endpoint here that responds to GETs with a response.
        url: '/page/' + pageNumber + '?format=JSON',
        type: 'GET'
    })
        .done(function(data) {
            var posts = JSON.parse(data);

            // Once the server responds with the result, update the
            //  textbox with that result.
            for( var i= 0; i < posts.length; i++){
                var entryItem = $(".entry").get(0),
                    newItem = $(entryItem).clone(),
                    commentsText;

                if(posts[i].nr_of_comments ==  1){
                    commentsText = "Comment";
                } else{
                    commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                }

                newItem.find(".user a").attr("href", "/post/" + posts[i].user.username);
                newItem.find(".post_preview_wrapper").html(posts[i].content);
                newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].title);
                newItem.find(".user a").html(posts[i].user.username);
                newItem.find(".post-heading h2 a").html(posts[i].title);
                newItem.find(".comments-listings a").text(commentsText);
                newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
                newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                newItem.find(".date").text(posts[i].created_date);



                newItem.insertBefore($(".loading-posts"));
            }

            $(".truncate").dotdotdot({
                ellipsis  : '... ',
            });

            $('.progressloader').hide();
            button.attr("data-page-number", pageNumber);

          $(".truncate").dotdotdot({
            ellipsis  : '... ',
          });
        });
});