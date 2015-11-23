package PearlBee::RSS;

use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Feed;

use Try::Tiny;

=head2

Get XML feed of all current posts

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

=head2

Get XML feed of all current posts for a given user

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
1;
