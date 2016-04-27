/**
 * Created by mihaelamarinca on 4/27/2016.
 */
$(document).ready(function(){
//MORE BUTTON - for USER
    var pageURL = window.location.pathname.split('/');
    var newURL = pageURL[1] + "/" + pageURL[2];
    var userURL = "posts/user";
    var tagURL = "posts/tag";
    var categoryURL = "posts/category";
    if (newURL == userURL) {
        $("#latest_posts").addClass("hidden");
        //button MORE - for listing page - USER
        $('#more-posts').click(function() {
            var button = $(this),
                pageNumber =  +(button.attr("data-page-number")) + 1,
                userName = "/" + pageURL[3];

            $('.progressloader').show();

            $.ajax({
                // Assuming an endpoint here that responds to GETs with a response.
                url: '/posts/user' + userName + '/page/' + pageNumber + '?format=JSON',
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
                            commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                        } else{
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }

                        newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".user a").html(posts[i].user.name);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
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
                tagName = "/" + pageURL[3],
                themeinitial = $('#cmn-toggle-4').is(':checked');

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
                            commentsText,
                            avatarPath;

                        if(posts[i].nr_of_comments ==  1){
                            commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                        } else{
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }

                        if (posts[i].user.avatar && posts[i].user.avatar !== "/blog/img/male-user.png") {
                            avatarPath = posts[i].user.avatar;
                        } else if ( themeinitial === false) {
                            avatarPath = "/blog/img/male-user.png";
                        } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                        }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".user a").html(posts[i].user.name);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
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

                    $(".truncate").dotdotdot({
                        ellipsis  : '... ',
                    });

                    $('.progressloader').hide();
                    button.attr("data-page-number", pageNumber);

                    $(".truncate").dotdotdot({
                        ellipsis  : '... ',
                    });

                    $(".posts.listings .text-listing-entries .post_preview_wrapper *").not("p, pre, code, b, strong, em, i, strike, s, a, blockquote, ul, ol, li").each(function() {
                        var content = $(this).contents();
                        $(this).replaceWith(content);
                    });
                });
        });

    } else if (newURL == categoryURL) {
        $("#latest_posts").addClass("hidden");
        //button MORE - for listing page - CATEGORY
        $('#more-posts').click(function() {
            var button = $(this),
                pageNumber =  +(button.attr("data-page-number")) + 1,
                categoryName = "/" + pageURL[3],
                themeinitial = $('#cmn-toggle-4').is(':checked');

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
                            commentsText,
                            avatarPath;

                        if(posts[i].nr_of_comments ==  1){
                            commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                        } else{
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }

                        if (posts[i].user.avatar && posts[i].user.avatar !== "/blog/img/male-user.png") {
                            avatarPath = posts[i].user.avatar;
                        } else if ( themeinitial === false) {
                            avatarPath = "/blog/img/male-user.png";
                        } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                        }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".user a").html(posts[i].user.name);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
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

                    $(".truncate").dotdotdot({
                        ellipsis  : '... ',
                    });

                    $('.progressloader').hide();
                    button.attr("data-page-number", pageNumber);

                    $(".truncate").dotdotdot({
                        ellipsis  : '... ',
                    });

                    $(".posts.listings .text-listing-entries .post_preview_wrapper *").not("p, pre, code, b, strong, em, i, strike, s, a, blockquote, ul, ol, li").each(function() {
                        var content = $(this).contents();
                        $(this).replaceWith(content);
                    });
                });
        });
    } else {

//button MORE - for listing page
        $('#more-posts').click(function() {
            var button = $(this),
                pageNumber =  +(button.attr("data-page-number")) + 1,
                themeinitial = $('#cmn-toggle-4').is(':checked');

            $('.progressloader').show();

            $.ajax({
                // Assuming an endpoint here that responds to GETs with a response.
                url: '/posts/page/' + pageNumber + '?format=JSON',
                type: 'GET'
            })
            .done(function(data) {
                var posts = JSON.parse(data).posts;
                // Once the server responds with the result, update the
                //  textbox with that result.
                for( var i= 0; i < posts.length; i++){
                    var entryItem = $(".entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText,
                        avatarPath;

                    if(posts[i].nr_of_comments ==  1){
                        commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                    } else{
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    if (posts[i].user.avatar && posts[i].user.avatar !== "/blog/img/male-user.png") {
                        avatarPath = posts[i].user.avatar;
                    } else if ( themeinitial === false) {
                        avatarPath = "/blog/img/male-user.png";
                    } else if ( themeinitial === true) {
                        avatarPath = "/blog/img/male-user-light.png";
                    }


                    newItem.find(".bubble img.user-image").attr("src", avatarPath);
                    newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
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

                $(".truncate").dotdotdot({
                    ellipsis  : '... ',
                });

                $('.progressloader').hide();
                button.attr("data-page-number", pageNumber);

                $(".posts.listings .text-listing-entries .post_preview_wrapper *").not("p, pre, code, b, strong, em, i, strike, s, a, blockquote, ul, ol, li").each(function() {
                    var content = $(this).contents();
                    $(this).replaceWith(content);
                });

            });
        });
    }

});