/**
 * Created by mihaelamarinca on 4/26/2016.
 */
$(document).ready(function(){
// Leave a comment for a blog post
    $("#reply_post_comment_button").on('click', function (e){
        var comment = $("#reply_post_comment_form #comment").val();
        var slug = $("#reply_post_comment_form #slug").val();
        var isEmpty = $.trim($("#reply_post_comment_form #comment").val());
        $("#reply_post_comment_form").trigger('reset');
        var themeinitial = $('#cmn-toggle-4').is(':checked');

        console.log(comment);
        console.log(slug);
        if (isEmpty == "") {
// e.preventDefault();
// e.stopPropagation();
            return false;
        } else {
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
                var posts = JSON.parse(data);
                //for( var i= 0; i < posts.length; i++){
                var entryItem = $(".comment-list .comment").get(0),
                    newItem = $(entryItem).clone(),
                    avatarPath;

                if (posts.status === 'approved') {
                    if (posts.user.avatar_path) {
                        avatarPath = '/avatar/'+ posts.user.username;
                        newItem.find(".bubble img.user-image").attr("class", "user-image");
                    } else if (themeinitial === false){
                        avatarPath = "/blog/img/male-user.png";
                    } else if (themeinitial === true) {
                        avatarPath = "/blog/img/male-user-light.png";
                    }

                    newItem.find(".bubble img.user-image").attr("src", avatarPath);
                    newItem.find(".comment-author a").html(posts.user.name);
                    newItem.find(".comment-author a").attr("href", "/profile/author/" + posts.user.username);
                    newItem.find(".content-comment .cmeta .hours").html(posts.comment_date_human);
                    newItem.find(".content-comment p").html(posts.content);

                    // newItem.insertBefore($(".comment"));
                    $($(".comment-list").get(0)).prepend(newItem);
                    newItem.removeClass('hidden');
                //}
                } else if (posts.status === 'pending') {
                    $(".display_msg").addClass("show");
                }
            });
        }
    });
});