package PearlBee;
# ABSTRACT: PerlBee Blog platform

use Dancer2;
use Dancer2::Plugin::DBIC;

# Other used modules
use DateTime;

# Included controllers

# Common controllers
use PearlBee::Authentication;
use PearlBee::Authorization;
use PearlBee::Dashboard;
use PearlBee::REST;

# Admin controllers
use PearlBee::Admin;

# Author controllers
use PearlBee::Author::Post;
use PearlBee::Author::Comment;

use PearlBee::Helpers::Util qw(generate_crypted_filename map_posts create_password);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);
use PearlBee::Helpers::Captcha;

our $VERSION = '0.1';

=head

Prepare the blog path

=cut

hook 'before' => sub {
  session app_url   => config->{app_url} unless ( session('app_url') );
  session blog_name => resultset('Setting')->first->blog_name unless ( session('blog_name') );
  session multiuser => resultset('Setting')->first->multiuser;
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
    },
    { layout => 'main' };
};

=head

Home page

=cut

get '/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $page        = params->{page};
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
    },
    { layout => 'main' };
};


=head

View post method

=cut

get '/post/:slug' => sub {
  
  my $slug       = params->{slug};
  my $post       = resultset('Post')->find({ slug => $slug });
  my $settings   = resultset('Setting')->first;
  my @tags       = resultset('View::PublishedTags')->all();
  my @categories = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent     = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular    = resultset('View::PopularPosts')->search({}, { rows => 3 });

  new_captcha_code();

  # Grab the approved comments for this post and the corresponding reply comments
  my @comments;
  @comments = resultset('Comment')->search({ post_id => $post->id, status => 'approved', reply_to => undef }) if ( $post );
  foreach my $comment (@comments) {
    my @comment_replies = resultset('Comment')->search({ reply_to => $comment->id, status => 'approved' }, {order_by => { -asc => "comment_date" }});
    foreach my $reply (@comment_replies) {
      my $el;
      map { $el->{$_} = $reply->$_ } ('avatar', 'fullname', 'comment_date', 'content');
      $el->{uid}->{username} = $reply->uid->username if $reply->uid;
      push(@{$comment->{comment_replies}}, $el);
    }
  }

  template 'post',
    {
      post       => $post,
      recent     => \@recent,
      popular    => \@popular,
      categories => \@categories,
      comments   => \@comments,
      setting    => $settings,
      tags       => \@tags,
    },
    { layout => 'main' };
};

=head

Add a comment method

=cut

post '/comment/add' => sub {

  my $fullname    = params->{fullname};
  my $post_id     = params->{id};
  my $secret      = params->{secret};
  my @comments    = resultset('Comment')->search({ post_id => $post_id, status => 'approved', reply_to => undef });
  my $post        = resultset('Post')->find( $post_id );
  my @categories  = resultset('Category')->all();
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  my $params      = params;
  my $user        = session('user');
  
  $params->{reply_to} = $1 if ($params->{in_reply_to} =~ /(\d+)/);
  if ($params->{reply_to}) {
    my $comm = resultset('Comment')->find({ id => $params->{reply_to} });
    if ($comm) {
      $params->{reply_to_content} = $comm->content;
      $params->{reply_to_user} = $comm->fullname;
    }
  }

  my $template_params = {
    post        => $post,
    categories  => \@categories,
    popular     => \@popular,
    recent      => \@recent,
    warning     => 'The secret code is incorrect'
  };

  if ( check_captcha_code($secret) ) {
    # The user entered the correct secret code
    eval {

      # If the person who leaves the comment is either the author or the admin the comment is automaticaly approved

      my $comment = resultset('Comment')->can_create( $params, $user );

      # Notify the author that a new comment was submited
      my $author = $post->user;

      Email::Template->send( config->{email_templates} . 'new_comment.tt',
      {
          From    => config->{default_email_sender},
          To      => $author->email,
          Subject => ($params->{reply_to} ? 'A comment reply was submitted to your post' : 'A new comment was submitted to your post'),

          tt_vars => {
            fullname         => $fullname,
            title            => $post->title,
            comment          => $params->{comment},
            signature        => config->{email_signature},
            post_url         => config->{app_url} . '/post/' . $post->slug,
            app_url          => config->{app_url},
            reply_to_content => $params->{reply_to_content} || '',
            reply_to_user    => $params->{reply_to_user} || '',
          },
      }) or error "Could not send the email";
    };
    error $@ if ( $@ );

    # Grab the approved comments for this post
    @comments = resultset('Comment')->search({ post_id => $post->id, status => 'approved', reply_to => undef }) if ( $post );

    delete $template_params->{warning};
    delete $template_params->{in_reply_to};

    if (($post->user_id && $user && $post->user_id == $user->{id}) or ($user && $user->{is_admin})) {
      $template_params->{success} = 'Your comment has been submited. Thank you!';
    } else {
      $template_params->{success} = 'Your comment has been submited and it will be displayed as soon as the author accepts it. Thank you!';
    }
  }
  else {
    # The secret code inncorrect
    # Repopulate the fields with the data

    $template_params->{fields} = $params;
  }

  foreach my $comment (@comments) {
    my @comment_replies = resultset('Comment')->search({ reply_to => $comment->id, status => 'approved' }, {order_by => { -asc => "comment_date" }});
    foreach my $reply (@comment_replies) {
      my $el;
      map { $el->{$_} = $reply->$_ } ('avatar', 'fullname', 'comment_date', 'content');
      $el->{uid}->{username} = $reply->uid->username if $reply->uid;
      push(@{$comment->{comment_replies}}, $el);
    }
  }
  $template_params->{comments} = \@comments;

  new_captcha_code();

  template 'post', $template_params, { layout => 'main' };

};

=head

List all posts by selected category

=cut

get '/posts/category/:slug' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $slug        = params->{slug};
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
    },
    { layout => 'main' };
};

=head

List all posts by selected category

=cut

get '/posts/category/:slug/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $page        = params->{page};
  my $slug        = params->{slug};
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
    },
    { layout => 'main' };
};

=head

List all posts by selected author

=cut

get '/posts/user/:username' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $username    = params->{username};
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
    },
    { layout => 'main' };
};

=head

List all posts by selected category

=cut

get '/posts/user/:username/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $username    = params->{username};
  my $user         = resultset('User')->find({username => $username});
  unless ($user) {
    # we did not identify the user
  }
  my $page        = params->{page};
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
    },
    { layout => 'main' };
};

=head

List all posts by selected tag

=cut

get '/posts/tag/:slug' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $slug        = params->{slug};
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
    },
    { layout => 'main' };
};

=head

List all posts by selected tag

=cut

get '/posts/tag/:slug/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my $page        = params->{page};
  my $slug        = params->{slug};
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
    },
    { layout => 'main' };
};

get '/sign-up' => sub {

  new_captcha_code();

  template 'signup', {}, { layout => 'main' };
};

post '/sign-up' => sub {
  my $params = params();
  
  my $err;

  my $template_params = {
    username        => $params->{username},
    email           => $params->{email},
    first_name      => $params->{first_name},
    last_name       => $params->{last_name},
  };

  if ( check_captcha_code($params->{secret}) ) {
    # The user entered the correct secrete code
    eval {
      
      my $u = resultset('User')->search( { email => $params->{email} } )->first;
      if ($u) {
        $err = "An user with this email address already exists.";
      } else {
        $u = resultset('User')->search( { username => $params->{username} } )->first;
        if ($u) {
          $err = "The provided username is already in use.";
        } else {

          # Create the user
          if ( params->{username} ) {
  
            # Set the proper timezone
            my $dt       = DateTime->now;
            my $settings = resultset('Setting')->first;
            $dt->set_time_zone( $settings->timezone );

            my ($password, $pass_hash, $salt) = create_password();

            resultset('User')->create({
              username        => $params->{username},
              password        => $pass_hash,
              salt            => $salt,
              email           => $params->{email},
              first_name      => $params->{first_name},
              last_name       => $params->{last_name},
              register_date   => join (' ', $dt->ymd, $dt->hms),
              role            => 'author',
              status          => 'pending'
            });

            # Notify the author that a new comment was submited
            my $first_admin = resultset('User')->search( {role => 'admin', status => 'activated' } )->first;

            Email::Template->send( config->{email_templates} . 'new_user.tt',
            {
              From     => config->{default_email_sender},
              To       => $first_admin->email,
              Subject  => 'A new user applied as an author to the blog',

              tt_vars  => {
                first_name       => $params->{first_name},
                last_name        => $params->{last_name},
                username         => $params->{username},
                email            => $params->{email},
                signature        => config->{email_signature},
                blog_name        => session('blog_name'),
                app_url          => session('app_url'),
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

    new_captcha_code();

    template 'signup', $template_params, { layout => 'main' };
  } else {
    template 'notify', {success => 'The user was created and it is waiting for admin approval.'},  { layout => 'main'};
  }
};

sub new_captcha_code {

  my $code = PearlBee::Helpers::Captcha::generate();

  session secret => $code;
  session secrets => [] unless session('secrets'); # this is a hack because Google Chrome triggers GET 2 times, and it messes up the valid captcha code
  push(session('secrets'), $code);

  return $code;
}

sub check_captcha_code {
  my $code = shift;

  my $ok = 0;
  my $sess = session();

  if ($sess->{data}->{secrets}) {
    foreach my $secret (@{$sess->{data}->{secrets}}) {
      my $result= $PearlBee::Helpers::Captcha::captcha->check_code($code, $secret);
      if ( $result == 1 ) {
        $ok = 1;
        session secrets => [];
        last;
      }
    }
  }

  return $ok;
}

1;
