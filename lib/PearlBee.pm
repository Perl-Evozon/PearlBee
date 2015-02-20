package PearlBee;

# ABSTRACT: PerlBee Blog platform

use Dancer2;
use Dancer2::Plugin::DBIC;

# Other used modules
use Digest::MD5 qw(md5_hex);
use Authen::Captcha;
use DateTime;
use Data::Dumper;

# Included controllers

# Common controllers
use PearlBee::Authentication;
use PearlBee::Authorization;
use PearlBee::Dashboard;
use PearlBee::REST;

# Admin controllers
use PearlBee::Admin::Category;
use PearlBee::Admin::Tag;
use PearlBee::Admin::Post;
use PearlBee::Admin::Comment;
use PearlBee::Admin::User;
use PearlBee::Admin::Settings;

# Author controllers
use PearlBee::Author::Post;
use PearlBee::Author::Comment;

use PearlBee::Helpers::Util qw(generate_crypted_filename get_presentation_posts_info);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);
use PearlBee::Helpers::Captcha;

our $VERSION = '0.1';

=head

Prepare the blog path

=cut

hook 'before' => sub { 
  session app_url   => config->{app_url} unless ( session('app_url') ); 
  session blog_name => resultset('Setting')->first->blog_name unless ( session('blog_name') ); 
};

=head

Home page

=cut

get '/' => sub {

  my $nr_of_rows  = 6; # Number of posts per page
  my @posts       = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ status => 'published' })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  
  # extract demo posts info
  my @mapped_posts = get_presentation_posts_info(@posts);

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

  my $nr_of_rows  = 6; # Number of posts per page
  my $page        = params->{page};
  my @posts       = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search({ status => 'published' })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  
  # extract demo posts info
  my @mapped_posts = get_presentation_posts_info(@posts);

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

  # Store the encrypted code on the session
  session secret => PearlBee::Helpers::Captcha::generate();

  # Grab the approved comments for this post
  my @comments;
  @comments = resultset('Comment')->search({ post_id => $post->id, status => 'approved' }) if ( $post );

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
  my @comments    = resultset('Comment')->search({ post_id => $post_id, status => 'approved' });
  my $post        = resultset('Post')->find( $post_id );
  my @categories  = resultset('Category')->all();
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  my $params      = params;

  my $template_params = {
    post        => $post,
    categories  => \@categories,
    popular     => \@popular,
    recent      => \@recent,
    comments    => \@comments,
    warning     => 'The secret code is incorrect'
  };
  
  my $captcha = Authen::Captcha->new(
    data_folder => config->{captcha_folder},
    output_folder => config->{captcha_folder} .'/image',
  );
  
  my $result= $captcha->check_code($secret, session('secret'));
  if ( $result == 1 ) {
    # The user entered the correct secrete code
    eval {

      # If the person who leaves the comment is either the author or the admin the comment is automaticly approved
      my $user    = session('user');
      my $comment = resultset('Comment')->can_create( $params, $user );

      # Notify the author that a new comment was submited
      my $author = $post->user;
      Email::Template->send( config->{email_templates} . 'new_comment.tt',
      {
          From    => 'no-reply@PearlBee.com',
          To      => $author->email,
          Subject => 'A new comment was submitted to your post',

          tt_vars => { 
            fullname   => $fullname,
            title      => $post->title,
            comment    => $params->{comment},
            signature  => config->{email_signature},
            post_url   => config->{app_url} . '/post/' . $post->slug,
            app_url    => config->{app_url},
            app_name   => config->{appname},
          },
      }) or error "Could not send the email";
    };

    # Grap the approved comments for this post
    @comments = resultset('Comment')->search({ post_id => $post_id, status => 'approved' });

    error $@ if ( $@ );

    delete $template_params->{warning};
    $template_params->{success} = 'Your comment has been submited and it will be displayed as soon as the author accepts it. Thank you!';
    $template_params->{comments} = \@comments;
  }
  else {
    # The secret code inncorrect
    # Repopulate the fields with the data
   
    $template_params->{fields} = $params;
  }

  # Store the encrypted code on the session
  session secret => PearlBee::Helpers::Captcha::generate();

  template 'post', $template_params, { layout => 'main' };
  
};

=head

List all posts by selected category

=cut

get '/posts/category/:slug' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $slug        = params->{slug};
  my @posts       = resultset('Post')->search({ 'category.slug' => $slug, 'status' => 'published' }, { join => { 'post_categories' => 'category' }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'category.slug' => $slug }, { join => { 'post_categories' => 'category' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  
  # extract demo posts info
  my @mapped_posts = get_presentation_posts_info(@posts);

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
        previous_link => $previous_link
    }, 
    { layout => 'main' };
};

=head

List all posts by selected category

=cut

get '/posts/category/:slug/page/:page' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $page        = params->{page};
  my $slug        = params->{slug};
  my @posts       = resultset('Post')->search({ 'category.slug' => $slug, 'status' => 'published' }, { join => { 'post_categories' => 'category' }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search({ 'category.slug' => $slug }, { join => { 'post_categories' => 'category' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  
  # extract demo posts info
  my @mapped_posts = get_presentation_posts_info(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/category/' . $slug);

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
        previous_link => $previous_link
    }, 
    { layout => 'main' };
};

=head

List all posts by selected tag

=cut

get '/posts/tag/:slug' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $slug        = params->{slug};
  my @posts       = resultset('Post')->search({ 'tag.slug' => $slug, 'status' => 'published' }, { join => { 'post_tags' => 'tag' }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'tag.slug' => $slug }, { join => { 'post_tags' => 'tag' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });
  
  # extract demo posts info
  my @mapped_posts = get_presentation_posts_info(@posts);

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
        previous_link => $previous_link
    }, 
    { layout => 'main' };
};

=head

List all posts by selected tag

=cut

get '/posts/tag/:slug/page/:page' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $page        = params->{page};
  my $slug        = params->{slug};
  my $tag         = resultset('Tag')->find({ slug => $slug });
  my @posts       = resultset('Post')->search({ 'tag.slug' => $slug, 'status' => 'published' }, { join => { 'post_tags' => 'tag' }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search({ 'tag.slug' => $slug }, { join => { 'post_tags' => 'tag' } })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/tag/' . $slug);

  template 'index', 
      { 
        posts         => \@posts,
        recent        => \@recent,
        popular       => \@popular,
        tags          => \@tags,
        page          => $page,
        categories    => \@categories,
        total_pages   => $total_pages,
        next_link     => $next_link,
        previous_link => $previous_link
    }, 
    { layout => 'main' };
};

true;
