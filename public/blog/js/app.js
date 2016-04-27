$(document).ready(function() {

    //  cookie for "cookie bar"
    function cookiesAccept(){
       days=60;
       myDate = new Date();
       myDate.setTime(myDate.getTime()+(days*24*60*60*1000));
       document.cookie = 'cookies=Accepted; expires=' + myDate.toGMTString();
    }

    var cookie = document.cookie.split(';')
        .map(function(x){ return x.trim().split('='); })
        .filter(function(x){ return x[0]==='cookies'; })
        .pop();

    if (!(cookie && cookie[1]==='Accepted')) {
        $(".cookies").css("display", "block");
       // $(".header").css("transition","none");
       $(".header").css("top","0px");
    }

    $('.closeCookie').on('click', function(){
        cookiesAccept();
        return false;
    });

    $("button.closeCookie").click(function(){
        $(".cookies").css("top","-31px").css("box-shadow","none");
        $(".header").css("transition","top 0.8s ease-in").css("top","0px");
    });
    //END cookies

    //header
    $(".input-group, .links-group:first").on('click',function(event){
        event.stopPropagation();
    });

    $("#header_onion_logo, #only-logo").on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        window.location = window.location.protocol + "//" + window.location.host + "/";
    }).on('mouseover', function (e) {
        $("#header_onion_logo").css('cursor','pointer');
    });
    // END Header


    // prettyprint
    $('pre').each(function(){ 
        var class_name = $(this).attr('class');
        if (class_name != undefined) {
          $( "pre" ).removeClass().addClass( "prettyprint lang-" );
            //$(this).className = $(this).attr('class', class_name.replace(/brush:/,'prettyprint lang-').replace(/;$/,''));
        } else {
          $( "pre" ).removeClass().addClass( "prettyprint lang-" );

        }
    });

    $('code').each(function(){ 
      $( "code" ).removeClass().addClass( "prettyprint lang-" );
    });
    // END prettyprint


/* ===== comments - not used ? - TODO: check if needed and remove if not ========== */
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
/* ======================================================================== */



    // ajax when toggle theme changes.
    $(function changeTheme(){

        $('#cmn-toggle-4').on('change',function() {
            var theme = $('#cmn-toggle-4').is(':checked');
            console.log("theme:",theme);
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
                var url = window.location.href;
                //var posts = JSON.parse();
                //console.log(themeq[]);

                $('.bubble').each(function() {

                    var src = $( this ).parent().find('img').attr('src');
                    console.log("src:",src);
                  
                    var userImg = $( this ).parent().find('img');
                    if (src !== undefined) { 
                        var defaultAvatar = (src.match(/\/blog\/img/g)||[]).length;

                        if (themeq === "light") {
                            $(".defaultAvatar").attr("src", "/blog/img/male-user-light.png");
                        } else if (themeq === "dark") {
                            $(".defaultAvatar").attr("src", "/blog/img/male-user.png");
                        }

                        if (themeq === "light" && defaultAvatar === 1) {
                            $("#theme").attr("href", "/blog/css/light.css");
                            $("#cmn-toggle-4").attr('checked', true);
                            userImg.attr('src', "/blog/img/male-user-light.png");
                        } 
                         else if (themeq === "light" && defaultAvatar === 0) {
                            $("#theme").attr("href", "/blog/css/light.css");
                            $("#cmn-toggle-4").attr('checked', true);
                        }
                         else if (themeq === "dark" && defaultAvatar === 1) {
                             $("#theme").attr("href", "/blog/css/dark.css"); 
                             $("#cmn-toggle-4").attr('checked', false);
                             userImg.attr('src', "/blog/img/male-user.png");
                        }
                         else if (themeq === "dark" && defaultAvatar === 0) {
                              $("#theme").attr("href", "/blog/css/dark.css");
                              $("#cmn-toggle-4").attr('checked', false);
                        }
                    }
             });
        });
        });
    });
    // END theme changes

    /* Strip image tags from post preview */
    $('.post_preview_wrapper img').remove();

    //    Truncate Post content
    $(".truncate").dotdotdot({
        ellipsis  : '... ',
    });
    $(window).resize(function(){
        $(".truncate").dotdotdot({
            ellipsis  : '... ',
        });
    });

    //Individual posts
    $('.blog-post').css('min-height', $(window).height()-$('.blog-comment').height()-$('footer').height()-80);
    $(window).resize(function(){
        $('.blog-post').css('min-height', $(window).height()-$('.blog-comment').height()-$('footer').height()-80);
    });
    //Listing page
    $('.blog').css('min-height', $(window).height()-$('footer').height()-45);
    $(window).resize(function(){
        $('.blog').css('min-height', $(window).height()-$('footer').height()-45);
    });

    //Pages page
    $('.pages').css('min-height', $(window).height()-$('footer').height()-45);
    $(window).resize(function(){
        $('.pages').css('min-height', $(window).height()-$('footer').height()-45);
    });

    //  Sign up
    $('.sign-up').css('min-height',$(window).height()-80);
    $(window).resize(function(){
        $('.sign-up').css('min-height',$(window).height()-80);
    });

    // Register
    $('.register').css('min-height',$(window).height()-80);
    $(window).resize(function(){
        $('.register').css('min-height',$(window).height()-80);
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

    //More button for BLOGs individual page
    $('#more-blog-posts').click(function() {
        var button = $(this),
            pageNumber =  +(button.attr("data-page-number")) + 1,
            url = window.location.pathname;

        $('.progressloader').show();

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: url + '/page/' + pageNumber + '?format=JSON',
            type: 'GET'
        })
        .done(function(data) {
            var posts = JSON.parse(data).posts;

            if (posts.length === 0) {
                button.parents('.loading-posts').addClass('hidden');
                $('.no-more-posts').show();
            } else {
                // TODO: daca se schimba in back-end si vin cate 10 odata, schimba aici in 10
                if (posts.length < 10) {
                    button.parents('.loading-posts').addClass('hidden');
                    $('.no-more-posts').show();
                } else {
                    button.parents('.loading-posts').removeClass('hidden');
                }

                // Once the server responds with the result, update the
                //  textbox with that result.
                for (var i = 0; i < posts.length; i++) {
                    var entryItem = $(".entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText;

                    if (posts[i].nr_of_comments == 1) {
                        commentsText =  "Comment (" + posts[i].nr_of_comments + ")";
                    } else {
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                    newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);

                    if (posts[i].post_categories) {
                        var categoryItem = newItem.find('.category-item.hidden');
                        for (var j = 0; j < posts[i].post_categories.length; j++) {
                            var newCategoryItem = categoryItem.clone();

                            newCategoryItem.find('a').text(posts[i].post_categories[j].category.name);
                            newCategoryItem.find('a').attr('href', '/posts/category/' + posts[i].post_categories[j].category.slug);

                            newCategoryItem.removeClass('hidden');
                            newCategoryItem.insertAfter(newItem.find('.category-item').last());
                        }
                    }

                    newItem.insertBefore($(".loading-posts"));
                }
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

    if ($(".blog.blogs .no-posts").length > 0) {
        $(".blog.blogs .no-more-posts").hide();
    }

    $(".posts.listings .text-listing-entries .post_preview_wrapper *").not("p, pre, code, b, strong, em, i, strike, s, a, blockquote, ul, ol, li").each(function() {
        var content = $(this).contents();
        $(this).replaceWith(content);
    });
});
