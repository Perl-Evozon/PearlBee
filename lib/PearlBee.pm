package PearlBee;

# ABSTRACT: PerlBee Blog platform

use Dancer2;
use Dancer2::Plugin::DBIC;

# Other used modules
use Authen::Captcha;
use Digest::MD5 qw(md5_hex);

# Included controllers

# Common controllers
use PearlBee::Authentication;
use PearlBee::Authorization;
use PearlBee::Dashboard;

# Admin controllers
use PearlBee::Admin::Category;
use PearlBee::Admin::Tag;
use PearlBee::Admin::Post;
use PearlBee::Admin::Comment;
use PearlBee::Admin::User;

# Author controllers
use PearlBee::Author::Post;
use PearlBee::Author::Comment;

use Data::Dumper;
our $VERSION = '0.1';

=head

Home page

=cut

get '/' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my @posts     = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => $nr_of_rows });
  my $nr_of_posts  = resultset('Post')->search({ status => 'published' })->count;
  my @tags      = resultset('View::PublishedTags')->all();
  my @categories   = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent     = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => 3 });
  my @popular   = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my $total_pages = ( ($nr_of_posts / $nr_of_rows) != int($nr_of_posts / $nr_of_rows) ) ? int($nr_of_posts / $nr_of_rows) + 1 : ($nr_of_posts % $nr_of_rows);
  my $previous_link = '#';
  my $next_link     =  ( $total_pages < 2 ) ? '#' : '/page/2';
  my $posts2     = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => $nr_of_rows })->first;


    template 'index', 
      { 
        posts       => \@posts,
        recent       => \@recent,
        popular     => \@popular,
        tags        => \@tags,
        categories     => \@categories,
        page       => 1,
        total_pages   => $total_pages,
        previous_link   => $previous_link,
        next_link     => $next_link
    }, 
    { layout => 'main' };
};

=head

Home page

=cut

get '/page/:page' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $page     = params->{page};
  my @posts     = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => $nr_of_rows, page => $page });
  my $nr_of_posts  = resultset('Post')->search({ status => 'published' })->count;
  my @tags      = resultset('View::PublishedTags')->all();
  my @categories   = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent     = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => 3 });
  my @popular   = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my $total_pages   = ( ($nr_of_posts / $nr_of_rows) != int($nr_of_posts / $nr_of_rows) ) ? int($nr_of_posts / $nr_of_rows) + 1 : ($nr_of_posts % $nr_of_rows);

  # Calculate the next and previous page link
  my $previous_link   = ( $page == 1 ) ? '#' : '/page/' . ( int($page) - 1 );
  my $next_link     = ( $page == $total_pages ) ? '#' : '/page/' . ( int($page) + 1 );

    template 'index', 
      { 
        posts       => \@posts,
        recent       => \@recent,
        popular     => \@popular,
        tags        => \@tags,
        categories     => \@categories,
        page       => $page,
        total_pages   => $total_pages,
        previous_link   => $previous_link,
        next_link     => $next_link
    }, 
    { layout => 'main' };
};


=head

View post method

=cut

get '/post/:id' => sub {
  
  my $post_id   = params->{id};
  my $post     = resultset('Post')->find( $post_id );
  my @categories   = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });

  my $captcha = Authen::Captcha->new();

    # set the data_folder. contains flatfile db to maintain state
    $captcha->data_folder('public/captcha');

    # set directory to hold publicly accessable images
    $captcha->output_folder('public/captcha/image');
    my $md5sum = $captcha->generate_code(5);

    # Rename the image file so that the encrypted code won't show on the UI
    my $command = "mv " . config->{captcha_folder} . "/image/" . $md5sum . ".png" . " " . config->{captcha_folder} . "/image/image.png";
    `$command`;

    # Store the encrypted code on the session
    session secret => $md5sum;

  # Grab the approved comments for this post
  my @comments = resultset('Comment')->search({ post_id => $post_id, status => 'approved' });

  template 'post', { post => $post, categories => \@categories, comments => \@comments }, { layout => 'main' };
};

=head 

Add a comment method

=cut

post '/comment/add' => sub {

  my $fullname = params->{fullname};
  my $email    = params->{email};
  my $text     = params->{comment};
  my $post_id  = params->{id};
  my $secret   = params->{secret};
  my $post     = resultset('Post')->find( $post_id );

  if ( md5_hex($secret) eq session('secret') ) {
    # The user entered the correct secrete code
    eval {
      my $comment = resultset('Comment')->create({
          fullname => $fullname,
          content  => $text,
          email    => $email,
          post_id   => $post_id
        });

      # Notify the author that a new comment was submited
      my $author = $post->user;
      Email::Template->send( config->{email_templates} . 'new_comment.tt',
      {
          From    => 'no-reply@PearlBee.com',
          To      => $author->email,
          Subject => 'A new comment was submited to your post',

          tt_vars => { 
              fullname => $fullname,
              title    => $post->title,
              post_url => config->{app_url} . '/post/' . $post->id,
              url      => config->{app_url}
          },
      }) or error "Could not send the email";
    };

    error $@ if ( $@ );
    redirect '/post/' . $post_id;
  }
  else {
    # The secret code inncorrect
    # Repopulate the fields with the data
    
    my @categories   = resultset('Category')->all();

    # Grap the approved comments for this post
    my @post_comments;
    my @comments;
    eval{
      @post_comments = $post->post_comments;    
      @comments = grep { $_->comment->status eq 'approved' } @post_comments;
    };

    # Generate a new captcha code
    my $captcha = Authen::Captcha->new();

      # set the data_folder. contains flatfile db to maintain state
      $captcha->data_folder('public/captcha');

      # set directory to hold publicly accessable images
      $captcha->output_folder('public/captcha/image');
      my $md5sum = $captcha->generate_code(5);

      # Rename the file so that the encrypted code won't show on the UI
      my $command = "mv public/captcha/image/" . $md5sum . ".png" . " public/captcha/image/image.png";
      `$command`;

      # Store the encrypted code on the session
      session secret => $md5sum;

    template 'post', 
      { 
        post        => $post, 
        categories  => \@categories, 
        comments    => \@comments,
        fullname    => $fullname,
        email       => $email,
        text        => $text,
        warning     => 'Wrong secret code. Please enter the code again'
      }, 
      { layout => 'main' };
  }  
  
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
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my $total_pages   = ( ($nr_of_posts / $nr_of_rows) != int($nr_of_posts / $nr_of_rows) ) ? int($nr_of_posts / $nr_of_rows) + 1 : ($nr_of_posts % $nr_of_rows);
  my $previous_link = '#';
  my $next_link     = ( $total_pages < 2 ) ? '#' : '/posts/category/' . $slug . '/page/2';

  # Extract all posts with the wanted category
  template 'index', 
      { 
        posts         => \@posts,
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
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my $total_pages   = ( ($nr_of_posts / $nr_of_rows) != int($nr_of_posts / $nr_of_rows) ) ? int($nr_of_posts / $nr_of_rows) + 1 : ($nr_of_posts % $nr_of_rows);

  # Calculate the next and previous page link
  my $previous_link   = ( $page == 1 ) ? '#' : '/posts/category/' . $slug . '/page/' . ( int($page) - 1 );
  my $next_link     = ( $page == $total_pages ) ? '#' : '/posts/category/' . $slug . '/page/' . ( int($page) + 1 );

  template 'index', 
      { 
        posts         => \@posts,
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
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my $total_pages = ( ($nr_of_posts / $nr_of_rows) != int($nr_of_posts / $nr_of_rows) ) ? int($nr_of_posts / $nr_of_rows) + 1 : ($nr_of_posts % $nr_of_rows);
  my $previous_link = '#';
  my $next_link     = ( $total_pages < 2 ) ? '#' : '/posts/tag/' . $slug . '/page/2';

  template 'index', 
      {         
        posts         => \@posts,
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
  my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => "created_date DESC", rows => 3 });
  my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

  my $total_pages   = ( ($nr_of_posts / $nr_of_rows) != int($nr_of_posts / $nr_of_rows) ) ? int($nr_of_posts / $nr_of_rows) + 1 : ($nr_of_posts % $nr_of_rows);

  # Calculate the next and previous page link
  my $previous_link = ( $page == 1 ) ? '#' : '/posts/tag/' . $slug . '/page/' . ( int($page) - 1 );
  my $next_link     = ( $page == $total_pages ) ? '#' : '/posts/tag/' . $slug . '/page/' . ( int($page) + 1 );

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
