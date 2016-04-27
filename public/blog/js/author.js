/**
 * Created by mihaelamarinca on 4/26/2016.
 */
$(document).ready(function(){
    //Tabs label align and tabs min-height
    $( ".tabs label" ).first().css( "margin-left", "10px" );

    $('.author-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".author-page .background-bar").outerHeight(true) - $(".author-description").outerHeight(true));
    $(window).resize(function(){
        $('.author-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".author-page .background-bar").outerHeight(true) - $(".author-description").outerHeight(true));
    });

    if ($(".author-page input[name=author-tabs]:checked").attr('id') == "author-tab1") {
        $('#author-tab-content1').show();
    } else if ($(".author-page input[name=author-tabs]:checked").attr('id') == "author-tab2") {
        $('#author-tab-content2').show();
    } else {
        $('#author-tab-content3').show();
    }

    $(".author-page input[name=author-tabs]").on("change", function(){
        var activeTab = $(this).attr('id');
        if (activeTab == "author-tab1") {
            $('#author-tab-content1').show();
            $('#author-tab-content2').hide();
            $('#author-tab-content3').hide();
        } else if (activeTab == "author-tab2") {
            $('#author-tab-content2').show();
            $('#author-tab-content1').hide();
            $('#author-tab-content3').hide();
        } else {
            $('#author-tab-content3').show();
            $('#author-tab-content1').hide();
            $('#author-tab-content2').hide();
        }

    });

    function getAuthorEntries (button) {
        var authorURL =
            $('.author-description .author-name>a').attr('href').split('/');
        var author = authorURL[3];
        var pageNumber = +(button.attr("data-page-number"));

        $('.loading-author-entries .progressloader').show();

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/posts/user/' + author + '/page/' + pageNumber + '?format=JSON',
            type: 'GET'
        })
            .done(function (data) {
                var posts = JSON.parse(data).posts;

                if (posts.length === 0) {
                    button.addClass('hidden');
                    if (pageNumber == 0) {
                        $('.no-posts').removeClass('hidden');
                    }
                } else {
                    // TODO: daca se schimba in back-end si vin cate 10 odata, schimba aici in 10
                    if (posts.length < 5) {
                        button.addClass('hidden');
                    } else {
                        button.removeClass('hidden');
                    }
                    // Once the server responds with the result, update the
                    //  textbox with that result.
                    for (var i = 0; i < posts.length; i++) {
                        var entryItem = $(".author-entries .entry").get(0),
                            newItem = $(entryItem).clone(),
                            commentsText;

                        if (posts[i].nr_of_comments == 1) {
                            commentsText =  "Comment (" + posts[i].nr_of_comments + ")";
                        } else {
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }

                        newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].title);
                        newItem.find(".user a").html(posts[i].user.name);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug)
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                        newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".date").text(posts[i].created_date_human);


                        newItem.removeClass('hidden');
                        newItem.appendTo($(".author-entries"));
                    }

                    button.attr("data-page-number", pageNumber + 1);
                }
                $(".truncate").dotdotdot({
                    ellipsis: '... ',
                });

                $(".author-page .author-entries .post_preview_wrapper *").not("p, pre, code, b, strong, em, i, strike, s, a, blockquote, ul, ol, li").each(function() {
                    var content = $(this).contents();
                    $(this).replaceWith(content);
                });

            })
            .always(function () {
                $('.loading-author-entries .progressloader').hide();
            });
    }
//Author profile
    $('#more-author-entries').click(function (){
        getAuthorEntries($(this));
    });

    function getAuthorPages (button){
        var authorURL =
            $('.author-name>a').attr('href').split('/');
        var pageAuthor = authorURL[3];
        var pageNumber = +(button.attr("data-page-number"));

        //$('.loading-author-pages .progressloader').show();

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/pages/user/' + pageAuthor + '/page/' + pageNumber + '?format=JSON',
            type: 'GET'
        })
            .done(function (data) {
                var pages = JSON.parse(data).pages;

                if (pages.length === 0) {
                    button.addClass('hidden');
                    if (pageNumber == 0) {
                        $('.no-pages').removeClass('hidden');
                    }
                } else {
                    // TODO: daca se schimba in back-end si vin cate 10 odata, schimba aici in 10
                    if (pages.length < 10) {
                        button.addClass('hidden');
                    } else {
                        button.removeClass('hidden');
                    }
                    // Once the server responds with the result, update the
                    //  textbox with that result.
                    for (var i = 0; i < pages.length; i++) {
                        var entryItem = $(".author-pages .entry").get(0),
                            newItem = $(entryItem).clone();

                        newItem.find(".info-entry .page").html(pages[i].title);
                        newItem.find(".page-preview-wrapper").html(pages[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".read-more").attr("href", '/pages/' + pages[i].slug);

                        newItem.removeClass('hidden');
                        newItem.appendTo($(".author-pages"));
                    }

                    $(".text-listing-pages").find('*').removeAttr("style");
                    button.attr("data-page-number", pageNumber + 1);
                }
                $(".truncate").dotdotdot({
                    ellipsis: '... ',
                });

                $(".author-page .author-entries .post_preview_wrapper *").not("p, pre, code, b, strong, em, i, strike, s, a, blockquote, ul, ol, li").each(function() {
                    var content = $(this).contents();
                    $(this).replaceWith(content);
                });
            });

    }

//Author pages
    $('#more-author-pages').click(function (){
        getAuthorPages($(this));
    });

// Get  author entries when clicking on tab 2
    $('input[name=author-tabs]').on('change', function () {
        var activeTabId = $(this).attr('id');

        if (activeTabId == 'author-tab2') {
            if ($('.author-entries .entry:not(.hidden)').length == 0) {
                $('#more-author-entries').addClass('hidden');
                getAuthorEntries($('#more-author-entries'));
            }
        } else if(activeTabId == 'author-tab3'){
            if ($('.author-pages .entry:not(.hidden)').length == 0) {
                $('#more-author-pages').addClass('hidden');
                getAuthorPages($('#more-author-pages'));
            }
            $(".truncate").dotdotdot({
                ellipsis: '... ',
            });
        }
    });
// Get author entries when the page starts on tab 2
    $(document).ready(function () {
        var activeTabId = $('input[name=author-tabs]:checked').attr('id');
        if (activeTabId == 'author-tab2') {
            $('#more-author-entries').addClass('hidden');
            getAuthorEntries($('#more-author-entries'));
        } else if (activeTabId == 'author-tab3') {
            $('#more-author-pages').addClass('hidden');
            getAuthorPages($('#more-author-pages'));
        }
    });


    $('#more-author-posts').click(function() {
        var authorURL =
            $('.author-description .author-name a').attr('href').split('/');
        var author = authorURL[3];

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/profile/author/' + author + '?format=JSON', // add /page/number
            type: 'GET'
        })
            .done(function(data){
                var blogs = JSON.parse(data).blogs,
                    blogsEntry = $('#author-tab-content1 .info-entry').get(0);

                // Once the server responds with the result, update the
                //  textbox with that result.

                for(var i= 0; i < blogs.length; i++){
                    var newBlogsEntry = $(blogsEntry).clone();

                    newBlogsEntry.find('.entry-name').text(blogs[i].name);
                    newBlogsEntry.find('.information-blog').text(blogs[i].description);
                    newBlogsEntry.find('.entries-count').text(blogs[i].count.post);
                    newBlogsEntry.find('.entry-slug').attr('href', '/post/' + blogs[i].slug);

                    newBlogsEntry.appendTo($('.author-entries-list'));
                }
            })
    });


});
