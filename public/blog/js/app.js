

$(document).ready(function() {

    //  Blog start overlay
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

    if ( getCookie('first_visit') != 1) {
        if ($(".blog-start").hasClass("show") ) {
//            console.log('>>>>>>' + getCookie('first_visit'));
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
//  END Blog start overlay
    
//  Header
    if ($(window).width() <= 800){
        $("body").removeClass("active-overlay");
        $(".search-label").addClass("hidden");
        $(".header .user").removeClass("hidden");
        $(".blog-start").addClass("hidden");
        $(".header .user").click(function(){
            event.preventDefault();
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
    }

    $(".input-group, .links-group:first").on('click',function(event){
        event.stopPropagation();
    });
//  END Header

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

// ajax when toggle changes.
    $(function(){
        $('#cmn-toggle-4').on('change',function() {
            var theme = $('#cmn-toggle-4').is(':checked');
            console.log("theme:", theme);
            $.ajax({
         //Assuming an endpoint here that responds to GETs with a response.
                url: "/theme" ,
                method: "POST",
                contentType: "application/x-www-form-urlencoded",
               data: { 
                  theme: theme
                }
            })
            .done(function (data) {
                var themeq = data.toString();
                //var posts = JSON.parse();
                //console.log(themeq[]);
                if (themeq === "light") {
                    $("#theme").attr("href", "/blog/css/light.css");
                    $("#cmn-toggle-4").attr('checked', true);
                    } else {
                     $("#theme").attr("href", "/blog/css/dark.css"); 
                     $("#cmn-toggle-4").attr('checked', false);
                 }
               
        });
        });
    });

    // Leave a comment for a blog post
    $("#reply_post_comment_button").on('click', function (e){
        var comment = $("#reply_post_comment_form #comment").val();
        var slug = $("#reply_post_comment_form #slug").val();

       // e.preventDefault();
       // e.stopPropagation();


        $.ajax({
            method: "POST",
            url: "/comments",
            contentType: "application/x-www-form-urlencoded",
            data: {
              slug: slug,
              comment: comment
            }
        })
        .done(function (data) {
            //var posts = JSON.parse(data);
            //for( var i= 0; i < posts.length; i++){
                var entryItem = $(".comment-list .comment").get(0),
                    newItem = $(entryItem).clone();

                newItem.find(".comment-author b").html(data.user.username);
                newItem.find(".content-comment .cmeta .hours").html(data.comment_date_human);
                newItem.find(".content-comment p").html(data.content);

               // newItem.insertBefore($(".comment"));
                  $($(".comment-list").get(0)).prepend(newItem);
                  newItem.removeClass('hidden');
            //}
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

      if (errors === 0) {
        return true;
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
	
//	My profile password confirmation 
	
  $("#confirmNewPassword").keyup(function() {
    if( $(this).val() !== $("#newPassword").val() ){
        $("#confirmNewPassword").addClass('error');
    } else {
        $("#confirmNewPassword").removeClass('error');
    }
  });

//	Sign up
	$('.sign-up').css('min-height',$(window).height()-80);
	$(window).resize(function(){
	  $('.sign-up').css('min-height',$(window).height()-80);
	});



$(window).resize(function(){
  $(".truncate").dotdotdot({
    ellipsis  : '... ',
  });
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
           window.history.back();
    });

//Tabs label align and tabs min-height
$( ".tabs label" ).first().css( "margin-left", "10px" );

$('.tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
$(window).resize(function(){
    $('.tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
});


//button MORE - for listing page
//$('#more-posts').click(function() {
//    var button = $(this),
//        pageNumber =  +(button.attr("data-page-number")) + 1;
//
//    $('.progressloader').show();
//
//    $.ajax({
//        // Assuming an endpoint here that responds to GETs with a response.
//        url: '/page/' + pageNumber + '?format=JSON',
//        type: 'GET'
//    })
//        .done(function(data) {
//            var posts = JSON.parse(data);
//
//            // Once the server responds with the result, update the
//            //  textbox with that result.
//            for( var i= 0; i < posts.length; i++){
//                var entryItem = $(".entry").get(0),
//                    newItem = $(entryItem).clone(),
//                    commentsText;
//
//                if(posts[i].nr_of_comments ==  1){
//                    commentsText = "Comment";
//                } else{
//                    commentsText = "Comments (" + posts[i].nr_of_comments + ")";
//                }
//
//                newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
//                newItem.find(".post_preview_wrapper").html(posts[i].content);
//                newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].title);
//                newItem.find(".user a").html(posts[i].user.username);
//                newItem.find(".post-heading h2 a").html(posts[i].title);
//                newItem.find(".comments-listings a").text(commentsText);
//                newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
//                newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
//                newItem.find(".date").text(posts[i].created_date);
//
//
//
//                newItem.insertBefore($(".loading-posts"));
//            }
//
//            $(".truncate").dotdotdot({
//                ellipsis  : '... ',
//            });
//
//            $('.progressloader').hide();
//            button.attr("data-page-number", pageNumber);
//
//          $(".truncate").dotdotdot({
//            ellipsis  : '... ',
//          });
//        });
//});

//tab 1 user-posts
function getUserPosts(searchTerm, pageNumber, removeExistingPosts) {
        if (true === removeExistingPosts) {
            $('#tab-content1 .progressloader-holder').show();
        }

        $('.progressloader').show();
        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/search/posts/' + searchTerm + "/" + pageNumber,
            type: 'GET'
        })
            .done(function (data) {

                if (true === removeExistingPosts) {
                    $('#tab-content1 .entry:not(.hidden)').remove();
                }

                var posts = JSON.parse(data).posts;
                if (posts.length === 0) {
                    $('.no-posts').show();
                    //$('.tabs .loading-posts').css('margin-bottom', '0');
                    $(".view-more").addClass("cut");
                } else {
                    $('.no-posts').hide();
                    $(".view-more").removeClass("cut");

                    //  textbox with that result.
                    for (var i = 0; i < posts.length; i++) {
                        var entryItem = $(".entry").get(0),
                            newItem = $(entryItem).clone(),
                            commentsText;

                        if (posts[i].nr_of_comments == 1) {
                            commentsText = "Comment";
                        } else {
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }


                        newItem.find(".user a").html(posts[i].username);
                        newItem.find(".user a").attr("href", "/post/" + posts[i].username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content);
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                        newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".date").text(posts[i].created_date);


                        newItem.insertBefore($(".loading-posts"));
                        newItem.removeClass('hidden');
                    }
                }
                $('#tab-content1 .progressloader').hide();
                $('#search-more-posts').attr("data-posts-number", pageNumber);

            })
            .fail(function () {
                $('#tab-content1 .entry:not(.hidden)').remove();
                $('.no-posts').show();
            })
            .always(function () {
                //close search input
                $(".search-input").addClass("cut");
                $('#tab-content1 .progressloader-holder').hide();
            });
}
//tab 2: user-info;
    function getPeople(searchTerm) {

        $('#tab-content2 .progressloader-holder').show();
        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/search/user-info/' + searchTerm,
            type: 'GET'
        })
            .done(function (data) {
                $('#tab-content2 .user-info-entry:not(.hidden)').remove();

                var userInfo = JSON.parse(data).info;
                if (userInfo.length === 0){
                    $('.no-posts2').show();
                } else {
                    $('.no-posts2').hide();

                    //  textbox with that result.
                    for (var i = 0; i < userInfo.length; i++) {
                        var entryItem = $(".user-info-entry").get(0),
                            newItem = $(entryItem).clone(),
                            avatarPath;

                        if (userInfo[i].avatar_path) {
                            avatarPath = userInfo[i].avatar_path;
                        } else {
                            avatarPath = "/blog/img/male-user.png";
                        }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".info-entry a").text(userInfo[i].name);
                        newItem.find(".info-entry a").attr("href", "/posts/user/" + userInfo[i].username);
                        newItem.find(".info-entry .date").text(userInfo[i].register_date);

                        newItem.find(".properties li.nr-blog span").text(userInfo[i].counts.blog);
                        newItem.find(".properties li.nr-entries span").text(userInfo[i].counts.post);
                        newItem.find(".properties li.nr-comments span").text(userInfo[i].counts.comment);


                        newItem.appendTo($(".user-info-listing"));
                        newItem.removeClass('hidden');
                    }
                }
            })
            .fail(function() {
                $('#tab-content2 .user-info-entry:not(.hidden)').remove();
                $('.no-posts2').show();
            })
            .always(function() {
                //close search input
                $(".search-input").addClass("cut");
                $('#tab-content2 .progressloader-holder').hide();
            });
    }
//tab3 : tags
    function getTags(searchTerm) {
        $('#tab-content3 .progressloader-holder').show();
        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/search/user-tags/' + searchTerm,
            type: 'GET'
        })
            .done(function (data) {
                $('#tab-content3 #tag-list li:not(.hidden)').remove();

                var tags = JSON.parse(data).tags;
                if (tags.length === 0){
                    $('.no-posts3').show();
                } else {
                    $('.no-posts3').hide();

                    //  textbox with that result.
                    for (var i = 0; i < tags.length; i++) {
                        var entryItem = $("#tag-list li").get(0),
                            newItem = $(entryItem).clone();

                        newItem.find("a.btn-tag").attr("href", "/posts/tag/" + tags[i].slug);
                        newItem.find("a.btn-tag").html(tags[i].name);


                        newItem.appendTo($("#tag-list"));
                        newItem.removeClass('hidden');
                    }
                }
            })
            .fail(function() {
                $('#tab-content3 #tag-list li:not(.hidden)').remove();
                $('.no-posts3').show();
            })
            .always(function() {
                //close search input
                $(".search-input").addClass("cut");
                $('#tab-content3 .progressloader-holder').hide();
            });
    }

//search - for first tab : posts
    $('input[name=search_term]').on('keyup', function(e) {
        var code = (e.keyCode ? e.keyCode : e.which),
            searchTerm,
            activeTab,
            activeTabId;

        if (code !== 13) {
            return false;
        }

        searchTerm = $('input[name=search_term]').val();
        $(".tabs-head h2 span").html(searchTerm);


        activeTab = $('input[name=tabs]:checked');
        activeTabId = activeTab.attr('id');

        activeTab.attr("data-search-term", searchTerm);

        if (activeTabId == 'tab1') {
            getUserPosts(searchTerm, 0, true);
        } else if (activeTabId == 'tab2') {
            getPeople(searchTerm);
        } else {
            getTags(searchTerm);
        }

    });


$('input[name=tabs]').on('change', function () {
    var searchTerm = $('input[name=search_term]').val(),
        activeTabId = $(this).attr('id'),
        prevSearchTerm = $(this).attr('data-search-term');

    if (prevSearchTerm !== searchTerm) {
        $(this).attr("data-search-term", searchTerm);

        if (activeTabId == 'tab1') {
            getUserPosts(searchTerm, 0, true);
        } else if (activeTabId == 'tab2') {
            getPeople(searchTerm);
        } else {
            getTags(searchTerm);
        }
    }
});

//more button - for posts search
$('#search-more-posts').click(function () {
    var button = $(this),
        searchTerm = $('input[name=search_term]').val(),
        pageNumber = +(button.attr("data-posts-number")) + 1;

    $('#tab-content1 .progressloader').show();
    getUserPosts(searchTerm, pageNumber, false);
});

//MORE BUTTON - for USER
var pageURL = window.location.pathname.split('/');
var newURL = pageURL[1] + "/" + pageURL[2];
var userName = "/" + pageURL[3];
var userURL = "posts/user";
var tagURL = "posts/tag";
var categoryURL = "posts/category";
if (newURL == userURL) {
	$("#latest_posts").addClass("hidden");
	//button MORE - for listing page - USER
	$('#more-posts').click(function() {
		var button = $(this),
			pageNumber =  +(button.attr("data-page-number")) + 1,
			pageURL = window.location.pathname.split('/'),
			userName = "/" + pageURL[3];

		$('.progressloader').show();

		$.ajax({
			// Assuming an endpoint here that responds to GETs with a response.
			url: '/posts/user' + userName + '/page/' + pageNumber + '?format=JSON',
			type: 'GET'
		})
			.done(function(data) {
				var posts = JSON.parse(data).posts;

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

					newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
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
		
} else if (newURL == tagURL) {
	$("#latest_posts").addClass("hidden");
	//button MORE - for listing page - TAGS
	$('#more-posts').click(function() {
		var button = $(this),
			pageNumber =  +(button.attr("data-page-number")) + 1,
			pageURL = window.location.pathname.split('/'),
			tagName = "/" + pageURL[3];
		
		$('.progressloader').show();

		$.ajax({
			// Assuming an endpoint here that responds to GETs with a response.
			url: '/posts/tag' + tagName + '/page/' + pageNumber + '?format=JSON',
			type: 'GET'
		})
			.done(function(data) {
				var posts = JSON.parse(data).posts;
				var nrPage = JSON.parse(data).page;
				var maxPage = JSON.parse(data).total_pages;
				if ( nrPage >= maxPage ) {
					$('#view_more').addClass('hidden');
					$('#display_msg_posts').fadeIn().delay(1000).fadeOut(1500);
				}
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

					newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
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
	
} else if (newURL == categoryURL) {
		$("#latest_posts").addClass("hidden");
	//button MORE - for listing page - CATEGORY
	$('#more-posts').click(function() {
		var button = $(this),
			pageNumber =  +(button.attr("data-page-number")) + 1,
			pageURL = window.location.pathname.split('/'),
			categoryName = "/" + pageURL[3];
		
		$('.progressloader').show();

		$.ajax({
			// Assuming an endpoint here that responds to GETs with a response.
			url: '/posts/category' + categoryName + '/page/' + pageNumber + '?format=JSON',
			type: 'GET'
		})
			.done(function(data) {
				var posts = JSON.parse(data).posts;
				var nrPage = JSON.parse(data).page;
				var maxPage = JSON.parse(data).total_pages;
				if ( nrPage >= maxPage ) {
					$('#view_more').addClass('hidden');
					$('#display_msg_posts').fadeIn().delay(1000).fadeOut(1500);
				}
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

					newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
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
} else {
	
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

                newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
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
	
}
