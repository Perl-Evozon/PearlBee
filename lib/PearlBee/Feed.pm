package PearlBee::Feed;

use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Feed;
use Data::Dumper;
use Try::Tiny;

=head2 Get XML feed of all current posts

=cut

get '/feed' => sub {
    my $feed;
    my @posts = reverse resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 10 });
    try {
        $feed = create_feed(
            format  => params->{format} ||
                       config->{plugins}{feed}{format},
            title   => config->{plugins}{feed}{title},
            entries => [ map { title => $_->title,
                               link => config->{app_url} . '/' . $_->slug }, @posts ],
        );
    }
    catch {
        my ( $exception ) = @_;
 
        if ( $exception->does('FeedInvalidFormat') ) {
            return $exception->message;
        }
        elsif ( $exception->does('FeedNoFormat') ) {
            return $exception->message;
        }
        else {
            $exception->rethrow;
        }
    };
 
    return $feed;
};

=head2 Get XML feed of all current posts for a given user

=cut

get '/feed/:uid' => sub {
    my $feed;
    my $user_id = route_parameters->{uid};
    my @posts = reverse resultset('Post')->search(
        { status => 'published', user_id => $user_id },
        { order_by => { -desc => "created_date" }, rows => 10 }
    );
    try {
        $feed = create_feed(
            format  => params->{format} ||
                       config->{plugins}{feed}{format},
            title   => config->{plugins}{feed}{title},
            entries => [ map { title => $_->title,
                               link => config->{app_url} . '/' . $_->slug }, @posts ],
        );
    }
    catch {
        my ( $exception ) = @_;
 
        if ( $exception->does('FeedInvalidFormat') ) {
            return $exception->message;
        }
        elsif ( $exception->does('FeedNoFormat') ) {
            return $exception->message;
        }
        else {
            $exception->rethrow;
        }
    };
 
    return $feed;
};


=head2 Get XML feed of all current comments for a given blogpost

=cut

get '/feed/post/:slug' => sub {
    my $feed;
    my $post = resultset('Post')->find({slug => route_parameters->{slug}});
    if ( $post ) {
      my $post_id = $post->id;
      my @comments = reverse resultset('Comment')->search(
          { status => 'approved', post_id => $post_id },
          { order_by => { -desc => "comment_date" }, rows => 10 }
      );
      try {
          $feed = create_feed(
              format  => params->{format} ||
                         config->{plugins}{feed}{format},
              title   => config->{plugins}{feed}{title},
              entries => [ map { title => $_->fullname. " commented on " . $post->title,
                                 link => '/post/' . route_parameters->{slug} . "#comment_" . $_->id }, @comments ],
          );
      }
      catch {
          my ( $exception ) = @_;
 
          if ( $exception->does('FeedInvalidFormat') ) {
              return $exception->message;
          }
          elsif ( $exception->does('FeedNoFormat') ) {
              return $exception->message;
          }
          else {
              $exception->rethrow;
          }
      };
    }

    return $feed;
};

get '/feed/author/:username' => sub {
    my $feed;
    my $username = route_parameters->{username};
    my ( $user ) = resultset('Users')->search_lc( $username );
    my $user_id  = $user->id;
    my @posts    =  resultset('Post')->search(
        { user_id => $user_id },
        { order_by => { -desc => "created_date" }, rows => 10 }
    );
    try {
        $feed = create_feed(
            format  => params->{format} ||
                       config->{plugins}{feed}{format},
            title   => config->{plugins}{feed}{title},
            entries => [ map { title => $_->title,
                link =>  '/post/' . $_->slug  }, @posts ],
        );
    }
    catch {
        my ( $exception ) = @_;
        if ( $exception->does('FeedInvalidFormat') ) {
            return $exception->message;
        }
        elsif ( $exception->does('FeedNoFormat') ) {
            return $exception->message;
        }
        else {
            $exception->rethrow;
        }
    };

    return $feed;
};

1;
