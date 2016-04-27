/**
 * Created by mihaelamarinca on 4/25/2016.
 */
$(document).ready(function(){
    //Close search
    $("#close_search").on('click', function (e) {
        window.history.back();
    });

    //Tabs label align and tabs min-height
    $( ".tabs label" ).first().css( "margin-left", "10px" );

    $('.search-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
    $(window).resize(function(){
        $('.search-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
    });

//tab 1 user-posts
    function getUserPosts(searchTerm, pageNumber, removeExistingPosts) {
        if (true === removeExistingPosts) {
            $('#tab-content1 .progressloader-holder').show();
        }
        var themeinitial = $('#cmn-toggle-4').is(':checked');

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
                    $(".view-more").addClass("cut");
                    if (pageNumber == 0) {
                        //$('.tabs .loading-posts').css('margin-bottom', '0');
                        $('.no-posts').show();
                    }
                } else {
                    if(posts.length < 10){
                        $(".view-more").addClass("cut");
                    } else{
                        $(".view-more").removeClass("cut");
                    }
                    $('.no-posts').hide();

                    //  textbox with that result.
                    for (var i = 0; i < posts.length; i++) {
                        var entryItem = $(".entry").get(0),
                            newItem = $(entryItem).clone(),
                            commentsText,
                            avatarPath;

                        if (posts[i].nr_of_comments == 1) {
                            commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                        } else {
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }


                        if (posts[i].user.avatar) {
                            avatarPath = posts[i].user.avatar;
                        } else if ( themeinitial === false) {
                            avatarPath = "/blog/img/male-user.png";
                        } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                        }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".user a").html(posts[i].user.name);
                        newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                        newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".date").text(posts[i].created_date_human);


                        newItem.insertBefore($(".loading-posts"));
                        newItem.removeClass('hidden');
                    }
                }
                $('#tab-content1 .progressloader').hide();
                $('#search-more-posts').attr("data-posts-number", pageNumber);

                $(".truncate").dotdotdot({
                    ellipsis  : '... ',
                });

                if ($(".search-page .tabs .no-posts.no-posts-found1").css("display") == "block") {
                    $(".search-page .tabs .loading-posts").css("margin-bottom", "0");
                }

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
        var themeinitial = $('#cmn-toggle-4').is(':checked');
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
                        } else if ( themeinitial === false) {
                            avatarPath = "/blog/img/male-user.png";
                        } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                        }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".info-entry a").text(userInfo[i].name);

                        if((userInfo[i].name.length > 18) && ($(window).width() < 600)) {
                            newItem.find(".info-entry a").html(userInfo[i].name.slice(0,18)+"...");
                        }

                        newItem.find(".info-entry a").attr("href", "/profile/author/" + userInfo[i].username);
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
                        if(tags[i].name.length < 30) {
                            newItem.find("a.btn-tag").html(tags[i].name);
                        } else {
                            newItem.find("a.btn-tag").html(tags[i].name.slice(0,30)+"...");
                        }
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
    $('input[name=search_term]').focus();

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
});