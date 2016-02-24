package PearlBee;
# ABSTRACT: PerlBee Blog platform

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::reCAPTCHA;

# Other used modules
use DateTime;
use JSON qw//;
use Try::Tiny;
use Digest::SHA;

# Included controllers
use PearlBee::Profile;
use PearlBee::Post;

# Common controllers
use PearlBee::Authentication;
use PearlBee::Authorization;
use PearlBee::Dashboard;
use PearlBee::REST;
use PearlBee::Feed;
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

=item Add items such as the copyright info here, globally.

=cut

hook before_template_render => sub {
  my ( $tokens ) = @_;
  $tokens->{copyright_year} = ((localtime)[5]+1900);
};
  
=head

Prepare the blog path

=cut

hook before => sub {
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

=item /theme

Set user's theme (assuming they're logged in) to the given name.

=cut


post '/theme' => sub {

  my $session_user = session('user');
  my $theme        = body_parameters->get('theme') eq 'true' ? 'light' : 'dark';
  if ($session_user) {
     return unless $session_user->{id}; 
     my $user = resultset('Users')->find({ id => $session_user->{id} });
     $user->update({ theme => $theme });
  } 
  my $json = JSON->new;
  $json->allow_blessed(1);
  $json->convert_blessed(1);
  $json->encode([$theme]); 

  session theme => $theme;
  content_type 'application/json';
  return to_json([$theme]);
};

=item /

Home page

=cut

get '/' => sub {
  my $nr_of_rows  = config->{posts_on_page} || 5; # Number of posts per page
  my @posts       = resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => $nr_of_rows });
  my $nr_of_posts = resultset('Post')->search_published({})->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => 3 });
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

get '/search' => sub { template 'searchresults' };

=item /page/:page - Home paging

=cut

get '/page/:page' => sub {

  my $nr_of_rows  = config->{posts_on_page} || 10; # Number of posts per page
  my $page        = route_parameters->{'page'};
  my @posts       = resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
  my $nr_of_posts = resultset('Post')->search_published({})->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
  my @recent      = resultset('Post')->search_published({},{ order_by => { -desc => "created_date" }, rows => 3 });
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

Add a comment method

=cut

post '/comments' => sub {
  my $parameters   = body_parameters;
  my $post_slug    = $parameters->{slug};
  my $comment_text = $parameters->{comment};
  my $post         = resultset('Post')->find({ slug => $post_slug });
  my $user         = session('user');

  my $username   = $user->{username};
  my $poster_id  = $user->{id};
  my ($owner_id) = $post->user_id;

  $parameters->{id}  = $post->id;
  $parameters->{uid} = $poster_id;
  
  my ($blog_owner) = resultset('BlogOwner')->search({ user_id => $owner_id });
  my $blog         = resultset('Blog')->find({ id => $blog_owner->blog_id });

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

    my %expurgated_user = %$user;
    delete $expurgated_user{id};
    $result{user} = \%expurgated_user;
    $result{comment_date} = $comment->comment_date;
    $result{comment_date_human} = $comment->comment_date_human;
    $result{status} = $comment->status;

    #if (($post->user_id && $user && $post->user_id == $user->{id}) or ($user && $user->{is_admin})) {
      $result{content} = $comment->content;
    #}
  }
  catch {
      $result{message} = q{An error occurred while submitting your comment. We're already on it!};
      $result{success} = 0;
      $result{approved} = 0;
      $result{email_sent} = 0;
  };

  my $json = JSON->new;
  $json->allow_blessed(1);
  $json->convert_blessed(1);
  unless ($result{status} eq 'approved') {
  delete $result{content};
  }
  return $json->encode(\%result); 
};

get '/register' => sub {
   
  template 'register', {
      recaptcha  => recaptcha_display(),
  };

};

get '/register_success' => sub { template 'register_success' };

get '/register_done' => sub { template 'register_done' };

get '/password_recovery' => sub { template 'password_recovery' };

get '/sign-up' => sub {

  template 'signup', {
    recaptcha => recaptcha_display()
  };
};

post '/sign-up' => sub {
  my $params = body_parameters;

  my $err;

  my $template_params = {
    username => $params->{'username'},
    email    => $params->{'email'},
    name     => $params->{'name'},
  };

  my $response = $params->{'g-recaptcha-response'};
  my $result   = recaptcha_verify($response);

  if ( $result->{success} || $ENV{CAPTCHA_BYPASS} ) {
    # The user entered the correct secrete code
    try {

      my $existing_users = resultset('Users')->search({ email => $params->{'email'} })->count;

      if ($existing_users > 0) {
        $err = "An user with this email address already exists.";
      } else {
        $existing_users = resultset('Users')->search({ username => $params->{'username'} })->count;
        if ($existing_users > 0) {
          $err = "The provided username is already in use.";
        } else {

          # Create the user
          if ( $params->{'username'} ) {

            # Match encryption from MT
            my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
            my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;

            my $crypt_sha  = '$6$' .
                             $salt .
                             '$' .
                             Digest::SHA::sha512_base64( $salt . $params->{'password'} );

            my $date             = DateTime->now();
            my $activation_token = generate_hash( $params->{'email'} . $date );
            my $token = $activation_token->{hash};

            resultset('Users')->create({
              username         => $params->{username},
              password         => $crypt_sha,
              email            => $params->{'email'},
              name             => $params->{'name'},
              role             => 'author',
              status           => 'pending',
              activation_token => $activation_token
            });

            # Notify the author that a new comment was submited
            my $first_admin = resultset('Users')->search({ role => 'admin', status => 'active' })->first;

            Email::Template->send( config->{email_templates} . 'new_user.tt',
            {
              From    => config->{default_email_sender},
              To      => $first_admin->email,
              Subject => 'A new user applied as an author to the blog',

              tt_vars => {
                name      => $params->{'name'},
                username  => $params->{'username'},
                email     => $params->{'email'},
                signature => config->{email_signature},
                blog_name => session('blog_name'),
                app_url   => session('app_url'),
              }
            }) or error "Could not send new_user email";

            Email::Template->send( config->{email_templates} .
                                   'activation_email.tt',
            {
              From    => config->{default_email_sender},
              To      => $params->{'email'},
              Subject => 'Welcome to Blogs.Perl.Org',

              tt_vars => {
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
    }
    catch {
      error $_;
    };
  }
  else {
    # The secret code inncorrect
    # Repopulate the fields with the data
    $err = "Invalid secret code.";
  }

  if ($err) {
    $template_params->{warning}   = $err;
    $template_params->{recaptcha} = recaptcha_display();

    template 'signup', $template_params;
  } else {
    template 'notify', {success => 'The user was created and it is waiting for admin approval.'};
  }
};

1;
