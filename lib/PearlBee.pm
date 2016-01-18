package PearlBee;
# ABSTRACT: PerlBee Blog platform

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::reCAPTCHA;

# Other used modules
use DateTime;
use JSON qw//;
use Text::Markdown qw( markdown );
use Try::Tiny;
use Digest::SHA;

# Included controllers

# Common controllers
use PearlBee::Authentication;
use PearlBee::Authorization;
use PearlBee::Dashboard;
use PearlBee::REST;
use PearlBee::RSS;
use PearlBee::ResetPassword;
use PearlBee::Search;

# Admin controllers
use PearlBee::Admin;

# Author controllers
use PearlBee::Author::Post;
use PearlBee::Author::Comment;

use PearlBee::Helpers::Email qw(send_email_complete);
use PearlBee::Helpers::Util qw(generate_crypted_filename map_posts create_password);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);
use PearlBee::Password;

our $VERSION = '0.1';
use Data::Dumper;
  
=head

Prepare the blog path

=cut

hook 'before' => sub {
  session app_url   => config->{app_url} unless ( session('app_url') );
  session blog_name => resultset('Setting')->first->blog_name unless ( session('blog_name') );
  session multiuser => resultset('Setting')->first->multiuser;
};

=head

Blog assets - XXX this should be managed by nginx or something.

=cut

set public_dir => path(config->{user_assets});
set avatar_dir => path(config->{user_avatars});

get '/users/*' => sub {
    my ( $file ) = splat;

    send_file $file;
};

get '/avatars/*' => sub {
    my ( $file ) = splat;

    send_file $file;
};

=head

Home page

=cut

get '/' => sub {
  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my @posts       = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ status => 'published' })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages);
  
    template 'index',
      {
        posts         => \@mapped_posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        categories    => \@categories,
        page          => 1,
        total_pages   => $total_pages,
        previous_link => $previous_link,
        next_link     => $next_link
    };
};

get '/search/:query' => sub {
  my $searchquery = route_parameters->{'query'};
  template 'searchresults', {
    searchquery => $searchquery
  }
};


=head

Home page

=cut

get '/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 10; # Number of posts per page
  my $page        = route_parameters->{'page'};
  my @posts       = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search({ status => 'published' })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages);

  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode([
      @mapped_posts   
    ]); 
  }     
  else {

    template 'index',
      {
        posts         => \@mapped_posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        categories    => \@categories,
        page          => $page,
        total_pages   => $total_pages,
        previous_link => $previous_link,
        next_link     => $next_link
    };
  }
};


=head

View post method

=cut

get '/post/:slug' => sub {

  my $slug          = route_parameters->{'slug'};
  my $post          = resultset('Post')->find({ slug => $slug });
  my $settings      = resultset('Setting')->first;
  my @tags          = resultset('View::PublishedTags')->all();
  my @categories    = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent     = resultset('Post')->get_recent_posts();
  my @popular    = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my ($next_post, $previous_post, @post_tags, @comments);
  if ( $post and $post->id ) {
    $next_post     = $post->next_post;
    $previous_post = $post->previous_post;
    @post_tags     = $post->tag_objects;
    @comments   = resultset('Comment')->get_approved_comments_by_post_id($post->id);
  }

  # #############################################################
  # Jeff, I commented your code regarding the Markdown conversion, because I moved the logic into get_approved_comments_by_post_id function.
  # We won't have a hierarchical system anyomre, so no need to get comments by reply_to
  # #############################################################

  # # Grab the approved comments for this post and the corresponding reply comments
  # my @comments;
  # @comments = resultset('Comment')->search({ post_id => $post->id, status => 'approved', reply_to => undef }) if ( $post );
  # foreach my $comment (@comments) {
  #   my @comment_replies = resultset('Comment')->search({ reply_to => $comment->id, status => 'approved' }, {order_by => { -asc => "comment_date" }});
  #   foreach my $reply (@comment_replies) {
  #     my $el;
  #     map { $el->{$_} = $reply->$_ } ('avatar', 'fullname', 'comment_date', 'content', 'type');
  #     if ( $el->{type} eq 'Markdown' ) {
  #       $el->{content} = markdown($el->{content});
  #     }
  #     $el->{uid}->{username} = $reply->uid->username if $reply->uid;
  #     push(@{$comment->{comment_replies}}, $el);
  #   }
  # }

  template 'post',
    {
      post          => $post,
      next_post     => $next_post,
      previous_post => $previous_post,
      recent        => \@recent,
      popular       => \@popular,
      categories    => \@categories,
      comments      => \@comments,
      setting       => $settings,
      tags          => \@post_tags,
    };
};

=head

Add a comment method

=cut

post '/comments' => sub {

  my $user        = session('user');
  my $username    = $user->username;

  my $parameters  = body_parameters;
  my $post_id = route_parameters->{slug};
  my @comments    = resultset('Comment')->get_approved_comments_by_post_id($post_id);
  my $post        = resultset('Post')->find({ slug => $post_id });
  my @categories  = resultset('Category')->all();
  my @recent      = resultset('Post')->get_recent_posts();
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  my $blog        = resultset('BlogOwner')->find({ user_id => $user->{id} });
  my %result;

  try {
    # If the person who leaves the comment is either the author or the admin the comment is automaticaly approved

    my $comment = resultset('Comment')->can_create( $parameters, $user );

    # Notify the author that a new comment was submitted
    my $author = $post->user;

    if ($blog and $blog->email_notification) {
      Helpers::Email::send_email_complete(
        { from            => config->{default_email_sender},
          to              => $author->email,
          subject         => 'A new comment was submitted to your post',
          template        => 'new_comment.tt',
          template_params =>
          { name      => $username,
            fullname  => 'get fullname from signed-in commenter',
            title     => $post->title,
            comment   => $parameters->{'comment'},
            signature => config->{email_signature},
            post_url  => config->{app_url} . '/post/' . $post->slug,
            app_url   => config->{app_url}
          }
        }
      );
    }

    if (($post->user_id && $user && $post->user_id == $user->{id}) or ($user && $user->{is_admin})) {
      $result{message} = 'Your comment has been submited. Thank you!';
      $result{success} = 1;
      $result{approved} = 0;
      $result{email_sent} = 1;
    } else {
      $result{message} = 'Your comment has been submited and it will be displayed as soon as the author accepts it. Thank you!';
      $result{success} = 1;
      $result{approved} = 1;
      $result{email_sent} = 1;
    }
  }
  catch {
      $result{message} = q{An error occurred while submitting your comment. We're already on it!};
      $result{success} = 0;
      $result{approved} = 0;
      $result{email_sent} = 0;
  };

  # foreach my $comment (@comments) {
  #   my @comment_replies = resultset('Comment')->search({ reply_to => $comment->id, status => 'approved' }, {order_by => { -asc => "comment_date" }});
  #   foreach my $reply (@comment_replies) {
  #     my $el;
  #     map { $el->{$_} = $reply->$_ } ('avatar', 'fullname', 'comment_date', 'content');
  #     $el->{uid}->{username} = $reply->uid->username if $reply->uid;
  #     push(@{$comment->{comment_replies}}, $el);
  #   }
  # }

  content_type 'application/json';
  return to_json(\%result);
};

=head

List all posts by selected category

=cut

get '/posts/category/:slug' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $slug        = route_parameters->{'slug'};
  my @posts       = resultset('Post')->search({ 'category.slug' => $slug, 'status' => 'published' }, { join => { 'post_categories' => 'category' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'category.slug' => $slug, 'status' => 'published' }, { join => { 'post_categories' => 'category' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/category/' . $slug);

  # Extract all posts with the wanted category
  template 'index',
      {
        posts         => \@mapped_posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        page          => 1,
        categories    => \@categories,
        total_pages   => $total_pages,
        next_link     => $next_link,
        previous_link => $previous_link,
        posts_for_category => $slug
    };
};

=head

List all posts by selected category

=cut

get '/posts/category/:slug/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $page        = route_parameters->{'page'};
  my $slug        = route_parameters->{'slug'};
  my @posts       = resultset('Post')->search({ 'category.slug' => $slug, 'status' => 'published' }, { join => { 'post_categories' => 'category' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search({ 'category.slug' => $slug, 'status' => 'published' }, { join => { 'post_categories' => 'category' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/category/' . $slug);

  template 'index',
      {
        posts              => \@mapped_posts,
        recent             => \@recent,
        popular            => \@popular,
        tags               => \@tags,
        categories         => \@categories,
        page               => $page,
        total_pages        => $total_pages,
        next_link          => $next_link,
        previous_link      => $previous_link,
        posts_for_category => $slug
    };
};

=head

List all posts by selected author

=cut

get '/posts/user/:username' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $username    = route_parameters->{'username'};
  my $user         = resultset('User')->find({username => $username});
  unless ($user) {
    # we did not identify the user
  }
  my @posts       = resultset('Post')->search({ 'user_id' => $user->id, 'status' => 'published' }, { order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'user_id' => $user->id, 'status' => 'published' })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);
  my $movable_type_url = config->{movable_type_url};
  my $app_url = config->{app_url};

  for my $post ( @mapped_posts ) {
    $post->{content} =~ s{$movable_type_url}{$app_url}g;
  }


  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/user/' . $username);

  # Extract all posts with the wanted category
  template 'index',
      {
        posts          => \@mapped_posts,
        recent         => \@recent,
        popular        => \@popular,
        tags           => \@tags,
        page           => 1,
        categories     => \@categories,
        total_pages    => $total_pages,
        next_link      => $next_link,
        previous_link  => $previous_link,
        posts_for_user => $username,
    };
};

=head

List all posts by selected category

=cut

get '/posts/user/:username/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $username    = route_parameters->{'username'};
  my $user        = resultset('User')->find({username => $username});
  unless ($user) {
    # we did not identify the user
  }
  my $page        = route_parameters->{'page'};
  my @posts       = resultset('Post')->search({ 'user_id' => $user->id, 'status' => 'published' }, { order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search({ 'user_id' => $user->id, 'status' => 'published' })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/user/' . $username);

  template 'index',
      {
        posts         => \@mapped_posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        categories    => \@categories,
        page          => $page,
        total_pages   => $total_pages,
        next_link     => $next_link,
        previous_link => $previous_link,
        posts_for_user => $username,
    };
};

=head

List all posts by selected tag

=cut

get '/posts/tag/:slug' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $slug        = route_parameters->{'slug'};
  my @posts       = resultset('Post')->search({ 'tag.slug' => $slug, 'status' => 'published' }, { join => { 'post_tags' => 'tag' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'tag.slug' => $slug, 'status' => 'published' }, { join => { 'post_tags' => 'tag' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/tag/' . $slug);

  template 'index',
      {
        posts         => \@mapped_posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        page          => 1,
        categories    => \@categories,
        total_pages   => $total_pages,
        next_link     => $next_link,
        previous_link => $previous_link,
        posts_for_tag => $slug
    };
};

=head

List all posts by selected tag

=cut

get '/posts/tag/:slug/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $page        = route_parameters->{'page'};
  my $slug        = route_parameters->{'slug'};
  my $tag         = resultset('Tag')->find({ slug => $slug });
  my @posts       = resultset('Post')->search({ 'tag.slug' => $slug, 'status' => 'published' }, { join => { 'post_tags' => 'tag' }, order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'tag.slug' => $slug, 'status' => 'published' }, { join => { 'post_tags' => 'tag' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/tag/' . $slug);

  template 'index',
      {
        posts         => \@mapped_posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        page          => $page,
        categories    => \@categories,
        total_pages   => $total_pages,
        next_link     => $next_link,
        previous_link => $previous_link,
        posts_for_tag => $slug
    };
};

get '/register' => sub {
   
  template 'register', {
      recaptcha  => recaptcha_display(),
  };

};

get '/register_success' => sub {
   
  template 'register_success';

};

get '/register_done' => sub {
   
  template 'register_done';

};

get '/password_recovery' => sub {

  template 'password_recovery';

};

get '/profile' => sub {

  template 'profile';

};

get '/sign-up' => sub {

  template 'signup', {
    recaptcha => recaptcha_display()
  };
};

post '/sign-up' => sub {
  my $params = body_parameters;

  my $err;

  my $template_params = {
    username        => $params->{'username'},
    email           => $params->{'email'},
    name            => $params->{'name'},
  };

  my $response = $params->{'g-recaptcha-response'};
  my $result = recaptcha_verify($response);


  if ( $result->{success} || $ENV{CAPTCHA_BYPASS} ) {
    # The user entered the correct secrete code
    eval {

      my $existing_users = resultset('User')->search( { email => $params->{'email'} } )->count;

      if ($existing_users > 0) {
        $err = "An user with this email address already exists.";
      } else {
        $existing_users = resultset('User')->search( { username => $params->{'username'} } )->count;
        if ($existing_users > 0) {
          $err = "The provided username is already in use.";
        } else {

          # Create the user
          if ( $params->{'username'} ) {

            # Set the proper timezone
            my $dt       = DateTime->now;
            my $settings = resultset('Setting')->first;
            $dt->set_time_zone( $settings->timezone );

            # Match encryption from MT
            my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
            my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

            my $crypt_sha  = '$6$' .
                             $salt .
                             '$' .
                             Digest::SHA::sha512_base64( $salt . $params->{'password'} );

            resultset('User')->create({
              username        => $params->{username},
              password        => $crypt_sha,
              email           => $params->{'email'},
              name            => $params->{'name'},
              register_date   => join (' ', $dt->ymd, $dt->hms),
              role            => 'author',
              status          => 'pending'
            });

            # Notify the author that a new comment was submited
            my $first_admin = resultset('User')->search( {role => 'admin', status => 'active' } )->first;

            Email::Template->send( config->{email_templates} . 'new_user.tt',
            {
              From     => config->{default_email_sender},
              To       => $first_admin->email,
              Subject  => 'A new user applied as an author to the blog',

              tt_vars  => {
                name             => $params->{'name'},
                username         => $params->{'username'},
                email            => $params->{'email'},
                signature        => config->{email_signature},
                blog_name        => session('blog_name'),
                app_url          => session('app_url'),
              }
            }) or error "Could not send new_user email";

            my $date             = DateTime->now();
            my $activation_token = generate_hash( $params->{'email'} . $date );
            my $token = $activation_token->{hash};
            Email::Template->send( config->{email_templates} .
                                   'activation_email.tt',
            {
              From     => config->{default_email_sender},
              To       => $params->{'email'},
              Subject  => 'Welcome to Blogs.Perl.Org',

              tt_vars  => {
                name      => $params->{'name'},
                username  => $params->{'username'},
                mail_body => "/activation?token=$token",
              }
            }) or error "Could not send the email";

          } else {
            $err = 'Please provide a username.';
          }
        }
      }
    };
    error $@ if ( $@ );
  }
  else {
    # The secret code inncorrect
    # Repopulate the fields with the data
    $err = "Invalid secret code.";
  }

  if ($err) {
    $template_params->{warning} = $err if $err;
    $template_params->{recaptcha} = recaptcha_display();

    template 'signup', $template_params;
  } else {
    template 'notify', {success => 'The user was created and it is waiting for admin approval.'};
  }
};

1;
